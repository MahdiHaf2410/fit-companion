# Fit Companion: project file 🏋️

> This file holds everything about the app: the idea, the structure, what was done, the bugs fixed, and the suggestions.
> **Read this file first in any new chat** (you can clear the chat and continue from here).

Last updated: **2026-11-22**, current version **1.5.0+8** (all 16 suggestions implemented)

---

## 1) The app's idea
**Fit Companion** is an **offline-first** app, fully bilingual (Arabic RTL + English), for people who go to the gym and want to:
- Track their **nutrition** (calories, protein, carbs, fat) with a food database that includes Algerian dishes 🇩🇿
- Track their **workouts** (programs, live sessions, sets, personal records)
- Track their **progress** (weight, waist, 7-day moving average, PRs)
- Learn (**Nutrition Academy**: 14 lessons with quizzes) and use calculators (BMR/TDEE, portion scaler, 1RM, plates)
- Track **water intake**

## 2) Stack
| Part | Technology |
|---|---|
| Framework | Flutter 3.47 / Dart 3.13 |
| State | flutter_riverpod 2.6 (StateProvider / StreamProvider) |
| Navigation | go_router 14 (StatefulShellRoute with 5 tabs) |
| Database | drift 2.24 + SQLite (`fit_companion.sqlite` in Documents) |
| Charts | fl_chart 0.70 |
| Settings | shared_preferences (theme + language) |
| Languages | `lib/l10n/app_en.arb` + `app_ar.arb` → `flutter gen-l10n` |

## 3) Folder map (`lib/`)
```
main.dart                      ← creates ONE DB + DEMO mode
app/app.dart, router.dart      ← MaterialApp + all routes
core/
  theme/app_colors.dart        ← design tokens (colours, gradients) + context.isDark etc.
  theme/app_theme.dart         ← full ThemeData (light + dark)
  widgets/app_card.dart        ← AppCard + Pressable (press animation + haptic)
  widgets/ui_kit.dart          ← ProgressRing, AnimatedNumber, SectionHeader, StatTile,
                                 IconBadge, Pill, WeekStrip, FadeSlideIn, kNavBarClearance
  widgets/app_scaffold_shell.dart ← floating animated bottom bar
  widgets/macro_progress_bar.dart ← animated macro bars
  utils/energy_calculator.dart ← BMR/TDEE/macros (Mifflin-St Jeor)
  utils/strength_calculator.dart ← 1RM (Epley) + plate calculator   [new]
  database/tables.dart         ← table schema (schemaVersion = 2)
  database/seed_data.dart      ← foods + exercises + 3 starter programs
  database/demo_data.dart      ← demo data (DEMO mode only)    [new]
features/
  dashboard/                   ← home screen
  nutrition/                   ← logging + search + recipes + calculators + academy
  hydration/                   ← water tracking                [new]
  workouts/                    ← programs + live session + history + session summary
  progress/                    ← weight + chart + PRs
  profile/                     ← profile + settings + export
  tools/                       ← gym tools (1RM + plates)      [new]
  onboarding/                  ← first-run setup
```

### Main routes
`/home` `/nutrition` `/workouts` `/progress` `/profile` (tabs)
`/nutrition/search|add|custom|recipe/create|calculator|food-calculator|academy|academy/lesson/:id`
`/workouts/programs/create` `/workouts/program/:id` `/workouts/active` `/workouts/exercises`
`/workouts/session/:id` 🆕 `/tools` 🆕 `/progress/add` `/profile/export` `/onboarding`

---

## 4) What was done (session of 2026-11-22)

