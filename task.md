# ✅ IQBrave Full Upgrade — Execution Checklist
> Phases 6–13 | Backend (Laravel) + Frontend (Flutter)

---

## 📦 PHASE 6 — Mastery-Based Learning Engine

### Backend (Laravel)
- [ ] Migration: add `mastery_score`, `correct_streak`, `attempt_count`, `mastered_at` to `student_topic_progress`
- [ ] Update `StudentTopicProgress::recordAttempt()` — calculate mastery_score & correct_streak
- [ ] Update `GamificationController@attemptMicroTopic` — return mastery_score in response
- [ ] New API: `GET /v1/student/mastery-summary` — returns mastery per node
- [ ] Node unlock rule update: require `mastery_score >= 80` to unlock next node
- [ ] Update `LearningPathController@getPath` — include mastery_score per node

### Frontend (Flutter)
- [ ] Update `NodeBubble` widget — show score ring color (🔴🟡🟢) based on mastery
- [ ] `MasteryScoreRing` widget — animated ring around node
- [ ] Quiz screen: show "You've mastered this! 🏆" vs "Keep practicing 💪" result
- [ ] Dashboard: mastery progress bar per module (% of nodes mastered)

---

## 📦 PHASE 7A — Achievement Badge System

### Backend (Laravel)
- [ ] Migration: create `student_badges` table (`user_id`, `badge_key`, `badge_name`, `earned_at`)
- [ ] Model: `StudentBadge` with `awardBadge()` static method
- [ ] `BadgeEngine` service — checks all badge conditions after each attempt
- [ ] Badge conditions: First Step, On Fire (3-day streak), Perfect (5 nodes 100%), Speed Run (<2min), Scholar (50 nodes), Bot Whisperer (IQ-Bot 10x), Master (full module)
- [ ] Hook `BadgeEngine::check()` into `GamificationController@attemptMicroTopic`
- [ ] New API: `GET /v1/student/badges` — returns earned badges with timestamps
- [ ] Update `GamificationController` attempt response — include `new_badge` if earned

### Frontend (Flutter)
- [ ] `BadgesProvider` — fetch from `/v1/student/badges`
- [ ] `BadgeGrid` widget — trophy shelf on profile screen
- [ ] `BadgeUnlockPopup` — full-screen celebration overlay when new badge earned
- [ ] Dashboard section: "🎖️ Recent Badge" teaser card

---

## 📦 PHASE 7B — Level System Upgrade

### Backend (Laravel)
- [ ] `GamificationEngine`: update `getLevel()` with full 7-level XP thresholds
- [ ] Add level perks logic: extra heart at level 2, streak shield unlock at level 3
- [ ] API `GET /v1/gamification/status` — include `level_title`, `next_level_xp`, `xp_to_next`

### Frontend (Flutter)
- [ ] `GamificationStatsWidget` update — show level title (Explorer, Scholar, etc.)
- [ ] XP progress bar shows % to next level (not just current XP)
- [ ] `LevelUpCelebration` widget — confetti + title reveal when leveling up

---

## 📦 PHASE 7C — Streak Shield

### Backend (Laravel)
- [ ] Migration: add `streak_shield_active` (bool) + `streak_shield_used_at` to `gamification_stats`
- [ ] `GamificationEngine::checkStreak()` — if missed day AND shield active → protect streak, deactivate shield
- [ ] Shield earned at 7-day streak: `GamificationEngine::awardStreakShield()`
- [ ] API: include `streak_shield_active` in `/v1/gamification/status` response

### Frontend (Flutter)
- [ ] Dashboard: 🛡️ shield badge next to streak counter
- [ ] Tooltip: "Shield protects 1 missed day"
- [ ] Animation: shield breaks when used (one-time)

---

## 📦 PHASE 7D — Daily Goal System

### Backend (Laravel)
- [ ] Migration: add `daily_goal`, `daily_xp_today`, `goal_last_reset` to `gamification_stats`
- [ ] `GamificationEngine::updateDailyXP()` — add XP each attempt, reset at midnight
- [ ] API: include `daily_goal`, `daily_xp_today`, `daily_goal_xp_target` in status
- [ ] `POST /v1/student/set-goal` — save selected goal

### Frontend (Flutter)
- [ ] `DailyGoalSelector` widget — Easy/Medium/Hard picker
- [ ] Dashboard: daily goal progress bar with animated fill
- [ ] Goal complete: 🎉 bonus XP animation
- [ ] Goal ring widget beside streak counter

---

## 📦 PHASE 8 — Adaptive AI Learning Path

### Backend (Laravel)
- [ ] `AdaptiveDifficultyEngine` service class
- [ ] `GET /v1/micro-topics/{id}/hint` — Gemini generates contextual hint (-5 XP)
- [ ] When `fail_count >= 3`: include simplified explanation in getMicroTopic response
- [ ] When `correct_streak >= 5`: include `challenge_unlocked: true` + bonus question
- [ ] Add `difficulty_level` to `micro_topics` (beginner/standard/challenge)

### Frontend (Flutter)
- [ ] Quiz screen: "💡 Get a Hint (-5 XP)" button (after 1st wrong answer)
- [ ] `IQBotSheet` auto-trigger when `fail_count >= 3`
- [ ] "🔥 Challenge Unlocked!" banner on 5-correct streak
- [ ] Challenge question: gold border + bonus XP indicator

---

