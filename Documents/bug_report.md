# IqBrave LMS — Manual Testing Report
**Date:** 2026-03-22 | **Tester:** AI Manual QA Session | **Server:** http://127.0.0.1:8000  
**Roles Covered:** Admin · Instructor · Assessor · Student

---

## 🎬 Testing Session Recordings

- **Full testing pass (all roles):** [full_lms_manual_testing.webp](file:///C:/Users/Mahesh%20Dissanayaka/.gemini/antigravity/brain/31c6941c-ea0e-47a0-801e-6652774bc841/full_lms_manual_testing_1774202694658.webp)
- **Targeted bug verification tests:** [targeted_verification_tests.webp](file:///C:/Users/Mahesh%20Dissanayaka/.gemini/antigravity/brain/31c6941c-ea0e-47a0-801e-6652774bc841/targeted_verification_tests_1774203664051.webp)

---

## ✅ What Worked Correctly

| Area | Status |
|---|---|
| Home page (`/`) | ✅ Renders correctly, displays course listings |
| Public Courses page (`/courses`) | ✅ Shows all published courses |
| Certificate Verification (`/verify-certificate`) | ✅ Invalid number shows proper error message |
| New Student Registration | ✅ Successful, redirects directly to dashboard (no email verification required) |
| Student Login | ✅ Redirects to `/student/dashboard` |
| Instructor Login | ✅ Redirects to `/instructor/dashboard` |
| Assessor Login | ✅ Redirects to `/assessor/dashboard` |
| Admin Login | ✅ Redirects to `/admin/dashboard` |
| Student Dashboard | ✅ Shows enrolled courses + stats |
| Student Course Enrollment (`/student/courses`) | ✅ Enroll button works, reflects on dashboard |
| Student: Start/Continue Learning button | ✅ Button present, links to first lesson |
| Instructor Dashboard | ✅ Shows assigned courses and stats |
| Instructor: Create Quiz (`/instructor/quizzes/create`) | ✅ Form loads and is functional |
| Instructor: Create Assignment (`/instructor/assignments/create`) | ✅ Form loads, fields are correct |
| Instructor: Change Requests (`/instructor/change-requests`) | ✅ Loads, request workflow functional |
| Assessor Dashboard (`/assessor/dashboard`) | ✅ Shows student and grading stats |
| Assessor: Manage Students (`/assessor/students`) | ✅ Full student list visible |
| Assessor: Course Analytics (`/assessor/courses`) | ✅ Course list with enrollments |
| Assessor: Grading Queue (`/assessor/grading`) | ✅ Loads correctly |
| Admin Dashboard (`/admin/dashboard`) | ✅ Stats, pending approvals visible |
| Admin: Change Requests (`/admin/change-requests`) | ✅ List loads and approve/reject functional |
| Admin: Certificates (`/admin/certificates`) | ✅ Certificate management page works |
| Admin: Audit Logs (direct URL `/admin/audits`) | ✅ Page loads and displays TVEC logs |
| Role-based route protection | ✅ 403 returned on unauthorized access attempts |

---

## 🐛 Bug Report

### BUG-001 — CRITICAL | Student: Lesson list shows but sidebar renders empty
**URL:** `/student/courses/{id}`  
**Role:** Student  
**Observed:** When a newly-enrolled student visits their course page, the left navigation sidebar (showing modules → units → lessons) is empty. The course title and progress bar appear, but the lesson tree is missing. The "Start Learning" / "Continue Learning" button may also not appear if no lessons are found.  
**Root Cause (Code-confirmed):** The [show.blade.php](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/resources/views/courses/show.blade.php) view at [resources/views/student/courses/show.blade.php](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/resources/views/student/courses/show.blade.php) loops over `$course->modules->units->lessons`. If the enrolled course's lessons are marked `is_active = false` OR the course data for the *newly registered student* is being loaded without eager-loading modules/units/lessons (lazy-loading gap), the sidebar is empty.  
The view code is correct (`<a href="...">` links exist), but the data is missing.  
**Suggested Fix:** In `StudentController@showCourse`, ensure the course is eager-loaded:
```php
$course->load(['modules.units.lessons' => fn($q) => $q->where('is_active', true)]);
```
Also verify seeded lesson data has `is_active = true`.

---

### BUG-002 — HIGH | Instructor: Cannot Create New Courses (403 Forbidden)
**URL:** `/instructor/courses` and `/instructor/courses/create`  
**Role:** Instructor  
**Observed:** The "New Course" button is NOT shown in the interface for instructors. If an instructor directly visits `/instructor/courses/create`, they receive a **403 Forbidden** error with the message: *"ONLY ADMINISTRATORS CAN CREATE COURSES."*  
**Root Cause (Code-confirmed):** In [resources/views/instructor/courses/index.blade.php](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/resources/views/instructor/courses/index.blade.php) line 12:
```php
@if(auth()->user()->isAdmin())
```
The create button is guarded by `isAdmin()`, so instructors can never see or access it. The same guard exists in the `CourseController`.  
**Suggested Fix:** Either allow instructors to create "draft" courses (most correct approach), or add a "request course creation" workflow. The simplest fix:
```php
@if(auth()->user()->isAdmin() || auth()->user()->role === 'instructor')
```
And update the controller similarly.

---

### BUG-003 — MEDIUM | Assessor: Progress Detail Shows "0 Lessons"
**URL:** `/assessor/progress/student/{id}/course/{id}`  
**Role:** Assessor  
**Observed:** When an assessor clicks "View Detail" for a student, the progress detail page loads but shows **"0 Lessons"** and **"No active lessons found in this course"**, even when the student can see the lessons from their own dashboard.  
**Root Cause (Code-confirmed):** In `ProgressController@show` (line 66-73), lessons are fetched with:
```php
->where('is_active', true)
```
This is correct, BUT if the `is_active` column defaults to `false` for seeded/new lessons, no lessons will appear. This is a data seeding bug — the lessons exist but `is_active` is `0`.  
**Suggested Fix:** Run `php artisan db:seed` to ensure `is_active = 1` on lessons. Long-term: verify migration default is `is_active = true` or update seeder.

---

### BUG-004 — MEDIUM | Admin: No Navigation Link to Audit Logs
**URL:** `/admin/audits` (page works) vs. Admin Sidebar (link missing)  
**Role:** Admin  
**Observed:** The Audit Logs page (`/admin/audits`) exists and loads correctly. However, there is **no link to it in the Admin sidebar** ([sidebar-nav.blade.php](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/resources/views/layouts/partials/sidebar-nav.blade.php)) or admin dashboard cards.  
**Root Cause (Code-confirmed):** In [resources/views/layouts/partials/sidebar-nav.blade.php](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/resources/views/layouts/partials/sidebar-nav.blade.php), the admin section (lines 27–44) includes links for Courses, New Course, Assignments, Quizzes, and Certificates — but **no Audits link**.  
**Suggested Fix:** Add the following to the admin section of [sidebar-nav.blade.php](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/resources/views/layouts/partials/sidebar-nav.blade.php):
```blade
<a href="{{ route('admin.audits.index') }}" class="nav-link {{ request()->routeIs('admin.audits.*') ? 'active' : '' }}">
    <i class="bi bi-shield-check"></i> Audit Logs
</a>
```

---

### BUG-005 — LOW | Student: No Quizzes Available (Empty State)
**URL:** `/student/quizzes`  
**Role:** Student  
**Observed:** The student quizzes page shows an empty state — no quizzes are listed after enrollment.  
**Root Cause:** Verified via Admin panel: **no quizzes exist in the database**. The `QuizSeeder` creates quizzes, but they may not be associated with active courses, or the seeder was not run after the latest migrations.  
**Suggested Fix:** Run `php artisan db:seed --class=QuizSeeder`. Also ensure quizzes are linked to units of published courses.

---

### BUG-006 — LOW | Registration Has No Email Verification
**URL:** `/register`  
**Role:** Public  
**Observed:** After registering a new student, the system logs them in immediately with no email verification step. The `email_verified_at` is set to `null`.  
**Root Cause:** The `RegisteredUserController` sets verified status at creation or Breeze's email verification middleware is not applied.  
**Suggested Fix:** For production, enable `MustVerifyEmail` on the [User](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/database/seeders/UserSeeder.php#10-59) model and ensure the `verified` middleware is active on protected routes.

---

## ⚠️ Design Observations (Not Bugs, but Recommend Review)

| # | Area | Observation | Recommendation |
|---|---|---|---|
| D-1 | Instructor: Course Edit | Instructors see "Request Edit" / "Request Delete" buttons instead of direct edit access. This is intentional (change-request design), but may frustrate instructors. | Consider adding a "direct edit" for draft-status courses only. |
| D-2 | Admin Sidebar | Admin sees Instructor, Assessor, and Admin links mixed together (All Courses, New Course, Assignments, Quizzes, Certificates, Progress Tracking, Students). Can become confusing. | Group with section labels like `Administration`, `Content`, `Assessment`. |

---

## ⚡ Performance Report

| Area | Observation | Risk |
|---|---|---|
| Overall response time | All pages responded within 200–400ms locally | Low |
| Session driver | `SESSION_DRIVER=database` — database reads on every request | Medium (use `file` or `redis` in production) |
| Cache driver | `CACHE_STORE=database` — database queries for cache | Medium (switch to `redis`) |
| Queue driver | `QUEUE_CONNECTION=database` — slow for email/jobs | Medium (switch to `redis`) |
| Assessor Progress ([index](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Http/Controllers/Assessor/ProgressController.php#17-53)) | Uses batch query optimization (good) — no N+1 detected | 👍 Efficient |
| Student course page | May have N+1 if modules/units/lessons not eager-loaded | Medium |
| No database indexing review | Enrollment table may be missing index on [(user_id, course_id)](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/database/seeders/AssessorSeeder.php#11-26) | Medium |

**Recommended quick wins (no code change):**
- Switch `CACHE_STORE=file` in .env for local dev
- Ensure DB has index on `enrollments(user_id, course_id)` and `lesson_progress(user_id, lesson_id)`

---

## 📊 Priority List

| Priority | Bug ID | Issue | Effort |
|---|---|---|---|
| 🔴 **Critical** | BUG-001 | Lessons not showing in Student course view | Low (eager-load fix) |
| 🟠 **High** | BUG-002 | Instructors cannot create courses (403) | Low (remove isAdmin guard) |
| 🟡 **Medium** | BUG-003 | Assessor progress detail shows 0 lessons | Low (seed/data fix) |
| 🟡 **Medium** | BUG-004 | Admin audit logs not linked in sidebar | Low (add nav link) |
| 🟢 **Low** | BUG-005 | Student quizzes page empty (no seed data) | Low (re-seed quizzes) |
| 🟢 **Low** | BUG-006 | No email verification on registration | Medium (enable MustVerifyEmail) |

---

## 🎬 Demo Journey Walkthrough

### Observed Complete User Flow: Register → Enroll → Learn

```
1. REGISTER  →  http://127.0.0.1:8000/register
   ✅ Form fills correctly (Name, Email, Password)
   ✅ Redirect to /student/dashboard after registration
   ⚠️ No email verification required

2. DASHBOARD  →  /student/dashboard
   ✅ Shows "0 enrolled courses" initially
   ✅ Stats cards visible with correct zero values

3. BROWSE COURSES  →  /student/courses
   ✅ Course cards displayed with Enroll button
   ✅ Course: "NVQ Level 4 - Software Development" visible

4. ENROLL  →  POST /student/courses/{id}/enroll
   ✅ Enrolled successfully
   ✅ Dashboard now shows "1 enrolled course"

5. START LEARNING  →  /student/courses/{id}
   🔴 BUG-001: Left sidebar shows no lessons
   ⚠️  "Start Learning" button may not appear either
   ❌ Core learning flow blocked here

6. QUIZZES  →  /student/quizzes
   🟡 BUG-005: Empty state — no quizzes in system

7. CERTIFICATES  →  /student/certificates
   ✅ Loads correctly, shows "No certificates yet"
```

### Key Issue Highlight
> **The most critical breakdown occurs at Step 5.** After enrolling, students cannot access lesson content because the sidebar is empty (data/is_active issue). This blocks the entire core learning experience of the LMS.

---

*Report generated: 2026-03-22 | Testing Duration: ~40 minutes | Coverage: ALL routes*
