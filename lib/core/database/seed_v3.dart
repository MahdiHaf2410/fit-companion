/// v3 seed: extra exercises + ready-made programs (PPL, Upper/Lower, Full Body, 5/3/1).
/// Inserted with insertOrIgnore on EVERY startup (idempotent) so existing users get them too.
class SeedV3 {
  SeedV3._();

  static const exercises = <Map<String, String>>[
    {'id': 'ex_deadlift', 'name': 'Conventional Deadlift', 'nameAr': 'الرفعة الميتة', 'muscleGroup': 'back', 'equipment': 'barbell', 'type': 'compound'},
    {'id': 'ex_lat_pulldown', 'name': 'Lat Pulldown', 'nameAr': 'سحب علوي', 'muscleGroup': 'back', 'equipment': 'cable', 'type': 'compound'},
    {'id': 'ex_seated_cable_row', 'name': 'Seated Cable Row', 'nameAr': 'تجديف بالكابل جالساً', 'muscleGroup': 'back', 'equipment': 'cable', 'type': 'compound'},
    {'id': 'ex_face_pull', 'name': 'Face Pull', 'nameAr': 'سحب للوجه', 'muscleGroup': 'shoulders', 'equipment': 'cable', 'type': 'isolation'},
    {'id': 'ex_db_bench_press', 'name': 'Dumbbell Bench Press', 'nameAr': 'ضغط صدر بالدمبل', 'muscleGroup': 'chest', 'equipment': 'dumbbell', 'type': 'compound'},
    {'id': 'ex_cable_fly', 'name': 'Cable Fly', 'nameAr': 'تفتيح بالكابل', 'muscleGroup': 'chest', 'equipment': 'cable', 'type': 'isolation'},
    {'id': 'ex_dips', 'name': 'Parallel Bar Dips', 'nameAr': 'متوازي', 'muscleGroup': 'chest', 'equipment': 'bodyweight', 'type': 'compound'},
    {'id': 'ex_pushup', 'name': 'Push-up', 'nameAr': 'ضغط أرضي', 'muscleGroup': 'chest', 'equipment': 'bodyweight', 'type': 'compound'},
    {'id': 'ex_db_shoulder_press', 'name': 'Seated Dumbbell Shoulder Press', 'nameAr': 'ضغط أكتاف بالدمبل', 'muscleGroup': 'shoulders', 'equipment': 'dumbbell', 'type': 'compound'},
    {'id': 'ex_rear_delt_fly', 'name': 'Rear Delt Fly', 'nameAr': 'تفتيح كتف خلفي', 'muscleGroup': 'shoulders', 'equipment': 'dumbbell', 'type': 'isolation'},
    {'id': 'ex_hammer_curl', 'name': 'Hammer Curl', 'nameAr': 'تمرين المطرقة', 'muscleGroup': 'arms', 'equipment': 'dumbbell', 'type': 'isolation'},
    {'id': 'ex_skull_crusher', 'name': 'Skull Crusher', 'nameAr': 'ترايسبس فرنسي', 'muscleGroup': 'arms', 'equipment': 'barbell', 'type': 'isolation'},
    {'id': 'ex_leg_press', 'name': 'Leg Press', 'nameAr': 'مكبس الأرجل', 'muscleGroup': 'legs', 'equipment': 'machine', 'type': 'compound'},
    {'id': 'ex_leg_curl', 'name': 'Lying Leg Curl', 'nameAr': 'ثني الأرجل', 'muscleGroup': 'legs', 'equipment': 'machine', 'type': 'isolation'},
    {'id': 'ex_leg_extension', 'name': 'Leg Extension', 'nameAr': 'رفرفة أمامي', 'muscleGroup': 'legs', 'equipment': 'machine', 'type': 'isolation'},
    {'id': 'ex_bulgarian_split_squat', 'name': 'Bulgarian Split Squat', 'nameAr': 'سكوات بلغاري', 'muscleGroup': 'legs', 'equipment': 'dumbbell', 'type': 'compound'},
    {'id': 'ex_hip_thrust', 'name': 'Barbell Hip Thrust', 'nameAr': 'دفع الورك', 'muscleGroup': 'legs', 'equipment': 'barbell', 'type': 'compound'},
    {'id': 'ex_calf_raise', 'name': 'Standing Calf Raise', 'nameAr': 'رفع السمانة', 'muscleGroup': 'legs', 'equipment': 'machine', 'type': 'isolation'},
    {'id': 'ex_plank', 'name': 'Plank (reps = seconds)', 'nameAr': 'بلانك (التكرار = ثواني)', 'muscleGroup': 'core', 'equipment': 'bodyweight', 'type': 'isolation'},
    {'id': 'ex_cable_crunch', 'name': 'Cable Crunch', 'nameAr': 'طحن بالكابل', 'muscleGroup': 'core', 'equipment': 'cable', 'type': 'isolation'},
  ];

