# 🎓 IQBrave — Full Autonomous Self-Learning Platform Upgrade Plan
### Research-Backed Roadmap to Make Students *Feel* Like They're Actually Learning

---

## 🧠 The Core Problem We're Solving

> **"Student opens app → does a quiz → closes app → forgets everything tomorrow."**

World-class learning apps (Duolingo, Khan Academy, Brilliant.org) solve this through a **3-pillar architecture**:

1. **Hook** — make the student *want* to come back daily
2. **Learn** — make them *actually* understand (not just memorize)
3. **Retain** — make knowledge *stick* long-term through science

Current IQBrave has the foundation. This plan upgrades it to a **true learning machine**.

---

## 🔬 Science Behind This Plan

### Self-Determination Theory (SDT)
Students intrinsically learn when they feel:
- **Autonomy** — "I choose my own path"
- **Competence** — "I'm getting better"
- **Relatedness** — "I belong to a community"

### Bloom's Taxonomy (Applied)
| Level | Action | IQBrave Feature |
|---|---|---|
| 1. Remember | Recall facts | MCQ Quiz |
| 2. Understand | Explain concepts | AI Bot explanation |
| 3. Apply | Use in context | Practical tasks |
| 4. Analyze | Break down problems | Case study questions (NEW) |
| 5. Evaluate | Judge solutions | Peer review (NEW) |
| 6. Create | Build something | Final project (NEW) |

### The Duolingo Engagement Loop (Adapted for IQBrave)
```
Notification → Open App → Quick Win → Celebration → Save Progress → Next Challenge
     ↑                                                                      |
     └──────────────────────────────────────────────────────────────────────┘
```

---

## 📋 PHASE 6 — Mastery-Based Learning Engine
**Goal:** Student cannot proceed until they *truly* understand

### What to Build:
- **Mastery Score per Node** (0-100%) — 3 correct in a row = mastered ✅
- **"Needs Practice" alert** — if score drops below 70% after 24hrs → auto-flag
- **Node unlock logic upgrade**: 
  - Currently: complete → unlock next
  - NEW: score ≥ 80% → unlock, score < 80% → locked with hint

### Backend (Laravel):
```
student_topic_progress table:
+ mastery_score (0-100)
+ correct_streak (consecutive correct answers)  
+ attempt_count (total tries)
+ mastered_at (timestamp when mastery achieved)
```

### Flutter UI:
- **Score ring** on each node bubble (green glow when mastered)
- **"Keep practicing"** vs **"You've mastered this!"** celebration
- Node colors: 🔴 <50% | 🟡 50-79% | 🟢 80%+ mastered

---

## 📋 PHASE 7 — Deep Gamification System
**Goal:** Student *wants* to open app every day

### 7A: Achievement Badge System
| Badge | Trigger | Visual |
|---|---|---|
| 🌱 First Step | Complete Node 1 | Green sprout |
| 🔥 On Fire | 3-day streak | Flame animation |
| 💎 Perfect | 5 nodes 100% | Diamond glow |
| ⚡ Speed Run | Complete node <2 min | Lightning |
| 🧠 Scholar | 50 nodes done | Brain crown |
| 🤖 Bot Whisperer | Used IQ-Bot 10x | Robot badge |
| 🏆 Master | Complete full module | Gold trophy |

**Backend table:** `student_badges (user_id, badge_key, earned_at)`

### 7B: Level System Upgrade
| Level | XP Required | Title | Perk |
|---|---|---|---|
| 1 | 0 | Beginner | - |
| 2 | 100 | Explorer | +1 Heart |
| 3 | 300 | Learner | Streak shield |
| 4 | 600 | Scholar | Speed boost |
| 5 | 1000 | Expert | IQ-Bot priority |
| 6 | 2000 | Master | Certificate unlock |
| 7 | 5000 | IQ-Champion | 🏆 Hall of Fame |

### 7C: Streak Shield (Duolingo-inspired forgiveness)
- **Streak Shield**: Auto-activates once if student misses a day
- Earned: when streak reaches 7 days
- Shows on dashboard: "🛡️ Shield Active — 1 skip protected"

### 7D: Daily Goals
- Student sets goal: Easy (1 node) | Medium (3 nodes) | Hard (5 nodes)
- Progress bar fills through the day
- 🎉 animation + bonus XP when daily goal hit

---

## 📋 PHASE 8 — Adaptive AI Learning Path
**Goal:** App automatically *gets easier or harder* based on performance

### Smart Difficulty Engine:
```
if student.fail_count >= 3 on same node:
    → Show simpler explanation (IQ-Bot auto-triggers)
    → Break question into 2 sub-questions
    → Add hint button (costs 5 XP)

if student.correct_streak >= 5 in a row:
    → Unlock "Challenge Mode" bonus question
    → Award 2x XP for next node
    → Show "You're crushing it! 🔥" celebration
```

### AI-Generated Hints (Gemini):
- Not just wrong answer explanation — **step-by-step hints**
- "Stuck? IQ-Bot can give you a hint (-5 XP)"
- Gemini generates contextual hint without giving away answer

---

## 📋 PHASE 9 — Rich Lesson Content System
**Goal:** Every node feels like a *complete mini-lesson*, not just a quiz

### Current State:
```
Node → Quick MCQ → Done
```

### Target State (Duolingo-style flow):
```
Node → Content Card → Video → IQ-Check → Mini-Quiz (3Q) → 
Celebration / IQ-Bot Explain → Next Node
```