### 🐞 Bugs fixed
1. **Two separate database instances.** `main.dart` opened one and the provider opened another, so the streams didn't sync. Now there's one instance (`databaseProvider.overrideWithValue(db)`).
2. **The router was rebuilt on every profile change.** When you logged your weight, it threw you back to `/home`. Now the GoRouter is created once and uses `refreshListenable`.
3. **🔴 Live workout session:** ticking a set or adding a set didn't update the screen, because the stream only watched the `workoutSessions` table. Now it watches `workoutSessions` + `workoutSets`.
4. **Two sessions could be started at once**, and `watchSingleOrNull` would crash. Now `startWorkoutSession` returns the session that's already active.
5. **Saving to the DB on every keystroke** (weight/reps) with a PR calculation each time. Now it uses a 600ms debounce.
6. **The PR calculation** compared the set against itself. Now it excludes the current set.
7. **The PR list didn't update** (it was a FutureProvider). Now it's a live StreamProvider.
8. **The home screen could show another day's calories** if you changed the date in the nutrition screen. Now there's `todayNutritionSummaryProvider`.
9. **Hardcoded English text** ("14 Lessons", "Recent Logs", "No active workout session", "BMR & TDEE", "kg × reps"…) moved into the l10n files.
10. **Finishing a workout kept unfinished sets.** They're now deleted on finish, so history stays clean.
11. **Clearing data** now also clears water records (`appPreferences`).
12. **The minus sign in Arabic** (-1.8 showed as 1.8-) is fixed with LRM.
13. **After onboarding, the user could get stuck on the onboarding screen** (a timing issue between `context.go('/home')` and the stream). The redirect now sends anyone who is onboarded to `/home`.
14. **The "Last time" column could show stale data** (a provider cache). Now `autoDispose`.
15. **Swipe-delete** (sets, meals, measurements) now uses `confirmDismiss` (deletes first, then animates) to avoid the "dismissed Dismissible still in tree" error.
16. **A weight/reps edit typed just before leaving the screen** used to be lost. It's now saved in `dispose`.

### 🎨 The new design ("Neon Athletic")
- **Dark-first** palette: near-black background `#090C11` + neon lime `#C6FF3D` + violet `#7C5CFF` + cyan + orange for streaks. Light mode keeps the same identity (`#4A7C00` on white for contrast).
- **Floating, animated bottom nav bar** (pill indicator + haptic).
- **Cards** with soft gradients, 24px corner radius, and a press-scale animation + haptic.
- **Animated progress rings** for calories, water and sets; **counting-up numbers**; **entrance animations** (FadeSlideIn); animated macro bars.
- Modern page transitions (FadeForwards), floating snackbars, bottom sheets with rounded corners.
- Correct RTL handling (EdgeInsetsDirectional; Material chevrons flip on their own, no need to flip them manually).

### ✨ New features
| Feature | Where |
|---|---|
| Home screen: big calories ring + streak + workouts this week + latest weight + 7-day activity strip | Dashboard |
| 💧 Water tracking (+250 / −250, ring + glasses, adjustable goal; default = 35 ml × weight) | Dashboard + Nutrition |
| 7-day date strip in the nutrition screen + coloured meal sections + swipe to delete | Nutrition |
| ⏱️ Live session timer + rest timer (−15/+15/skip) using each exercise's `targetRestSeconds` + sound/haptic at the end | Active Workout |
| "Last time": previous set results shown next to each set + new sessions pre-fill the weight used last time (progressive overload) | Active Workout |
| 🏆 Instant alert on a new PR + PR badge | Active Workout |
| Add an exercise mid-session (search sheet) + swipe-delete a set | Active Workout |
| Quick workout (start empty) | Workouts |
| Session summary (time, sets, volume, PRs, est. 1RM per set) + delete a session | `/workouts/session/:id` |
| Stats: streak, workouts this week, weekly volume | Workouts + Dashboard |
| Progress: current weight, change, BMI + chart with gradient and tooltips + PRs ranked by est. 1RM + swipe-delete a measurement | Progress |
| 🧮 Gym tools: 1RM calculator (Epley + percentages table) + plate calculator (barbell drawing) | `/tools` |
| DEMO mode with a separate DB and sample data | `--dart-define=DEMO=true` |

### Fixes in 1.2.1
- 5/3/1: the main sets and BBB used to interleave (5,10,5,10…). Numbering is now continuous per exercise (+ a test)
- Coach messages are ordered by `id` instead of `created_at` (the question and the answer used to share the same time)
- App startup is never blocked by a notifications error; `res/raw/keep.xml` protects the icon and widget from R8

### Fixes in 1.2.2 (after testing on a phone)
- **Coach errors:** Gemini sometimes returns 503 "high demand". The function now tries several models in turn (`gemini-3.8-flash` → `gemini-3.6-flash` → `gemini-2.5-flash` → `gemini-flash-latest`) with a 20 s timeout each and an overall 50 s budget. The app gives up after 60 s and shows "servers are busy" instead of spinning forever.
- **The confirmation email opened localhost:** `signUp` now uses `emailRedirectTo: io.fitcompanion://login-callback`, and the app catches that link (intent-filter in AndroidManifest). It also needs a dashboard setting (Authentication → URL Configuration).

### 🧪 Tests
- **62 tests all passing** (`flutter test`), including:
  - `test/workouts/strength_and_session_test.dart`: 1RM, plates, streak, live session stream, preventing two sessions, last performance, water
  - `test/ui/regression_test.dart`: leaving onboarding, swipe-deleting a set, "Last time" stays fresh
  - `test/ui/screens_layout_test.dart`: every main screen on a **360px** phone, in **Arabic + English**, **light + dark** (fails on any overflow)
