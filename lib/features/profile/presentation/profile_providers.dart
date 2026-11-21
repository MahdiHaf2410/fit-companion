import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/providers/database_provider.dart';

final profileStreamProvider = StreamProvider<Profile?>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.watchProfile();
});

final goalStreamProvider = StreamProvider<Goal?>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.watchGoal();
});