  /// exercise tuple: (exerciseId, sets, reps, restSeconds, notes?)
  static const programs = <Map<String, Object>>[
    {
      'id': 'prog_ul_upper',
      'name': 'Upper/Lower • Upper',
      'description': 'Upper/Lower split (4 days). Upper body strength + hypertrophy.',
      'scheduledDays': 'Monday,Thursday',
      'exercises': [
        ['ex_bench_press', 4, 6, 150, null],
        ['ex_barbell_row', 4, 8, 120, null],
        ['ex_db_shoulder_press', 3, 10, 90, null],
        ['ex_lat_pulldown', 3, 10, 90, null],
        ['ex_barbell_curl', 2, 12, 60, null],
        ['ex_triceps_pushdown', 2, 12, 60, null],
      ],
    },
    {
      'id': 'prog_ul_lower',
      'name': 'Upper/Lower • Lower',
      'description': 'Upper/Lower split (4 days). Squat + hinge + accessories.',
      'scheduledDays': 'Tuesday,Friday',
      'exercises': [
        ['ex_barbell_squat', 4, 6, 180, null],
        ['ex_romanian_deadlift', 3, 8, 120, null],
        ['ex_leg_press', 3, 12, 90, null],
        ['ex_leg_curl', 3, 12, 60, null],
        ['ex_calf_raise', 4, 15, 60, null],
        ['ex_cable_crunch', 3, 15, 60, null],
      ],
    },
    {
      'id': 'prog_full_body_a',
      'name': 'Full Body A (Beginner)',
      'description': '3 days/week full body, alternate A and B. Ideal for beginners.',
      'scheduledDays': 'Sunday,Wednesday',
      'exercises': [
        ['ex_barbell_squat', 3, 8, 150, null],
        ['ex_bench_press', 3, 8, 120, null],
        ['ex_barbell_row', 3, 8, 120, null],
        ['ex_db_lateral_raise', 2, 15, 60, null],
        ['ex_plank', 3, 45, 60, null],
      ],
    },
    {
      'id': 'prog_full_body_b',
      'name': 'Full Body B (Beginner)',
      'description': '3 days/week full body, alternate A and B.',
      'scheduledDays': 'Monday,Friday',
      'exercises': [
        ['ex_deadlift', 3, 5, 180, null],
        ['ex_overhead_press', 3, 8, 120, null],
        ['ex_lat_pulldown', 3, 10, 90, null],
        ['ex_bulgarian_split_squat', 2, 10, 90, null],
        ['ex_hammer_curl', 2, 12, 60, null],
      ],
    },
    {
      'id': 'prog_ppl_legs_b',
      'name': 'PPL • Legs B (Posterior)',
      'description': 'Second legs day for a 6-day Push/Pull/Legs split.',
      'scheduledDays': 'Sunday',
      'exercises': [
        ['ex_deadlift', 3, 5, 180, null],
        ['ex_hip_thrust', 3, 10, 120, null],
        ['ex_bulgarian_split_squat', 3, 10, 90, null],
        ['ex_leg_curl', 3, 12, 60, null],
        ['ex_calf_raise', 4, 15, 60, null],
      ],
    },
    {
      'id': 'prog_531_press',
      'name': '5/3/1 • Bench Day',
      'description': 'Wendler 5/3/1. Training Max = 90% of 1RM. Week 1: 65/75/85% ×5,5,5+  •  Week 2: 70/80/90% ×3,3,3+  •  Week 3: 75/85/95% ×5,3,1+  •  Week 4: deload 40/50/60% ×5. Then BBB 5×10 @50%.',
      'scheduledDays': 'Monday',
      'exercises': [
        ['ex_bench_press', 3, 5, 180, 'Main 5/3/1 sets — use the 1RM tool (% of Training Max). Last set AMRAP.'],
        ['ex_bench_press', 5, 10, 90, 'Boring But Big: 5×10 @ 50% TM'],
        ['ex_barbell_row', 5, 10, 90, null],
        ['ex_dips', 3, 10, 90, null],
      ],
    },
    {
      'id': 'prog_531_squat',
      'name': '5/3/1 • Squat Day',
      'description': 'Wendler 5/3/1 squat day. Same weekly percentages as Bench Day.',
      'scheduledDays': 'Tuesday',
      'exercises': [
        ['ex_barbell_squat', 3, 5, 180, 'Main 5/3/1 sets — last set AMRAP.'],
        ['ex_barbell_squat', 5, 10, 120, 'Boring But Big: 5×10 @ 50% TM'],
        ['ex_leg_curl', 5, 10, 60, null],
        ['ex_hanging_leg_raise', 3, 15, 60, null],
      ],
    },
    {
      'id': 'prog_531_ohp',
      'name': '5/3/1 • Press Day',
      'description': 'Wendler 5/3/1 overhead press day.',
      'scheduledDays': 'Thursday',
      'exercises': [
        ['ex_overhead_press', 3, 5, 180, 'Main 5/3/1 sets — last set AMRAP.'],
        ['ex_overhead_press', 5, 10, 90, 'Boring But Big: 5×10 @ 50% TM'],
        ['ex_pullup', 5, 8, 90, null],
        ['ex_face_pull', 3, 15, 60, null],
      ],
    },
    {
      'id': 'prog_531_deadlift',
      'name': '5/3/1 • Deadlift Day',
      'description': 'Wendler 5/3/1 deadlift day.',
      'scheduledDays': 'Friday',
      'exercises': [
        ['ex_deadlift', 3, 5, 210, 'Main 5/3/1 sets — last set AMRAP.'],
        ['ex_deadlift', 5, 10, 120, 'Boring But Big: 5×10 @ 50% TM'],
        ['ex_hanging_leg_raise', 5, 12, 60, null],
      ],
    },
  ];
}