- `flutter analyze` → No issues.

---

## 4b) Versions 1.1.0 → 1.2.0: implementing the 16 suggestions ✅
| # | Feature | Status |
|---|---|---|
| 3 | Copy yesterday (whole day or one meal) + meal templates (⋮ menu on each meal) | ✅ |
| 4 | Exercise progress screen `/workouts/exercise/:id` (e1RM / top weight / volume chart + history) | ✅ |
| 5 | Smart add-weight suggestion (double progression) + auto-fill of the suggested weight | ✅ |
| 6a | Body measurements (chest, arm, thigh, hips, body fat %) + changes card | ✅ |
| 7 | Ready-made programs: Upper/Lower, Full Body A/B, PPL Legs B, 5/3/1 (4 days) + 20 new exercises | ✅ |
| 8 | Muscle heatmap for the week (front/back body) | ✅ |
| 9 | 15 achievements + an unlock alert + `/achievements` | ✅ |
| 15 | Set types (warm-up/drop/failure) + RPE (tap the set number) + supersets (⋮ on the exercise) | ✅ |
| 1 | Barcode scanner (mobile_scanner) → local DB first, then Open Food Facts (cached for offline) `/nutrition/scan` | ✅ |
| 2 | Reminders: water (every X hours), meals, workout days, weigh-in `/settings/reminders` | ✅ |
| 6b | Private progress photos + before/after comparison with a slider `/progress/photos` | ✅ |
| 10 | Backup/restore to a JSON file (share_plus/file_picker) `/settings/backup` | ✅ |
| 11 | Home-screen widget: calories left + protein + water (`FitWidgetProvider.kt`) | ✅ |
| 12 | Health Connect: read steps + write weight `/settings/health` (Apple Health not used, the app is Android only) | ✅ |
| 16 | Rest timer as a live countdown notification (shows on watches) + an alert at the end | ✅ |
| 13 | Cloud sync (Supabase, free plan): email/password account + upload/download of the whole data + automatic backup when leaving the app (never overwrites a newer copy) `/settings/cloud` | ✅ |
| 14 | AI coach (Gemini via the Supabase Edge Function `ai-coach`), conversation stored in Supabase `/coach` | ✅ (needs GEMINI_API_KEY) |

**Services (plugins) behind Riverpod providers** in `lib/core/services/` (notification, health, home_widget, backup). Tests use the Noop versions, `main.dart` swaps in the real ones.
**Android:** minSdk 26, compileSdk 37, desugaring, MainActivity = FlutterFragmentActivity (Health Connect), permissions (INTERNET, POST_NOTIFICATIONS, health.*, camera via mobile_scanner).
**DB v3:** new columns (foods.barcode, workout_sets.set_type/rpe/superset_group, body_metrics.chest/arm/thigh/hips/body_fat) + tables (meal_templates, meal_template_items, progress_photos). `PRAGMA foreign_keys = ON`. Migration test in `test/core/migration_test.dart` (v2→v3 keeps the data). Schemas in `drift_schemas/`.
**Seed v3:** `ensureSeedV3()` runs on every startup (insertOrIgnore), so existing users get the new programs too.
**l10n:** new keys are added with `python tool/add_l10n.py tool/l10n_xxx.py` then `flutter gen-l10n`.

