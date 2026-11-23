import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../../shared/providers/database_provider.dart';
import 'backup_service.dart';

/// Supabase project (free plan). The publishable key is safe to ship in the app
/// because every table is protected by Row Level Security (auth.uid() = user_id).
class SupabaseConfig {
  static const url = 'https://keuheinbxgevhuhywfou.supabase.co';
  static const publishableKey = 'sb_publishable_5mIKcW6A-n9YOdPUHObnOA_VjnsihWi';

  /// Deep link the confirmation e-mail opens (registered in AndroidManifest.xml).
  /// Must also be added in Supabase → Authentication → URL Configuration.
  static const authRedirect = 'io.fitcompanion://login-callback';
}

class CloudStatus {
  final bool enabled; // Supabase initialised (false in tests)
  final String? email; // signed-in user
  final DateTime? lastSyncedAt;
  final DateTime? remoteUpdatedAt;

  const CloudStatus({this.enabled = false, this.email, this.lastSyncedAt, this.remoteUpdatedAt});

  bool get signedIn => email != null;

  /// Another device uploaded after our last sync.
  bool get remoteIsNewer =>
      remoteUpdatedAt != null && (lastSyncedAt == null || remoteUpdatedAt!.isAfter(lastSyncedAt!.add(const Duration(seconds: 2))));
}

enum SignUpResult { signedIn, confirmEmail }

/// Snapshot-based cloud sync: the whole local DB (same JSON as the local backup)
/// is stored in `user_backups` (one row per user).
class CloudService {
  final AppDatabase db;
  final bool enabled;

  CloudService(this.db, {this.enabled = true});

  static const _lastSyncKey = 'cloud_last_sync';
  static const _autoKey = 'cloud_auto_sync';

  SupabaseClient get _sb => Supabase.instance.client;

  User? get user => enabled ? _sb.auth.currentUser : null;

  Stream<Object?> get authChanges => enabled ? _sb.auth.onAuthStateChange : const Stream.empty();

  Future<SignUpResult> signUp(String email, String password) async {
    final res = await _sb.auth.signUp(email: email, password: password, emailRedirectTo: SupabaseConfig.authRedirect);
    return res.session != null ? SignUpResult.signedIn : SignUpResult.confirmEmail;
  }

  Future<void> signIn(String email, String password) => _sb.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _sb.auth.signOut();