### Flutter Screen Flow:
1. **Lesson Card** (swipeable) — key concept in visual card format
2. **Video** (existing YouTube integration)
3. **IQ-Check** — "Before the quiz, do you understand? ✅ / 🤔"
4. **Mini-Quiz** (3 questions, not just 1)
5. **Result Screen** with:
   - Score ring animation
   - XP earned popup
   - Badge unlock (if triggered)
   - "Share Progress" button

### Content Cards Design (NEW):
Each node gets visual **concept cards**:
```
┌─────────────────────────────┐
│  💡 Key Concept             │
│                             │
│  "UPS stands for            │
│  Uninterruptible Power      │
│  Supply. It protects your   │
│  computer from sudden       │
│  power loss."              │
│                             │
│  [  Tap to continue →  ]   │
└─────────────────────────────┘
```

---

## 📋 PHASE 10 — Student Profile & Progress Showcase
**Goal:** Student *sees* their growth visually — feels proud

### Profile Screen:
```
┌────────────────────────────────────┐
│  👤 Kamal Perera                   │
│  Level 4 Scholar ⚡                │
│  M01 — 78% complete               │
│                                    │
│  📊 Stats:                         │
│  ├─ 247 XP earned                 │
│  ├─ 🔥 12-day streak              │
│  ├─ ❤️ 5/5 hearts                 │
│  └─ 🏆 8 badges earned            │
│                                    │
│  🎖️ Badges:                       │
│  🌱 💎 🔥 ⚡ ... (grid view)      │
│                                    │
│  📈 Weekly Activity:               │
│  [Heatmap calendar]               │
└────────────────────────────────────┘
```

### Weekly Activity Heatmap:
- GitHub-style contribution graph
- Each day = color intensity based on XP earned
- Great visual motivator: "I don't want gaps!"

---

## 📋 PHASE 11 — Push Notifications (Habit Loop Trigger)
**Goal:** Student *remembers* to study without teacher reminding

### Notification Strategy:
| Trigger | Message | Time |
|---|---|---|
| Daily reminder | "🔥 Day 12 streak! Keep it going Kamal!" | 7:00 PM |
| Streak at risk | "😱 Your streak ends in 3 hours!" | 9:00 PM |
| Spaced review due | "📚 3 topics need revision today" | 9:00 AM |
| New content | "🆕 2 new nodes unlocked in M01!" | Morning |
| Achievement | "🏆 You just earned 'Scholar' badge!" | Immediate |
| Inactivity (3 days) | "We miss you! 😔 IQ-Bot is waiting..." | 6:00 PM |

### Tech Stack: **Firebase Cloud Messaging (FCM)**
- `flutter_local_notifications` + `firebase_messaging` packages
- Backend: scheduled Laravel jobs for streak/review reminders

---

## 📋 PHASE 12 — NVQ Certificate & Digital Portfolio
**Goal:** Real-world outcome that makes learning *feel worthwhile*

### Auto-Generated Certificate:
When student completes module with ≥70% mastery:
- PDF certificate with name, module, date, QR code
- Shareable link: `iqbrave.com/certificate/abc123`
- Verified by QR scan (employer can scan to verify)

### Digital Portfolio (Practical Evidence):
- All practical ZIP uploads → organized portfolio
- Student can share portfolio URL with employer
- Teacher can endorse portfolio items

### "Learning Passport":
Visual skill tree showing all mastered competencies:
```
✅ Computer Hardware
✅ File Management  
✅ Word Processing
🔵 Spreadsheets (in progress)
🔒 Databases (locked)
```

---

## 📋 PHASE 13 — Teacher/Admin Dashboard (Web)
**Goal:** Teacher *sees everything* without intervening

### Real-time Class Overview:
| Student | Progress | Streak | Weak Areas | Last Active |
|---|---|---|---|---|
| Kamal | 78% ✅ | 🔥12 | Sorting | 2hr ago |
| Nimal | 34% ⚠️ | 💀0 | Files, UPS | 3 days ago |
| Sitha | 92% 🏆 | 🔥25 | None | 1hr ago |

### Auto-Alerts for Teacher:
- "⚠️ Nimal hasn't logged in for 3 days"
- "💪 Sitha completed the module — ready for next!"
- "🔁 5 students struggling with Node 7 (power sequence)"

---

## 🗓️ Implementation Priority

```
Priority 1 (Immediate Impact):
├── Phase 9 — Rich Lesson Flow (students learn better)
└── Phase 11 — Push Notifications (students come back)

Priority 2 (Retention):
├── Phase 7 — Deep Gamification (badges + levels)
└── Phase 6 — Mastery Engine (actually learn!)

Priority 3 (Showcase):
├── Phase 10 — Student Profile
└── Phase 12 — Certificate + Portfolio

Priority 4 (Scale):
├── Phase 8 — Adaptive AI Path
└── Phase 13 — Teacher Dashboard
```

---

## 💡 The "Feel Like Learning" Secret

The reason students don't feel like they're learning:
1. **No emotional reward** after completing — just a tick ✅
2. **No visual proof** of growth over time
3. **No consequence** for forgetting to study
4. **Content feels disconnected** — quiz without understanding

**IQBrave's answer:**
- Every correct answer = 🎉 dopamine hit (animation + XP popup)
- Every wrong answer = 🤖 AI explains → understanding, not punishment
- Dashboard shows *growth* not just status
- Notification makes student *feel missed* when absent
- Certificate at end gives *real-world meaning* to every node

> **Goal: Student closes the app thinking "I understood something today" — not just "I finished a quiz."**

---

*Plan prepared: April 2026 | Based on Duolingo, Khan Academy & SDT research*