## 📦 PHASE 9 — Rich Lesson Content Flow

### Backend (Laravel)
- [ ] Add `concept_cards` JSON column to `micro_topics`
- [ ] Update M01 seeder: add 2-3 concept cards per node
- [ ] `getMicroTopic` API — include `concept_cards` in response
- [ ] Update seeder: 3 questions per node (currently 1)

### Frontend (Flutter)
- [ ] `ConceptCardScreen` — swipeable cards before quiz
- [ ] `LessonFlowController` — Cards → Video → IQ-Check → Quiz sequence
- [ ] `IQCheckWidget` — comprehension check before quiz
- [ ] `QuizResultScreen` — score ring + XP popup + badge check + share
- [ ] Quiz pagination: 3 questions per node
- [ ] `ShareProgressButton` — share score card to social

---

## 📦 PHASE 10 — Student Profile & Heatmap

### Backend (Laravel)
- [ ] `GET /v1/student/profile` — full stats: XP, level, streak, badges, mastery%
- [ ] `GET /v1/student/activity-heatmap` — daily XP for last 52 weeks
- [ ] Migration: create `daily_xp_logs` table (`user_id`, `date`, `xp_earned`)
- [ ] Log XP daily in `GamificationEngine::awardXP()`

### Frontend (Flutter)
- [ ] `ProfileScreen` — full dark-themed profile page
- [ ] `ActivityHeatmapWidget` — GitHub-style calendar
- [ ] `BadgeShelf` — horizontal badge scroll
- [ ] `SkillTreeWidget` — module competency visual
- [ ] Profile tab in bottom navigation
- [ ] Edit profile: name, avatar upload

---

## 📦 PHASE 11 — Push Notifications

### Backend (Laravel)
- [ ] Add `fcm_token` column to `users` table (migration)
- [ ] `POST /v1/student/fcm-token` — save device token
- [ ] `DailyReminderJob` — 7pm streak status check
- [ ] `StreakAtRiskJob` — 9pm users close to losing streak
- [ ] `SpacedRepetitionReminderJob` — 9am review reminder
- [ ] `BadgeNotification` — immediate push on badge unlock
- [ ] Register jobs in `app/Console/Kernel.php`
- [ ] Install + configure Firebase Admin SDK

### Frontend (Flutter)
- [ ] Add `firebase_messaging` + `flutter_local_notifications` to pubspec
- [ ] `NotificationService` class — init, permission, foreground/background handlers
- [ ] Send FCM token to backend on login
- [ ] Handle notification tap → deep navigate to correct screen
- [ ] Update `AndroidManifest.xml` + `Info.plist` for notification permissions

---

## 📦 PHASE 12 — NVQ Certificate & Portfolio

### Backend (Laravel)
- [ ] Install `barryvdh/laravel-dompdf`
- [ ] `CertificateController@generate` — check eligibility (mastery ≥ 70% all nodes)
- [ ] Certificate HTML template with student name, module, date, QR code
- [ ] `GET /verify/{code}` — public verification route
- [ ] `PortfolioController@index` — list all practical submissions
- [ ] Add `is_portfolio_public` to practical submissions

### Frontend (Flutter)
- [ ] `CertificateScreen` — preview + download/share button
- [ ] Share as image integration
- [ ] `PortfolioScreen` — practical submissions grid
- [ ] Module complete screen: "🎓 Certificate Ready!" CTA button
- [ ] `SkillPassport` widget — certified competencies list

---

## 📦 PHASE 13 — Teacher Dashboard (Web)

### Backend (Laravel)
- [ ] `TeacherDashboardController` — class overview aggregation
- [ ] `GET /teacher/class-overview` — students table with progress/streak/weak nodes
- [ ] `GET /teacher/alerts` — inactive/struggling/completed alerts
- [ ] `GET /teacher/node-analytics` — failure rate per node
- [ ] Seed teacher account: `teacher@iqbrave.com` / `teacher123`
- [ ] Teacher role middleware

### Frontend (Web)
- [ ] `teacher/dashboard.blade.php` — dark themed responsive layout
- [ ] Student table with color coding (green/yellow/red)
- [ ] Alerts panel — struggling + inactive students
- [ ] Node failure heatmap chart
- [ ] Individual student detail view
- [ ] Export CSV/PDF report button

---

## 🔧 Infrastructure

- [ ] Flutter: add all new packages to `pubspec.yaml`
- [ ] Flutter: update `AndroidManifest.xml` (notification permission)
- [ ] Backend: rate limiting on `/v1/iqbot/explain` (max 10/hour per user)
- [ ] Backend: comprehensive API error middleware
- [ ] Backend: Feature tests for BadgeEngine + MasteryEngine
- [ ] Deploy: update production `.env` with Firebase + Gemini keys

---

## 📊 Weekly Execution Plan

| Week | Phases | Key Deliverable |
|---|---|---|
| Week 1 | Phase 9 + Phase 6 | Students actually learn each node |
| Week 2 | Phase 7A + 7B + Profile | Badges + levels + profile visible |
| Week 3 | Phase 7C + 7D + Phase 11 | Streak shield + daily goal + notifications |
| Week 4 | Phase 8 + Phase 12 | Adaptive AI + certificate generation |
| Week 5 | Phase 13 + Testing | Teacher dashboard + full QA |

---

**Total: ~88 subtasks | Estimated: 5 weeks**