  Future<DateTime?> _getPref(String key) async {
    final row = await (db.select(db.appPreferences)..where((p) => p.key.equals(key))).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  Future<void> _setPref(String key, String value) => db.into(db.appPreferences).insertOnConflictUpdate(
        AppPreferencesCompanion(key: Value(key), value: Value(value)),
      );

  Future<bool> isAutoSync() async {
    final row = await (db.select(db.appPreferences)..where((p) => p.key.equals(_autoKey))).getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> setAutoSync(bool v) => _setPref(_autoKey, v.toString());

  Future<CloudStatus> status() async {
    if (!enabled) return const CloudStatus();
    final u = user;
    final last = await _getPref(_lastSyncKey);
    if (u == null) return CloudStatus(enabled: true, lastSyncedAt: last);
    DateTime? remote;
    try {
      final row = await _sb.from('user_backups').select('updated_at').eq('user_id', u.id).maybeSingle();
      remote = row == null ? null : DateTime.tryParse(row['updated_at'] as String);
    } catch (_) {}
    return CloudStatus(enabled: true, email: u.email, lastSyncedAt: last, remoteUpdatedAt: remote);
  }

  /// Uploads this phone's data (overwrites the cloud copy).
  Future<void> push({String? device}) async {
    final u = user;
    if (u == null) throw StateError('not_signed_in');
    final data = await BackupService(db).exportMap();
    final row = await _sb
        .from('user_backups')
        .upsert({
          'user_id': u.id,
          'data': data,
          'schema_version': db.schemaVersion,
          'device': device,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select('updated_at')
        .single();
    // The sync pref itself is written after the export, so it never ends up in the snapshot.
    await _setPref(_lastSyncKey, row['updated_at'] as String);
  }

  /// Replaces this phone's data with the cloud copy. Returns false when the cloud is empty.
  Future<bool> pull() async {
    final u = user;
    if (u == null) throw StateError('not_signed_in');
    final row = await _sb.from('user_backups').select('data, updated_at').eq('user_id', u.id).maybeSingle();
    if (row == null) return false;
    await BackupService(db).restoreMap(Map<String, dynamic>.from(row['data'] as Map));
    await _setPref(_lastSyncKey, row['updated_at'] as String);
    return true;
  }

  /// Safe automatic upload (app going to background): never overwrites a newer
  /// cloud copy coming from another device — that needs a manual choice.
  Future<void> autoPushIfSafe() async {
    if (!enabled || user == null || !await isAutoSync()) return;
    final s = await status();
    if (s.remoteIsNewer) return;
    await push(device: 'auto');
  }

  // ---------------------------------------------------------------------------
  // AI coach (Supabase Edge Function `ai-coach` → Gemini). History lives in Supabase.
  // ---------------------------------------------------------------------------

  Future<List<CoachMessage>> coachHistory() async {
    if (user == null) return const [];
    final rows = await _sb
        .from('coach_messages')
        .select('role, content, media_path, media_type')
        .order('id', ascending: true)
        .limit(60);
    return [
      for (final r in rows)
        CoachMessage(
          role: r['role'] as String,
          text: (r['content'] as String?) ?? '',
          mediaPath: r['media_path'] as String?,
          mediaType: r['media_type'] as String?,
        ),
    ];
  }

  /// Uploads a photo/video for the coach into the user's private folder.
  Future<String> uploadCoachMedia(Uint8List bytes, {required String mime, required String extension}) async {
    final u = user;
    if (u == null) throw CoachException('unauthorized');
    final path = '${u.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';
    try {
      await _sb.storage
          .from('coach-media')
          .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: mime, upsert: false))
          .timeout(const Duration(seconds: 120));
    } on TimeoutException {
      throw CoachException('upload_failed');
    } on StorageException catch (e) {
      throw CoachException(e.statusCode == '413' ? 'media_too_big' : 'upload_failed');
    }
    return path;
  }

  /// Temporary URL to show a stored photo in the chat (1 hour).
  Future<String?> coachMediaUrl(String path) async {
    try {
      return await _sb.storage.from('coach-media').createSignedUrl(path, 3600);
    } catch (_) {
      return null;
    }
  }

  Future<String> askCoach({
    required String message,
    required String context,
    required String language,
    String? mediaPath,
    String? mediaMime,
  }) async {
    final FunctionResponse res;
    try {
      // Never spin forever: text ~60 s, media (video) up to ~2 min.
      res = await _sb.functions.invoke('ai-coach', body: {
        'message': message,
        'context': context,
        'language': language,
        if (mediaPath != null) 'media': {'path': mediaPath, 'mime': mediaMime},
      }).timeout(Duration(seconds: mediaPath != null ? 130 : 60));
    } on TimeoutException {
      throw CoachException('gemini_busy');
    } on FunctionException catch (e) {
      final d = e.details;
      throw CoachException((d is Map ? d['error'] : null)?.toString() ?? 'http_${e.status}');
    }
    final data = res.data;
    if (data is Map && data['reply'] is String) return data['reply'] as String;
    throw CoachException((data is Map ? data['error'] : null)?.toString() ?? 'unknown');
  }

  /// AI estimate of a food's nutrition (Edge Function `ai-food-macros` → Gemini).
  Future<FoodMacroEstimate> estimateFoodMacros({
    required String name,
    required String description,
    required double grams,
    required String language,
  }) async {
    if (user == null) throw CoachException('unauthorized');
    final FunctionResponse res;
    try {
      res = await _sb.functions
          .invoke('ai-food-macros', body: {'name': name, 'description': description, 'grams': grams, 'language': language})
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw CoachException('gemini_busy');
    } on FunctionException catch (e) {
      final d = e.details;
      throw CoachException((d is Map ? d['error'] : null)?.toString() ?? 'http_${e.status}');
    }
    final data = res.data;
    if (data is Map && data['per100g'] is Map) return FoodMacroEstimate.fromJson(Map<String, dynamic>.from(data));
    throw CoachException((data is Map ? data['error'] : null)?.toString() ?? 'unknown');
  }

  Future<void> clearCoachHistory() async {
    final u = user;
    if (u == null) return;
    await _sb.from('coach_messages').delete().eq('user_id', u.id);
    // Also delete the photos/videos sent to the coach.
    try {
      final files = await _sb.storage.from('coach-media').list(path: u.id);
      if (files.isNotEmpty) {
        await _sb.storage.from('coach-media').remove([for (final f in files) '${u.id}/${f.name}']);
      }
    } catch (_) {}
  }

  /// Image analysis (Edge Function `ai-vision`): mode = food_photo | label | progress.
  /// Images are sent inline (base64) and are not stored on the server.
  Future<Map<String, dynamic>> analyzeImages({
    required String mode,
    required List<VisionImage> images,
    required String language,
    Map<String, dynamic> extra = const {},
  }) async {
    if (user == null) throw CoachException('unauthorized');
    final FunctionResponse res;
    try {
      res = await _sb.functions.invoke('ai-vision', body: {
        'mode': mode,
        'language': language,
        'images': [
          for (final i in images) {'data': base64Encode(i.bytes), 'mime': i.mime, if (i.label != null) 'label': i.label},
        ],
        ...extra,
      }).timeout(const Duration(seconds: 90));
    } on TimeoutException {
      throw CoachException('gemini_busy');
    } on FunctionException catch (e) {
      final d = e.details;
      throw CoachException((d is Map ? d['error'] : null)?.toString() ?? 'http_${e.status}');
    }
    final data = res.data;
    if (data is Map && data['error'] == null) return Map<String, dynamic>.from(data);
    throw CoachException((data is Map ? data['error'] : null)?.toString() ?? 'unknown');
  }
  /// AI tools (Edge Function `ai-tools`): weekly_report | program | meal_plan | voice_log.
  Future<Map<String, dynamic>> aiTool(String mode, {required String language, Map<String, dynamic> body = const {}}) async {
    if (user == null) throw CoachException('unauthorized');
    final FunctionResponse res;
    try {
      res = await _sb.functions
          .invoke('ai-tools', body: {'mode': mode, 'language': language, ...body})
          .timeout(const Duration(seconds: 95));
    } on TimeoutException {
      throw CoachException('gemini_busy');
    } on FunctionException catch (e) {
      final d = e.details;
      throw CoachException((d is Map ? d['error'] : null)?.toString() ?? 'http_${e.status}');
    }
    final data = res.data;
    if (data is Map && data['error'] == null) return Map<String, dynamic>.from(data);
    throw CoachException((data is Map ? data['error'] : null)?.toString() ?? 'unknown');
  }

  // ---------------- Friends ----------------

  /// Publishes my public stats (only friends can read them) and returns my row.
  Future<Map<String, dynamic>> upsertFriendProfile(Map<String, dynamic> stats) async {
    final u = user;
    if (u == null) throw CoachException('unauthorized');
    final row = await _sb
        .from('friend_profiles')
        .upsert({'user_id': u.id, ...stats, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .select()
        .single();
    return Map<String, dynamic>.from(row);
  }

  /// Me + my friends' public stats.
  Future<List<Map<String, dynamic>>> friendLeaderboard() async {
    if (user == null) throw CoachException('unauthorized');
    final rows = await _sb.from('friend_profiles').select();
    return [for (final r in rows) Map<String, dynamic>.from(r)];
  }

  Future<String> addFriend(String code) async {
    try {
      final name = await _sb.rpc('add_friend', params: {'code': code});
      return name?.toString() ?? '';
    } on PostgrestException catch (e) {
      final m = e.message;
      throw CoachException(m.contains('code_not_found') ? 'code_not_found' : (m.contains('own_code') ? 'own_code' : 'unknown'));
    }
  }

  Future<void> removeFriend(String friendId) => _sb.rpc('remove_friend', params: {'friend': friendId});
  // ---------------- Exercise demo videos ----------------

  /// Cached YouTube demos for an exercise (shared cache, readable without an account);
  /// if nothing is cached and the user is signed in, asks `exercise-video` to look it up once.
  Future<List<ExerciseVideo>> exerciseVideos(String englishName) async {
    if (!enabled) return const [];
    final query = ExerciseVideo.normalize(englishName);
    try {
      final row = await _sb.from('exercise_videos').select('videos').eq('query', query).maybeSingle();
      final cached = ExerciseVideo.listFrom(row?['videos']);
      if (cached.isNotEmpty) return cached;
    } catch (_) {}
    if (user == null) throw CoachException('unauthorized');
    final FunctionResponse res;
    try {
      res = await _sb.functions.invoke('exercise-video', body: {'name': englishName}).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw CoachException('network');
    } on FunctionException catch (e) {
      final d = e.details;
      throw CoachException((d is Map ? d['error'] : null)?.toString() ?? 'http_${e.status}');
    }
    final data = res.data;
    return ExerciseVideo.listFrom(data is Map ? data['videos'] : null);
  }
}

class ExerciseVideo {
  final String id;
  final String title;
  final String channel;
  const ExerciseVideo(this.id, this.title, this.channel);

  /// Must match `normalize` in supabase/functions/exercise-video.
  static String normalize(String s) {
    final t = s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    return t.length > 80 ? t.substring(0, 80) : t;
  }

  static List<ExerciseVideo> listFrom(Object? raw) => [
        if (raw is List)
          for (final v in raw)
            if (v is Map && v['id'] is String) ExerciseVideo(v['id'] as String, '${v['title'] ?? ''}', '${v['channel'] ?? ''}'),
      ];
}

class CoachException implements Exception {
  final String code;
  CoachException(this.code);
  @override
  String toString() => code;
}

/// main.dart overrides this with an enabled service after Supabase.initialize().
final cloudServiceProvider = Provider<CloudService>((ref) => CloudService(ref.watch(databaseProvider), enabled: false));

/// Result of the AI food analysis (values per 100 g; totals are computed in the app).
class FoodMacroEstimate {
  final String foodName;
  final double kcal100, protein100, carbs100, fat100, fiber100;
  final String confidence; // high / medium / low
  final String assumptions;

  const FoodMacroEstimate({
    required this.foodName,
    required this.kcal100,
    required this.protein100,
    required this.carbs100,
    required this.fat100,
    required this.fiber100,
    required this.confidence,
    required this.assumptions,
  });

  factory FoodMacroEstimate.fromJson(Map<String, dynamic> j) {
    final p = Map<String, dynamic>.from(j['per100g'] as Map);
    double d(String k) => (p[k] as num?)?.toDouble() ?? 0;
    return FoodMacroEstimate(
      foodName: (j['food_name'] ?? '').toString(),
      kcal100: d('kcal'),
      protein100: d('protein'),
      carbs100: d('carbs'),
      fat100: d('fat'),
      fiber100: d('fiber'),
      confidence: (j['confidence'] ?? 'medium').toString(),
      assumptions: (j['assumptions'] ?? '').toString(),
    );
  }
}

class CoachMessage {
  final String role; // user | model | error
  final String text;
  final String? mediaPath;
  final String? mediaType; // image | video
  final Uint8List? localBytes; // just-sent photo shown before upload finishes

  const CoachMessage({required this.role, required this.text, this.mediaPath, this.mediaType, this.localBytes});
}

class VisionImage {
  final Uint8List bytes;
  final String mime;
  final String? label; // e.g. "BEFORE – 2026-10-01 – front"

  const VisionImage(this.bytes, {this.mime = 'image/jpeg', this.label});
}