## 4b-2) Version 1.3.0: custom programs + my foods + "I ate it"
**Workouts**
- No more days: "My programs" contains only what the user builds (e.g. Upper A, Lower A, Upper B, Lower B, Arms & Abs).
- Program editor `/workouts/programs/create` and `/workouts/program/:id/edit`: name, description, add/remove exercises, sets/reps/rest with steppers, reordering by dragging.
- The ready-made programs (PPL, Upper/Lower, Full Body, 5/3/1) moved to **"Ready-made programs"** `/workouts/templates`; "Add to my programs & edit" copies one into my programs.
- **Full library: 144 exercises** (`seed_v4.dart`) with Arabic names, plus a **cardio** category. A shared picker `exercise_picker.dart` (search + filter + "Add my exercise" button when you can't find one). Custom exercises are saved with `isCustom = true`.

**Food**
- The search screen has 2 tabs: **"My foods"** (main, starts empty) and **"Suggestions"** (the built-in foods).
- **"Add my food"** `/nutrition/custom` (`my_food_screen.dart`): name + description + weight → **"Calculate with AI"** (Edge Function `ai-food-macros` → Gemini with a JSON schema, USDA/CIQUAL/Maghreb tables, kcal ≈ 4P+4C+9F check, confidence level). Values are editable, then "Save & add to meal". Without an account you enter the values by hand.
- **"Did you eat it?":** each log has `isEaten` + `eatenAt`. A ○ button next to each food: tap it → pick the time → ✓. Only what you ate counts in the totals; planned food shows as "⏳ X kcal planned". "Copy yesterday" and templates now add the food as planned.

**DB v4:** foods.description, food_logs.is_eaten/eaten_at, workout_programs.is_template (migration: old logs = eaten, `prog_*` = templates). Migration tests v2→v4 and v3→v4.
**Supabase:** `ai_usage` table (limit of 80 analyses/day) + `ai-food-macros` function (verify_jwt=false + getUser).

## 4b-3) Version 1.4.0: themes + animated background
- **20 themes** in `lib/core/theme/app_palettes.dart` (Neon, Ocean, Crimson, Royal, Sunset, Emerald, Arctic, Black Gold, Cyberpunk, Sakura, Mono, Sahara, Toxic, Aurora, Lava, Algeria, Espresso, Electric, Rose Gold, Matrix). Each theme = accent/secondary/tertiary colours + neutral tint + **corner shape** (sharp / soft / rounded / pill) + a default effect. Light and dark are generated automatically from the same palette.
- `AppColors.lime/violet/cyan/…` became getters that follow the active theme (`AppColors.active`), and `AppThemeExt` carries the palette + glass mode. Text on top of colours is chosen automatically (black or white, whichever has the higher contrast).
- **Animated background** `lib/core/widgets/animated_background.dart`: 7 effects (orbs, particles, waves, neon grid, aurora, bokeh, stars) + **touch reaction** (ripples, glow, particles that move away from your finger) + an intensity slider. One shared clock (`BackgroundHost` in `MaterialApp.builder`), each page paints its own background through `BackgroundPageTransitionsBuilder`. 30 fps, stops in the background, turns off if "Remove animations" is enabled in Android.
- With animation on: transparent scaffolds, slightly translucent AppBar, "glass" cards.
- Themes screen `/settings/themes` (My account → Themes & appearance): light/dark/system mode, a grid of 20 themes with a live preview, animation, touch reaction, intensity, effect choice.
- Settings saved in SharedPreferences (`ui_palette`, `ui_animated`, `ui_effect`, `ui_interactive`, `ui_intensity`).
- Tests: contrast (WCAG) for every theme in light/dark + rendering the dashboard in all 20 × 2 with the background and touch on. Screenshots for checking: `flutter test test/screenshots/theme_shots_test.dart --dart-define=SHOTS_DIR=<folder>`.
- ⚠️ In widget tests don't use `pumpAndSettle` with the background on (it never stops): use `pump` with a duration.

## 4b-4) Version 1.5.0: AI with images and video + logo
- **Barcode** (`barcode_scan_screen.dart`): local DB → Open Food Facts (now accepts a product with no nutrition table) → if the product's name is known but its values are missing, AI estimates them → if it isn't found at all: "Photo of product", where AI reads the name and the nutrition table from the photo (`ai-vision` mode `label`). The result opens in the add screen (quantity + meal + "I ate it").
- **Meal photo (AI)** `/nutrition/photo` (`food_photo_screen.dart`): photo of a plate/meal/product → items + weight (editable) + kcal/P/C/F + analysis + **suggestions only if needed** (an empty array when the meal is already good) → added to the meal through `logCustomEntry` (foodId = null). Buttons: in the nutrition bar, the tool chips, and food search.
- **Coach chat with images and video:** 📷 button → photo/video (camera or gallery, video ≤ 60 s, ≤ 40MB). Upload to the private bucket `coach-media/<uid>/` (RLS) → the `ai-coach` function downloads it and sends it inline to Gemini. Images show in the history (signed URL). "Clear conversation" also deletes the files.
- **Progress photos:** a card on the home screen + photo date (today / last week / 2 weeks / month / pick from calendar) + pose + choose any two photos to compare + **"Analyse my progress with AI"** (`ai-vision` mode `progress`, after explicit consent; the photos are not saved on the server) → score /10, muscles, fat, analysis per muscle, tips.
- **Home screen:** the greeting is smaller and the name is clearer on its own line.
- **Logo:** `assets/branding/logo.png` + launcher icon (legacy + round + adaptive) + splash (old Android + Android 12+) + in onboarding and the About section.
- **Developer credit** in the profile: "Developed by Mahdi Hafiane".
- Fixed overflows in the profile screen (language selector, rows) + the `Pill` no longer overflows.

**Supabase additions:** bucket `coach-media` (private, 40MB, images/videos, RLS per user folder), `coach_messages.media_path/media_type` columns, `ai_usage.kind` = food_macros/food_photo/label/progress, function `ai-vision` (limits: food_photo 60, label 60, progress 10 per day).

## 4b-5) Version 1.6.0: smart coach, challenges, friends, AI tools, sleep
**Offline analysis (no internet, tested in `test/insights_test.dart`):** logic in `lib/core/utils/insights.dart`, UI in `lib/features/insights/insights.dart`
- **Adaptive TDEE** (card in Progress): real maintenance calories from what you actually ate + your weight trend (least squares, 7700 kcal/kg). Needs ≥10 logged days, ≥4 weigh-ins and a ≥14-day span. The "Apply" button changes the calorie target and moves the difference into carbs.
- **Fatigue and deload detection** (card in Workouts): e1RM dropping 2 sessions in a row + average RPE ≥ 9 over 14 days + ≥6 hard weeks in a row → fresh / watch / deload.
- **Coach notes during the workout** (`active_workout_screen.dart`): you skipped a set, weight dropping, you missed the target reps last time, close to a PR (≤ 2.5 kg).
- **Sleep and performance** (card in Progress): reads `SLEEP_SESSION` from Health Connect (permission `READ_SLEEP`) → average hours for the week + volume after nights of 7 h or more vs short nights (`SleepAnalyzer`).

**Challenges + XP** (`lib/features/challenges/challenges.dart`, route `/challenges`, card on the home screen): 4 weekly challenges (the week starts on **Saturday**) + 4 monthly ones. XP = workouts ×50 + PRs ×30 + days with food logged ×10 + water days ×10 + weigh-ins ×5 + challenges. Level n needs 100·n(n−1)/2 XP. Titles: Beginner → Rookie → Athlete → Warrior → Beast → Legend. Completed challenges are saved in `AppPreferences('challenges_done')`, so their XP stays forever.

**AI tools** (`lib/features/ai/ai_tools.dart`, "AI tools" card on the home screen), one Edge Function **`ai-tools`** with 4 modes:
- `weekly_report` (`/ai/report`): score /10 + summary + what went well + what to improve + goals. Saved in `AppPreferences('ai_weekly_report')`. Optional notification every Friday at 19:00 (`scheduleWeeklyReport`, id 500). Limit 6/day.
- `program` (`/ai/program`): days + goal + equipment + notes → the AI chooses **only from the exercise ids in the app catalogue** (the server filters any other id) → "Save" creates one program per day. Limit 10/day.
- `meal_plan` (`/ai/meals`): one day that hits your targets, with local Algerian foods + a shopping list. "Add to today" logs it as **planned** (isEaten = false). Limit 12/day.
- `voice_log` (🎤 in the nutrition bar + the card): records 16 kHz mono WAV (package `record`, `RECORD_AUDIO`) → Gemini → transcript + items with macros → pick items + meal → log. The audio is not saved anywhere. Limit 60/day.

**Shareable cards** (`lib/features/social/social.dart` `showShareCard`): RepaintBoundary → 3× PNG → share_plus. Buttons: workout summary (session detail) + challenges/level.

**Friends** (`/friends`, from the challenges screen): a random 6-character friend code (`friend_profiles.friend_code`) + leaderboard (weekly volume / workouts / XP). Only friends can read your stats (RLS). Adding and removing go through the `SECURITY DEFINER` functions `add_friend(code)` / `remove_friend(uuid)`, both directions. Long-press to remove.

**Supabase additions:** tables `friend_profiles`, `friendships` (RLS), functions `add_friend`/`remove_friend` (authenticated only), `ai_usage.kind` + weekly_report/program/meal_plan/voice_log, Edge Function `ai-tools` (verify_jwt=false + `auth.getUser()`). Everything is still on the **free plan**.
**Security advisor:** 2 intentional warnings for `add_friend`/`remove_friend` (SECURITY DEFINER callable by authenticated users: they only act on `auth.uid()` and need a valid code). "Leaked password protection" is off (a dashboard setting).
**Sources in the repo:** `supabase/functions/*/index.ts` + `supabase/migrations/*.sql` (copied from what's deployed).
**Tests:** 184 ✅ (incl. layout tests for the new screens at 360px en/ar light/dark).

## 4b-6) Versions 1.6.1 → 1.6.2: exercise demo videos inside the app
- Every exercise has a **video player inside the app** (`ExerciseVideoPlayer` in `lib/core/utils/exercise_video.dart`, package `youtube_player_iframe`, WebView):
  - On the exercise screen it sits at the top (both with and without history). During the workout: ⋮ → "Watch how" → a bottom sheet that plays the video immediately.
  - A thumbnail first (no WebView until you tap ▶), then it plays inline. Fullscreen by rotating the phone or with the button. "Another video" switches between up to 6 results, and ↗ opens it in YouTube.
- **How the video is chosen:** the Edge Function **`exercise-video`** searches the YouTube Data API **once per exercise** (`"<name> exercise proper form"`, embeddable + safeSearch strict).
  - The results are saved in the table **`exercise_videos`** (key = lower-case name). Anyone can read it (even without an account, RLS select for anon); only the function writes to it (service role).
  - The search itself (a cache miss) requires sign-in, with a limit of 60/day per user (`ai_usage.kind = 'video'`).
  - Free quota: 10,000 units/day, a search = 100 units, and the ~130 exercises are searched only once.
- **Fallbacks:** if the user isn't signed in and the exercise isn't in the cache → "Sign in" + "Open in YouTube". If the key is missing or there's an error → "Open in YouTube" (a search).
- **⚠️ Required:** the secret **`YOUTUBE_API_KEY`** in Supabase (Edge Functions → Secrets). Without it the in-app videos don't work (the external button still works).
- Note: `youtube_player_iframe` 6.0.4 is "no longer maintained"; its replacement is the `youtube_player` package (migration later if needed).

## 4b-7) Version 1.7.0: the full exercise library (~420 exercises)
- Added **274 new exercises** from the user's list (StrengthLog categories): chest, shoulders, biceps, triceps, legs, back, glutes, abs, calves, forearms/grip, neck. **Only the names** (EN + Arabic) + muscle group + equipment + type, with no copied instruction text.
- Exercises that were already in the app (Bench Press, Squat, Deadlift, Pull-Up, …, ~85 of them) were **not repeated**.
- Mapping to the app's groups: glutes and calves → `legs`, forearms → `arms`, neck → `back`, abs → `core`. Smith → `machine`. Timed exercises have "(reps = seconds)" in the name, like the old ones.
- New equipment type **`band`** (rubber band): `kEquipments` + `equipBand` + in the AI program builder (with kettlebell).
- **Source:** `tool/seed_v5_data.py` → `python tool/gen_seed_v5.py` generates `lib/core/database/seed_v5.dart` (it checks that no id or name repeats an older one). Inserted with `insertOrIgnore` on every start (`ensureSeedV3`), so **old users get them too with no migration**.
- The video search strips "(reps = seconds)" from the name (`videoSearchName`).
- Tests: `test/catalog_v5_test.dart` (no duplicates, valid groups/equipment, Arabic names, insertion is idempotent). Total 192 ✅.

## 4b-8) Version 1.7.1: fixing account creation and email confirmation
- **Problem:** the confirmation link (`io.fitcompanion://login-callback?code=…`) opened "Page Not Found" (go_router didn't recognise it). The account got confirmed on the server, but the user didn't end up signed in. It also opened as a copy of the app inside Gmail.
- **Fix:**
  - `redirect` in the router: `isAuthCallback(uri)` → saves it in `pendingAuthCallback` → `/settings/cloud`.
  - The Cloud screen finishes the sign-in (`completeAuthCallback`: waits for supabase_flutter, otherwise `getSessionFromUrl`). If that fails, it shows "Email confirmed ✓, now sign in with the password".
  - The activity is now `singleTask` (no `taskAffinity=""`), so the link opens the app itself.
- **Clear error messages** instead of `AuthApiException`:
  - wrong password, email not confirmed (+ a **"Resend"** button), account already exists (Supabase hides it: `identities` empty → `SignUpResult.alreadyExists`), too many emails, weak password, no internet;
  - "Create account" button when the account doesn't exist.
- **Note:** the free plan's email sending is very limited (a few per hour). If a lot of people sign up, it's best to turn off "Confirm email" (Authentication → Sign In / Providers → Email) or add your own SMTP (free, e.g. Brevo/Resend).

## 4b-9) Website + downloads that update automatically
- **Website:** https://mahdihaf2410.github.io/fit-companion/ (GitHub Pages from the `docs/` folder on the `main` branch; free).
  - Files: `docs/index.html` + `style.css` + `app.js`.
  - **Design (v2, redone so it doesn't look generated):** "training log + competition barbell".
    - Chalk background `#EEF1F4`, steel ink `#172033`, and the IWF plate colours. Each colour marks one of the app's tabs: red training / green nutrition / blue progress / yellow coach.
    - Type: Big Shoulders Display + IBM Plex Sans; in Arabic: Reem Kufi + IBM Plex Sans Arabic.
    - The memorable thing: an SVG barbell (160 kg) whose plates load once when the page opens. That's the only motion on the page.
    - No cards / eyebrows / orbs / scroll animations. Numbers only on the install steps.
  - EN/AR with RTL (the ع button, remembered in localStorage, picked automatically from the browser language).
- **Downloads:** every version is a **GitHub Release** with fixed file names: `fit-companion-arm64.apk` (main), `fit-companion-armv7.apk` (old phones), `fit-companion-universal.apk`.
  - The buttons point to `releases/latest/download/<name>`, which is **always the newest version**.
  - `app.js` reads `api.github.com/.../releases/latest` → shows the version, size and date, plus the notes in the right language.
- **⚠️ After every update (fixed steps):**
  1. `version` in pubspec;
  2. build `--release` + `--split-per-abi`;
  3. write `tool/release-notes/vX.Y.Z.md` (EN then `<!-- ar -->` then AR);
  4. `bash tool/release.sh tool/release-notes/vX.Y.Z.md`;
  5. commit + push.

  The site updates **on its own** with no changes to the code. The script refuses to publish if the APKs are older than pubspec.
- The APK is built on this PC (debug key) and **not** on GitHub Actions, so updates install on top of each other.
- Local preview: `.claude/launch.json` → "website" (python http.server on port 8765).

## 4c) Supabase (cloud + coach)
- **Project:** `fit-companion`, ID `keuheinbxgevhuhywfou`, region eu-west-3 (Paris), **free plan ($0)**.
- **URL:** https://keuheinbxgevhuhywfou.supabase.co. The publishable key is in `lib/core/services/cloud_service.dart` (`SupabaseConfig`). It's safe in the APK because RLS protects everything.
- **Tables:** `user_backups` (one JSON snapshot per user), `coach_messages` (conversation history). RLS: `auth.uid() = user_id` on everything. Security advisor = no warnings. Verified: anonymous users can't read or write.
- **Edge Function `ai-coach`:** verify_jwt = true, limit of 40 messages/day per user, model = secret `GEMINI_MODEL` or by default **`gemini-3.8-flash`** (stable, free tier, checked Nov 2026). `verify_jwt = false` on purpose because user tokens are ES256; the function checks the user itself via `auth.getUser()` (verified: 401 for anyone not signed in). It receives only a **compact summary** (`lib/features/coach/coach_context.dart`) with no name or email.
- **⚠️ Two steps you have to do yourself (I can't do them for you):**
  1. Add the Gemini key: Supabase Dashboard → Edge Functions → Secrets → `GEMINI_API_KEY` = your key from aistudio.google.com (free). Optional: `GEMINI_MODEL`.
  2. URL Configuration: Authentication → URL Configuration → **Site URL** = `io.fitcompanion://login-callback` and add the same value under **Redirect URLs**.
  3. (Optional) Turn off email confirmation: Dashboard → Authentication → Sign In / Providers → Email → turn off "Confirm email". The free plan's email sending is very limited, so new accounts may not receive the confirmation link.
- Free projects pause after about 1 week of inactivity. Open them from the dashboard (Restore) if they pause.
- Gemini free tier: Google may use the prompts to improve its models. That's why we send only a summary.

## 4d) Android & APK
- **APK paths** (after `flutter build apk --release`):
  - Universal (works on every phone, ~88MB): `build/app/outputs/flutter-apk/app-release.apk` (all files are in this folder)
  - Smaller, per processor (`flutter build apk --release --split-per-abi`): **`app-arm64-v8a-release.apk`** (~32MB, for most modern phones), `app-armeabi-v7a-release.apk` (older phones)
- The APK is signed with **this PC's debug key**: updates install on top of each other only if built on this same PC. For the Play Store you need your own keystore (see the suggestions).
- **Bump the version** in `pubspec.yaml` (`version: x.y.z+N`, increase N) before every APK so it installs as an update.
- minSdk 26 (Android 8+), compileSdk 37.
- ⚠️ No emulator/phone was available while developing, so the APK has not been tested on a real device yet (only analyze + 98 tests + build).

## 5) How to run and develop
```bash
flutter pub get
flutter run                                   # normal (your real data)
flutter run --dart-define=DEMO=true           # demo data in a separate DB
flutter run --dart-define=DEMO=true --dart-define=INITIAL_ROUTE=/progress   # open a specific screen
flutter test                                  # all tests
flutter analyze
flutter gen-l10n                              # after editing the .arb files
dart run build_runner build --delete-conflicting-outputs   # after changing tables.dart
```
**Important rules for development:**
- Every new string → add it to `app_en.arb` **and** `app_ar.arb`, then `flutter gen-l10n`.
- Any new table → `schemaVersion++` + `onUpgrade` (from < N) + build_runner.
- Small settings with no new table → use the `AppPreferences` key/value table (as with water).
- Tab screens use `padding bottom: kNavBarClearance` so content isn't hidden under the floating bar.
- The project is a **git** repository on GitHub (public), see `README.md`.

---

## 6) Status: done ✅ / not done ⏳
- ✅ The 5 tab screens + Active Workout + Session Detail + Tools redesigned
- ✅ The other screens (onboarding, search, add food, recipes, calculators, academy, profile) **automatically get the new theme**, but their layout was not redesigned by hand
- ⏳ Profile screen: still has hardcoded English text ("Athlete", "yrs")
- ⏳ The weight chart is not mirrored in RTL (left → right); acceptable for charts
- ⏳ `todayNutritionSummaryProvider` / `todayWaterProvider` fix "today" when they're created, so if the app stays open past midnight it keeps showing yesterday (fix: a timer or a refresh on resume)
- ⏳ Program day names (Sat/Wed) and exercise names in sessions stay in English in the Arabic UI (the data is stored in English)
- ⏳ Swipe-to-delete a set works on the set number / "Last time" column, but not when starting from inside the weight/reps field
- ⏳ Not yet tested on a real Android phone (only analyze + 98 tests + APK build)
- ⏳ Cloud sync is snapshot-based (whole file): if two phones edit at the same time, it asks which copy to keep, it does not merge record by record
- ⏳ The sync `updated_at` comes from the phone's clock (a server trigger would be safer)
- ⏳ After a restore / cloud download, the reminders don't reschedule on their own; open the Reminders screen and save to reapply them
- ⏳ 5/3/1: the percentages are in the program notes + the 1RM tool; the weights are not calculated automatically from the Training Max
- ⏳ The home-screen widget refreshes when the app is opened (and every 30 minutes from Android), not instantly when the app is closed

---

## 7) New suggestions (after v1.2.0)
1. **Your own signing key (keystore)** + publishing on Google Play (Internal testing for free)
2. **Automatic 5/3/1 weights** from the Training Max with a weekly cycle
3. **Record-by-record sync** (merge instead of a snapshot) + realtime
4. **Warm-up generator** (automatic warm-up sets before the heavy weight)
5. **Coach on the workout summary**: a one-tap analysis after each workout
6. **Arabic exercise names in programs and sessions** (program names and days too)
7. **Light-mode widget** + a second widget for the next workout
8. **Instructional videos/GIFs** for exercises (offline)

## 7b) Old suggestions (all done in v1.1/v1.2 ✅)
### Priority 1: big value, reasonable effort
1. **Barcode scanner** for foods (mobile_scanner + Open Food Facts when online; cached for offline)
2. **Reminders/notifications**: water, meals, workout time, weigh-in (flutter_local_notifications)
3. **Templates & copy**: "copy yesterday's meals" + "save a meal as a template" + quick add for frequent foods
4. **Detailed exercise screen**: a chart of each exercise's progress (1RM over time) + its personal history
5. **Smart progressive overload**: suggests adding +2.5 kg when you hit the target reps across all sets
6. **Body measurements**: chest/arm/thigh/body fat % + **progress photos** (before/after)

### Priority 2: makes the app more "pro"
7. **Ready-made programs**: PPL, Upper/Lower, Full Body, 5/3/1, with automatic weekly scheduling
8. **Muscle heatmap**: which muscles you trained this week + volume per muscle group
9. **Achievements & badges**: streaks, 100 workouts, first PR… (gamification)
10. **Local backup/restore** of the DB (an export/import file) + CSV export
11. **Home-screen widget** (Android) for calories and water
12. **Health Connect / Apple Health** sync for steps and calories burned

### Priority 3: advanced
13. **Cloud sync** (Supabase or Firebase) + an account
14. **AI coach**: meal or program suggestions based on your goal and data
15. **Supersets / drop sets / RPE** in sets
16. **Wear OS / Apple Watch** for the rest timer

> 📝 Tell me which numbers you want and I'll start on them.
