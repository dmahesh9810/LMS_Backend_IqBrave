# 🎮 Gamification & Micro-Tracking Plan (Duolingo Style)

This implementation plan outlines the structural steps needed to satisfy two core objectives:
1. **Teacher's Perspective (Knowledge Monitoring):** Ensure students actually learn at a granular level using the recently introduced `student_concept_masteries` and `micro_topics` migrations.
2. **Student's Perspective (Duolingo Feeling):** Introduce an addictive, gamified learning path in the Flutter mobile app involving XP, Streaks, Hearts (Lives), and a visual roadmap.

## User Review Required

> [!IMPORTANT]
> To achieve the Duolingo feeling, we need to restructure how courses are displayed in the Mobile App. Instead of traditional "boring" lists (Module 1 -> Lesson 1), the UI will become a **Winding Roadmap**, and lessons must be broken down into "bite-sized" interactive quizzes rather than long PDFs. Does this shift in curriculum delivery align with your vision?

---

## Proposed Changes

### Layer 1: Gamification Database (Laravel Backend)

To power the gamified math we need new tables specifically tying your new concept mastery into XP and streaks.

#### [NEW] `database/migrations/2026_04_15_000000_create_student_gamification_stats_table.php`
- **Table Definition**: Tracks single-row-per-student gamification states.
  - `user_id` (Foreign Key)
  - `total_xp` (Integer)
  - `current_streak` (Integer - days played consecutively)
  - `longest_streak` (Integer)
  - `hearts` (Integer - defaults to 5, decreases on wrong quiz attempts)
  - `last_activity_date` (Date - to calculate streak breaks)

#### [NEW] `app/Services/GamificationEngine.php`
- Core service to handle the logic:
  - `awardXP($studentId, $amount)`
  - `updateStreak($studentId)`
  - `deductHeart($studentId)`
  - Re-charging hearts over time (e.g., 1 heart every 4 hours).

---

### Layer 2: Gamification Controllers & API (Laravel Backend)

The Flutter app needs an API to fetch the gamification status and the visual learning path shape.

#### [NEW] `routes/api.php`
- Need to expose API endpoints since the Flutter app relies on them:
  - `GET /api/v1/learning-path` (Returns the course mapped as a sequence of nodes for the winding path)
  - `GET /api/v1/gamification/status` (Returns XP, Hearts, Streak)
  - `POST /api/v1/micro-topics/{id}/attempt` (Registers a quiz attempt, awards XP or deducts Heart, and updates the `student_concept_masteries` table for the teacher)

#### [NEW] `app/Http/Controllers/Api/LearningPathController.php`
- This will aggregate `micro_topics` and `lessons` into a sequential "map" format so the mobile app knows which nodes are unlocked and locked.

---

### Layer 3: Flutter Mobile UI (The Duolingo Experience)

This is where the user will feel the magic. We will revamp the `iqbrave-lms-mobile` app completely to move away from standard LMS views.

#### [NEW] Visual Learning Path (Flutter `CustomPainter` or Staggered Map)
- **File**: `lib/views/courses/widgets/learning_path_map.dart`
- **Description**: A widget that draws a winding vertical path (like the image you showed).
- Node types: 
  - 🌟 Crown (Completed with high mastery)
  - 🟢 Active Green Circle (Next available)
  - 🔒 Greyed Out (Locked)

#### [NEW] Top Gamification AppBar (Flutter)
- **File**: `lib/views/main/widgets/gamification_app_bar.dart`
- **Description**: The top bar mimicking the screenshot:
  - 🇺🇸 Flag (Course Indicator)
  - 🔥 Streak Counter
  - 💎 Gems / XP Tracker
  - ❤️ Hearts Tracker

#### [MODIFY] `lib/providers/` (State Management)
- **File**: `lib/providers/knowledge_provider.dart`
- **Description**: Will track the current `Hearts`, `XP`, and `Streak` locally so the UI reacts instantly (with animations) when an answer is right or wrong, syncing to the Laravel API seamlessly in the background.

#### [NEW] Celebratory Animations (Flutter)
- **Dependency**: Add `lottie` package to `pubspec.yaml`
- **Description**: When a student finishes a micro-topic, pop a full-screen Lottie animation celebrating the XP gain and showing their Mastery Level jumping from e.g., 20% -> 60%, satisfying the ultimate loop.

---

## Proposed Solutions for Design Choices

> [!TIP]
> Based on your goal to create an addictive, Duolingo-style experience alongside strict teacher monitoring, here is my recommended approach for the architecture:
> 
> **1. The Nodes (Rawum) MUST be Micro-Topics:** 
> We will connect the nodes on the roadmap to `micro_topics` instead of full lessons. A full lesson is too boring for a mobile game UX. By using 3-5 minute micro-quizzes, students get frequent "dopamine hits" (XP gains), and the teacher gets highly granular data on exact `student_concept_masteries`.
> 
> **2. "Practice to Earn" Hearts System:** 
> When a student's hearts drop to 0, they are locked out of *new* topics. However, instead of making them wait, we introduce a "Practice to Earn" feature. They must replay old, already-mastered Micro-Topics to earn 1 Heart back per review. This prevents frustration while secretly forcing them to revise and solidify old knowledge!

## Verification Plan

### Backend Verification
- Ensure `GamificationEngine` correctly increments streaks and resets them if a day is skipped.
- Ensure `micro_topics` attempt API properly calculates mastery percentage and affects XP/Hearts independently.

### Frontend Verification
- Run Flutter on an emulator.
- Visually verify the Learning Path draws a connected, winding line between lesson nodes.
- Confirm that making a mistake in a lesson immediately deducts a heart in the top AppBar without requiring a full page reload (Riverpod reactive state).
