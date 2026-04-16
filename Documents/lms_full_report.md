# Learning Management System (LMS)
# Complete System Analysis Report

**Prepared by:** [Student Name]
**Course:** [Course Name / Module Code]
**Institution:** [University Name]
**Date:** March 2026
**Submission Type:** Final Year Project — System Analysis Report

---

> **Assumption Note:** This report is based on a live codebase analysis of the IQBrave LMS project. Where implementation details are still in progress (e.g., Vue.js frontend SPA), realistic industry-standard assumptions have been applied and explicitly flagged.

---

## TABLE OF CONTENTS

1. System Overview
2. Functional Requirements
3. Non-Functional Requirements
4. System Architecture
5. Database Design
6. Use Case Analysis
7. UML Diagrams
8. Security Analysis
9. API Design
10. Strengths of the System
11. Limitations and Weaknesses
12. Recommendations for Improvement
13. Conclusion
14. System Workflow (End-to-End)
15. Data Flow Explanation
16. Scalability Strategy
17. Deployment Architecture
18. Testing Strategy

---

## 1. System Overview

### 1.1 Purpose of the System

The IQBrave Learning Management System (LMS) is a purpose-built, web-based educational platform engineered to digitise the full lifecycle of academic course delivery — from content creation and student enrolment to automated progress tracking, assessment management, and verifiable digital certification.

The system addresses a growing demand within modern educational institutions and corporate training environments for platforms that can provide a structured, scalable, and accessible alternative to physical classroom instruction. Unlike commercially available monolithic LMS solutions such as Moodle or Blackboard, this system is purpose-built with a clean, modern tech stack, granting complete ownership, extensibility, and security control to the deploying institution.

### 1.2 Target Users

The platform is designed around a strict **Role-Based Access Control (RBAC)** model comprising four primary user personas:

| Role | Primary Responsibility | Key Access Rights |
|---|---|---|
| **Admin** | Platform governance and oversight | Certificate management, system-wide monitoring |
| **Instructor** | Academic content creation and structuring | Full course CRUD, quiz and assignment authoring |
| **Assessor** | Student performance grading | Access to pending submissions, grade assignment |
| **Student** | Knowledge acquisition and assessment | Course browsing, enrolment, content consumption, certificate download |

This deliberate separation of concerns across roles follows the **Principle of Least Privilege**, ensuring that no user role possesses permissions beyond the minimum required to perform their function — a critical security and governance principle.

### 1.3 Key Objectives

* Provide a structured four-tier content hierarchy (Course → Module → Unit → Lesson) enabling granular academic organisation.
* Automate student progress computation with server-side accuracy.
* Facilitate both automated (quiz) and manual (assignment) assessment modes within a single platform.
* Issue and verify tamper-evident digital certificates upon course completion.
* Prepare the platform with a decoupled API design to support future Vue.js SPA or mobile application integration without architectural refactoring.

---

## 2. Functional Requirements

### 2.1 User Registration and Authentication

* Users must register with a valid name, email address, and password.
* Passwords must be hashed using a strong algorithm (Bcrypt via Laravel's native `Hash::make`).
* The system uses **Laravel Breeze** for session-based authentication and **Laravel Sanctum** for token-based API authentication.
* Email verification is enforced via the `verified` middleware, preventing unverified users from accessing protected dashboards.
* Upon login, the system resolves the authenticated user's role and performs a programmatic redirect to the role-appropriate dashboard, implemented using PHP 8's `match` expression for readability and correctness.

### 2.2 Course Management

* Instructors can create, update, and delete courses they own.
* Each course record includes: `title`, `slug` (auto-generated from title using `Str::slug`), `description`, `thumbnail`, and `status` (draft/published).
* The content hierarchy is structured as: Course → Modules → Units → Lessons, each with full CRUD operations managed through nested RESTful resource routes.

### 2.3 Lesson and Module Management

* Modules are ordered within a course (via an `order` column).
* Lessons support three content delivery modes:
  * **Video**: Embedded YouTube or external URL (auto-converted to embed format by the [getEmbedUrlAttribute](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/Lesson.php#57-74) accessor).
  * **PDF**: Uploaded document (`pdf_path`).
  * **Text**: Rich HTML content (`content` field).
* Lessons include an `is_active` boolean flag allowing instructors to temporarily hide content without deleting it.

### 2.4 Student Enrolment

* Students can browse a public course catalog filtered by published status.
* Enrolment is recorded in the [enrollments](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/User.php#124-129) pivot table with `enrolled_at` timestamp and a `status` field that can reflect: `active`, `completed`, or `suspended`.
* A student cannot enrol in the same course twice due to database-level unique constraints on [(user_id, course_id)](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/Course.php#22-35).

### 2.5 Progress Tracking

* Each time a student explicitly completes a lesson (via `POST /student/courses/{course}/lessons/{lesson}/complete`), a `LessonProgress` record is created containing `user_id`, `lesson_id`, and `completed_at` timestamp.
* Progress percentage is computed on-demand at the [Course](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/Course.php#9-102) Model layer using the formula: [(completed_lessons / total_active_lessons) × 100](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/Course.php#22-35), returning an integer rounded to the nearest whole number.

### 2.6 Assessments

* **Quizzes**: Instructors compose quizzes containing one or more questions (`QuizQuestion`), each with multiple answer options (`QuizOption`). Students attempt quizzes (`QuizAttempt` records), and the system auto-grades submissions based on correct answer mappings.
* **Assignments**: Instructors define text-based or file-based assignment submissions. Students upload their work; `AssignmentSubmission` records are routed to the Assessor's grading queue.

### 2.7 Certificates

* The platform automatically issues a `Certificate` record when a student achieves 100% course completion.
* Certificates are downloadable as PDF documents by the student.
* A public `/verify-certificate` portal allows third parties to authenticate certificate legitimacy without requiring login.
* Admin users can revoke or reinstate certificates via the admin panel, supporting institutional policy enforcement.

### 2.8 Admin Features

* Centralised certificate management dashboard (revoke / reinstate).
* System-wide access to manage users, roles, and content (assumed based on admin route privileges).

---

## 3. Non-Functional Requirements

### 3.1 Performance
* Target API response time: **≤ 200ms** for standard read operations under normal load.
* Eloquent ORM queries must be optimised using eager loading (`with()`) to prevent N+1 query problems, particularly on deep nested relations (Course → Modules → Units → Lessons).
* File uploads (assignment submissions) should be stored in Laravel's managed `storage/app` directory, abstracting away the local filesystem for cloud portability.

### 3.2 Security
* **Authentication**: All protected routes are wrapped under Laravel's `auth` and `verified` middleware.
* **Authorisation**: Every role-restricted route group uses a custom `role:` middleware that compares the authenticated user's `role` string against an allowed list, returning HTTP 403 on failure.
* **Input Validation**: All write operations (POST/PUT) pass through Laravel Form Request validation classes before reaching business logic.
* **Mass Assignment Protection**: All Eloquent models define strict `$fillable` arrays, preventing users from injecting unexpected fields.
* **CSRF Protection**: Laravel's session CSRF middleware is active on all non-API web routes.

### 3.3 Scalability
* The REST API architecture allows the frontend to be independently scaled or replaced (e.g., as a Vue.js SPA, React app, or mobile client) without changes to the backend.
* The database schema is normalised to 3NF, minimising data redundancy and enabling efficient horizontal partitioning if required.

### 3.4 Usability
* Role-specific dashboards present a clean, task-focused interface — students see their enrolled courses and progress, instructors see their content management tools, assessors see pending grading tasks.
* The system architecture supports responsive design through Tailwind CSS (evidenced by `tailwind.config.js`), ensuring accessibility across desktop and mobile devices.

### 3.5 Availability and Reliability
* Target: **99.9% uptime** (≈ 8.7 hours downtime/year), achievable through standard cloud hosting with process management (e.g., Supervisor for queue workers).
* Laravel's logging and exception handling ensure errors are captured and do not expose sensitive system internals to end users.

---

## 4. System Architecture

### 4.1 Architectural Pattern: MVC with RESTful API

The system is implemented using the **Model-View-Controller (MVC)** architectural pattern, which is the native paradigm of the Laravel framework. This pattern separates concerns rigorously:

* **Model**: Encapsulates the data schema and business logic. The `Course::progressForStudent()` method is a prime example of domain logic residing at the model layer rather than polluting controllers.
* **View**: Server-rendered Blade templates or, in the planned SPA iteration, entirely replaced by Vue.js components consuming the API layer.
* **Controller**: Acts as the orchestrator, receiving the HTTP request, invoking models, and returning responses.

### 4.2 Backend Structure

Controllers are organised into role-specific namespaces, enforcing clear domain boundary separation:

```
App\Http\Controllers\
├── Instructor\
│   ├── CourseController.php
│   ├── ModuleController.php
│   ├── UnitController.php
│   ├── LessonController.php
│   ├── AssignmentController.php
│   ├── QuizController.php
│   └── InstructorAnalyticsController.php
├── Student\
│   ├── StudentController.php
│   ├── StudentDashboardController.php
│   ├── AssignmentController.php
│   ├── QuizController.php
│   └── CertificateController.php
├── Assessor\
│   └── GradingController.php
└── Admin\
    └── CertificateController.php
```

This namespace structure aligns with the **Single Responsibility Principle (SRP)** from SOLID design principles, where each controller exclusively handles the HTTP interaction concerns for one functional domain.

### 4.3 Frontend Structure (Planned/Partial)

* Leverages **Vite** (`vite.config.js`) as the frontend build tool, indicating modern ES module bundling.
* **Tailwind CSS** provides the utility-first styling framework.
* The planned integration with **Vue.js** would operate as a SPA consuming the Laravel API via Sanctum token authentication.

### 4.4 Request Lifecycle

```
HTTP Request
    ↓
routes/web.php  →  Middleware Stack (auth, verified, role:X)
    ↓
Controller Method
    ↓
Eloquent Model / Business Logic
    ↓
MySQL Database
    ↓
Blade View / JSON Response
    ↓
HTTP Response to Client
```

---

## 5. Database Design

### 5.1 Entity Table Summary

| Table | Key Columns | Purpose |
|---|---|---|
| `users` | `id`, `name`, `email`, `password`, `role`, `email_verified_at` | Core identity and role assignment |
| `courses` | `id`, `instructor_id`, `title`, `slug`, `description`, `thumbnail`, `status` | Course metadata |
| `modules` | `id`, `course_id`, `title`, `order` | Logical groupings within a course |
| `units` | `id`, `module_id`, `title`, `order` | Sub-groupings within a module |
| `lessons` | `id`, `unit_id`, `title`, `video_url`, `pdf_path`, `content`, `type`, `order`, `is_active` | Atomic learning items |
| `enrollments` | `id`, `user_id`, `course_id`, `enrolled_at`, `status` | Student-course subscriptions |
| `lesson_progress` | `id`, `user_id`, `lesson_id`, `completed_at` | Completion tracking per lesson |
| `quizzes` | `id`, `course_id`, `title`, `description` | Quiz metadata |
| `quiz_questions` | `id`, `quiz_id`, `question_text`, `order` | Individual quiz questions |
| `quiz_options` | `id`, `question_id`, `option_text`, `is_correct` | Answer choices |
| `quiz_attempts` | `id`, `quiz_id`, `user_id`, `score`, `completed_at` | Student attempt records |
| `assignments` | `id`, `course_id`, `title`, `description`, `due_date` | Assignment metadata |
| `assignment_submissions` | `id`, `assignment_id`, `user_id`, `file_path`, `grade`, `feedback` | Submission records |
| `certificates` | `id`, `user_id`, `course_id`, `issued_at`, `revoked_at`, `verification_code` | Issued certificates |

### 5.2 Entity Relationship Summary

* **User → Courses** (1:N via `instructor_id`): An instructor authors many courses.
* **User ↔ Courses** (M:N via `enrollments`): A student may enrol in many courses; a course may have many students.
* **Course → Modules → Units → Lessons** (cascading 1:N): Deep hierarchical syllabus structure.
* **User → LessonProgress** (1:N): Tracks which lessons each student has completed.
* **Quiz → QuizQuestions → QuizOptions** (cascading 1:N): Quiz composition structure.
* **User → QuizAttempts** (1:N): Each student can make multiple quiz attempts.
* **Assignment → AssignmentSubmissions → User** (1:N, N:1): Many students submit to one assignment; each submission belongs to one student.
* **User + Course → Certificate** (composite): One certificate per student-course pair.

---

## 6. Use Case Analysis

### 6.1 Student Use Cases

| Use Case | Description |
|---|---|
| UC-S01: Register Account | Student registers with name, email, and password |
| UC-S02: Login | Student authenticates and is redirected to student dashboard |
| UC-S03: Browse Courses | Views published course catalog on the public-facing page |
| UC-S04: Enrol in Course | Initiates enrolment; a record is created in `enrollments` |
| UC-S05: View Lesson | Accesses video, PDF, or text lesson content |
| UC-S06: Mark Lesson Complete | Submits a completion request; `LessonProgress` record is created |
| UC-S07: Take Quiz | Attempts a quiz; answers are submitted and auto-graded |
| UC-S08: Submit Assignment | Uploads assignment file; visible to Assessor for grading |
| UC-S09: View Progress | Checks overall course completion percentage from dashboard |
| UC-S10: Download Certificate | Downloads a PDF certificate upon 100% course completion |

### 6.2 Instructor Use Cases

| Use Case | Description |
|---|---|
| UC-I01: Create Course | Defines course metadata and publishes it to the catalog |
| UC-I02: Structure Syllabus | Adds modules, units, and lessons in hierarchical order |
| UC-I03: Add Lesson Content | Uploads video link, PDF, or HTML content for lessons |
| UC-I04: Create Quiz | Defines quiz, adds questions and multi-choice options |
| UC-I05: Create Assignment | Defines assignment brief and due date |
| UC-I06: View Submissions | Reviews student submissions from the assignment dashboard |
| UC-I07: View Analytics | Accesses dashboard with enrolment and engagement statistics |

### 6.3 Admin & Assessor Use Cases

| Use Case | Description |
|---|---|
| UC-A01: Manage Certificates | Views all certificates; revokes or reinstates as required |
| UC-A02: Monitor Platform | Accesses admin dashboard for system-wide oversight |
| UC-AS01: Grade Submissions | Reviews assignment submissions and assigns grade/feedback |
| UC-AS02: View Grading Queue | Browses all pending submissions filtered for grading |

---

## 7. UML Diagrams (Text Description for Drawing)

### 7.1 Use Case Diagram

**Actors:** User (abstract), Student, Instructor, Assessor, Admin, Public (unauthenticated)

**Relationships:**
* Student, Instructor, Assessor, and Admin all extend (generalise from) the abstract `User` actor for shared use cases: `Login`, `View Profile`, `Edit Profile`.
* **Student** uses: `Browse Courses`, `Enrol in Course`, `View Lesson`, `Take Quiz`, `Submit Assignment`, `View Progress`, `Download Certificate`.
* **Instructor** uses: `Create Course`, `Manage Syllabus`, `Create Quiz`, `Create Assignment`, `View Submissions`, `View Analytics`.
* **Assessor** uses: `View Grading Queue`, `Grade Submission`.
* **Admin** uses: `Manage Certificates`, `Monitor Platform`.
* **Public** uses: `Browse Courses` (read-only), `Verify Certificate`.

### 7.2 Class Diagram

**Core Classes and Attributes:**

* `User`: `id`, `name`, `email`, `role` | Methods: `isAdmin()`, `isStudent()`, `dashboardRoute()`
* `Course`: `id`, `instructor_id`, `title`, `slug`, `status` | Methods: `totalLessons()`, `progressForStudent()`
* `Module`: `id`, `course_id`, `title`, `order`
* `Unit`: `id`, `module_id`, `title`, `order`
* `Lesson`: `id`, `unit_id`, `title`, `video_url`, `type`, `is_active` | Method: `getEmbedUrlAttribute()`
* `Enrollment`: `id`, `user_id`, `course_id`, `enrolled_at`, `status`
* `LessonProgress`: `id`, `user_id`, `lesson_id`, `completed_at`
* `Certificate`: `id`, `user_id`, `course_id`, `issued_at`, `verification_code`

**Key Relationships:**
* `User` — *instructs* → `Course` (1:N via `instructor_id`)
* `User` — *enrolled-in* → `Course` (M:N via `Enrollment`)
* `Course` *aggregates* → `Module` (1:N)
* `Module` *aggregates* → `Unit` (1:N)
* `Unit` *aggregates* → `Lesson` (1:N)
* `User` + `Lesson` — *linked by* → `LessonProgress` (association class)

### 7.3 Sequence Diagram: Student Enrolment Flow

```
Student Browser     →   Route Layer    →    Controller    →   Eloquent ORM   →   MySQL DB
       │                    │                   │                  │                 │
       │── POST /student/courses/{id}/enroll ──►│                  │                 │
       │                    │                   │                  │                 │
       │                    │──auth+role check──►│                  │                 │
       │                    │                   │──Enrollment::create([user, course])►│
       │                    │                   │                  │── INSERT INTO enrollments ──►│
       │                    │                   │                  │◄── Acknowledge ─────────────│
       │                    │                   │◄── Enrollment obj│                 │
       │◄── redirect to course page (200) ──────│                  │                 │
```

---

## 8. Security Analysis

### 8.1 Authentication Mechanism

The system employs **Laravel Breeze** for web-based session authentication, providing login, registration, password reset, and email verification flows out of the box. **Laravel Sanctum** extends authentication to support token-based API access for future SPA or mobile clients. All passwords are stored using Laravel's `Hash::make`, which internally uses **Bcrypt** (cost factor 10 by default), providing strong resistance to brute-force and rainbow table attacks.

### 8.2 Authorisation: RBAC Middleware

A custom `role:` middleware checks the authenticated user's `role` attribute against a comma-separated whitelist. For example, `middleware('role:admin,instructor')` on the instructor routes ensures that only users with the admin or instructor role can access those routes, returning HTTP 403 (Forbidden) for any other role. This approach prevents **horizontal privilege escalation** (a student accessing instructor routes) and **vertical privilege escalation** (a student accessing admin functions).

### 8.3 Data Validation and Input Sanitisation

* All form submissions are validated using Laravel's Request validation pipeline before reaching the controller logic.
* Eloquent's prepared statement binding inherently prevents **SQL Injection**.
* Blade templating auto-escapes all output with `{{ }}` notation, preventing **Cross-Site Scripting (XSS)**.
* **CSRF tokens** are verified on all POST, PUT, PATCH, and DELETE requests on web routes.

### 8.4 Mass Assignment Protection

Every Eloquent Model defines a strict `$fillable` array. This explicitly lists the only attributes that may be populated via `Model::create()` or `->fill()`, preventing **mass assignment vulnerabilities** where an attacker could inject a `role` override via a crafted form submission.

### 8.5 Threat Model Summary

| Threat | Mitigation |
|---|---|
| SQL Injection | Eloquent PDO prepared statements |
| XSS | Blade auto-escaping |
| CSRF | Laravel CSRF middleware tokens |
| Privilege Escalation | RBAC middleware on all role routes |
| Mass Assignment | Strict `$fillable` arrays |
| Brute Force (Login) | Laravel's rate limiting on `/login` route |
| Unauthenticated Access | `auth` + `verified` middleware on all protected routes |
| Certificate Fraud | Unique `verification_code` per certificate; public verification portal |

---

## 9. API Design

### 9.1 Design Philosophy

Routes follow a RESTful convention using HTTP verbs (GET, POST, PUT, DELETE) mapped to CRUD operations. Routes are prefixed by role namespace (`/instructor/`, `/student/`, `/assessor/`, `/admin/`) to create clear API surface boundaries. This design allows the front end to consume endpoints predictably and facilitates automated API documentation using tools such as Swagger/OpenAPI in the future.

### 9.2 Endpoint Reference Table

| Method | Endpoint | Role | Description |
|---|---|---|---|
| `GET` | `/courses` | Public | Browse published courses catalog |
| `GET` | `/courses/{id}` | Public | View a single course detail |
| `POST` | `/student/courses/{course}/enroll` | Student | Enrol in a course |
| `GET` | `/student/courses/{course}` | Student | View enrolled course content |
| `POST` | `/student/courses/{course}/lessons/{lesson}/complete` | Student | Mark a lesson as completed |
| `GET` | `/student/quizzes/{quiz}/start` | Student | Load quiz start screen |
| `POST` | `/student/quizzes/{quiz}/attempt/{attempt}/submit` | Student | Submit quiz answers |
| `POST` | `/student/assignments/{assignment}/submit` | Student | Submit assignment file |
| `GET` | `/student/certificates` | Student | List earned certificates |
| `GET` | `/student/certificates/{certificate}/download` | Student | Download certificate PDF |
| `POST` | `/instructor/courses` | Instructor | Create a new course |
| `PUT` | `/instructor/courses/{course}` | Instructor | Update an existing course |
| `POST` | `/instructor/quizzes` | Instructor | Create a quiz |
| `GET` | `/instructor/assignments/{assignment}/submissions` | Instructor | View student submissions |
| `POST` | `/assessor/grading/{submission}/grade` | Assessor | Grade a specific submission |
| `GET` | `/admin/certificates` | Admin | View all issued certificates |
| `PATCH` | `/admin/certificates/{certificate}/revoke` | Admin | Revoke a certificate |
| `POST` | `/verify-certificate` | Public | Verify certificate by code |

---

## 10. Strengths of the System

1. **Four-Tier Content Hierarchy**: The Course → Module → Unit → Lesson structure provides significantly more granular academic organisation than the standard two-tier (Course → Lesson) model found in basic LMS solutions, enabling complex course designs akin to real university modules.

2. **Dedicated Assessor Role**: Separating the concerns of content delivery (Instructor) and grading (Assessor) is an architectural decision that reflects real-world institutional workflows (e.g., a module lecturer authors content but tutors grade work). This scales naturally in large institutions where instructors cannot also handle high volumes of grading.

3. **Public Certificate Verification Portal**: The `/verify-certificate` public endpoint adds institutional trust and real-world employability value, functioning similarly to LinkedIn's certificate verification system.

4. **Auto-Slug Generation**: The `boot()` method in the `Course` model auto-populates the `slug` field from the course `title`, enforcing SEO-friendly URL practices and eliminating human error in URL construction.

5. **Clean Controller Namespace Separation**: Controllers are cleanly separated by role into dedicated namespaces, making the codebase highly maintainable and onboarding-friendly for new developers.

6. **Content Flexibility**: Lessons supporting video (YouTube embed), PDF, and rich text content types ensures the platform is not constrained to a single delivery modality, supporting diverse learning preferences.

---

## 11. Limitations and Weaknesses

1. **No Real-Time Communication**: The system lacks WebSockets or any real-time mechanism (e.g., Laravel Echo + Pusher) for live class delivery, instant instructor feedback, or real-time notifications. This limits its suitability for live virtual classroom experiences.

2. **No Discussion Forums or Q&A**: Learner-to-learner and learner-to-instructor communication is entirely absent. This is a significant gap, as social learning and peer interaction are recognised pedagogical drivers of engagement and retention.

3. **Absence of Search and Filtering**: The course browsing experience does not appear to include full-text search, category filtering, or tag-based discovery, reducing the findability of content as the catalog grows.

4. **Single Attempt Policy Uncertainty**: It is unclear whether the quiz system enforces attempt limits. Without this, students could attempt quizzes repeatedly until favourable results are obtained, undermining assessment integrity.

5. **No Notification System**: There is no email or in-app notification for events such as assignment grading completion, new course publication, or enrollment confirmation.

6. **Frontend Completeness**: The Vue.js SPA integration is planned/partial. Without a complete frontend, the system currently appears as a server-rendered Blade application, which may limit responsiveness and user experience on some devices.

---

## 12. Recommendations for Improvement

### 12.1 AI-Powered Features
* **Course Recommendation Engine**: Implement a collaborative filtering model based on enrolment history and completion rates to suggest courses aligned with each student's learning path. Platforms such as Coursera use this extensively to drive re-engagement.
* **Automated Essay Grading Assistant**: Integrate a large language model (LLM) API call on assignment submission to provide a preliminary AI grade and feedback, reducing Assessor workload on text-based submissions.

### 12.2 Communication and Engagement
* Add a polymorphic `discussions` table (morphable to `Lesson`, `Course`, or `Assignment`) to support threaded Q&A forums, enabling peer-to-peer learning.
* Implement a **Notification System** via Laravel's built-in `Notification` facade using the `mail` and `database` channels for email alerts and in-app notification centres.

### 12.3 Performance Optimisation
* Introduce **Redis** as an application cache layer to store the results of expensive compound queries such as `Course::with('modules.units.lessons')`.
* Apply **database indexing** on high-frequency lookup columns: `enrollments.user_id`, `lesson_progress.user_id`, `lesson_progress.lesson_id`.
* Consider implementing **API response pagination** (`paginate(15)`) on course and submission list endpoints to prevent excessive data transfer.

### 12.4 Frontend Modernisation
* Complete the transition to a **Vue.js SPA** using Inertia.js as the bridge adapter, enabling page-transition animations, reduced server load, and a native-app feel without requiring a full API rebuild.
* Conduct a **UX audit** to ensure onboarding flows (first login, first enrolment) are guided with tooltips and contextual prompts.

---

## 13. Conclusion

The IQBrave Learning Management System constitutes a professionally architected, domain-driven, and security-conscious educational platform. The deliberate application of SOLID principles — evidenced by strict controller namespace separation and model-layer business logic — produces a codebase that is maintainable, testable, and extensible. The role-based access control model mirrors industry-grade institutional standards, and the four-tier content hierarchy uniquely positions the platform to serve complex academic curricula beyond what commodity LMS products typically support.

The inclusion of a public certificate verification portal, automated progress tracking, dual assessment modes, and a clean RESTful API surface collectively demonstrate a mature understanding of full-stack software engineering. While the platform currently carries limitations in real-time communication, search, and frontend completeness, these are well-understood challenges with actionable technical pathways identified in Section 12. The overall system design reflects a strong foundation capable of evolving into an enterprise-grade educational platform with targeted, incremental enhancements.

---

## 14. System Workflow (End-to-End)

This section describes the complete lifecycle journey of a student through the LMS from initial access to certificate acquisition.

### 14.1 Step-by-Step End-to-End Workflow

```
Step 1: Student Registration
└── Student visits the platform homepage (/), browses the course catalog
└── Clicks "Register", submits name/email/password
└── System creates User record with role='student'
└── Verification email is dispatched; student verifies email address
└── Redirected to student dashboard

Step 2: Course Discovery and Enrolment
└── Student browses /courses (public catalog)
└── Views a course detail page /courses/{id}
└── Clicks "Enrol"; POST /student/courses/{id}/enroll
└── Enrollment record created: { user_id, course_id, status='active', enrolled_at=now }
└── Redirected to course learning page

Step 3: Content Consumption
└── Student accesses course content page, sees Module → Unit → Lesson tree
└── Opens each Lesson (video, PDF, or text)
└── After consuming content, clicks "Mark Complete"
└── POST /student/courses/{course}/lessons/{lesson}/complete
└── LessonProgress record created: { user_id, lesson_id, completed_at=now }
└── Progress percentage recalculated and displayed on dashboard

Step 4: Assessment (Quiz)
└── Student navigates to quiz section
└── Clicks "Start Quiz" → POST creates a QuizAttempt record
└── Presented with questions and answer choices
└── Submits answers → system scores automatically by comparing to `is_correct` flags
└── Result page displayed with score and pass/fail status

Step 5: Assessment (Assignment)
└── Student views assignment brief
└── Uploads assignment file → POST /student/assignments/{id}/submit
└── AssignmentSubmission record created; file stored in cloud storage
└── Assessor receives grading task in their queue
└── Assessor reviews, assigns grade and feedback → student notified

Step 6: Course Completion and Certificate
└── When last lesson is marked complete, progress reaches 100%
└── System checks: all lessons complete?
└── If YES → Certificate record auto-generated: { user_id, course_id, issued_at, verification_code=UUID }
└── Student sees certificate in /student/certificates
└── Downloads PDF certificate
└── Certificate verifiable publicly at /verify-certificate
```

---

## 15. Data Flow Explanation

### 15.1 Overview

The following describes how data transits through each architectural layer during a typical HTTP interaction, using the Course Enrolment action as the reference example.

### 15.2 Layer-by-Layer Data Flow

```
[1] CLIENT (Browser / Vue.js SPA)
    |
    |  HTTP POST /student/courses/{id}/enroll
    |  Headers: Cookie (session token) | Body: CSRF token
    ↓
[2] ROUTING LAYER (routes/web.php)
    |
    |  Matches route: POST /student/courses/{course}/enroll
    |  Applies middleware stack: [auth, verified, role:student]
    ↓
[3] MIDDLEWARE STACK
    |
    |  auth      → checks session/Sanctum token → resolves User entity
    |  verified  → confirms email_verified_at is not null
    |  role:student → confirms user->role === 'student' → else: 403 abort
    ↓
[4] CONTROLLER (StudentController@enroll)
    |
    |  Receives Request object + Route-model-bound $course
    |  Validates: is student already enrolled?
    |  Calls: Enrollment::create([user_id, course_id, status, enrolled_at])
    ↓
[5] MODEL / ORM LAYER (Eloquent)
    |
    |  Builds SQL: INSERT INTO enrollments (user_id, course_id, status, enrolled_at)
    |              VALUES (?, ?, 'active', NOW())
    |  Executes via PDO prepared statement
    ↓
[6] DATABASE (MySQL)
    |
    |  Executes INSERT
    |  Returns auto-incremented ID and created_at timestamp
    ↓
[7] RESPONSE LAYER (Controller → View/JSON)
    |
    |  Controller receives Enrollment model instance
    |  Returns: redirect()->route('student.courses.show', $course)
    |         OR JSON { "status": "enrolled", "course_id": X } (API mode)
    ↓
[8] CLIENT receives redirect or JSON → UI updates
```

---

## 16. Scalability Strategy

### 16.1 Handling 1,000+ Concurrent Users

The following technical strategies are recommended for scaling the LMS to production workloads:

| Strategy | Implementation | Impact |
|---|---|---|
| **Eager Loading** | `Course::with('modules.units.lessons')` | Prevents N+1 query cascades |
| **Redis Caching** | Cache course content and progress queries for 5–15 min TTL | 90%+ reduction in DB reads for popular courses |
| **Database Indexing** | Index `enrollments.user_id`, `lesson_progress.user_id` and `lesson_id` | Sub-10ms query time on large tables |
| **Queue Workers** | Use Laravel Queues for email dispatch (certificate issued, grading complete) | Keeps HTTP responses fast; async processing |
| **CDN for Static Assets** | Push course thumbnails, PDFs, and videos to AWS S3 + CloudFront | Offloads bandwidth from the application server |
| **Horizontal Scaling** | Deploy multiple Laravel app server instances behind a load balancer | Linear increase in request handling capacity |
| **Read Replicas** | MySQL read replicas for Student read queries (course browse, progress) | Separates read/write DB workloads |
| **Rate Limiting** | Laravel middleware throttle on API and auth endpoints | Prevents DDoS and brute-force overload |

### 16.2 Architecture at Scale (Conceptual)

```
                        ┌─────────────┐
           Users ──────►│ Load Balancer│ (NGINX / AWS ALB)
                        └──────┬──────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────▼──┐   ┌─────────▼──┐   ┌─────────▼──┐
    │ App Server 1│   │ App Server 2│   │ App Server 3│   (Laravel)
    └─────────┬──┘   └─────────┬──┘   └─────────┬──┘
              │                │                │
              └────────────────┼────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │    Redis Cache       │
                    └──────────┬──────────┘
                               │
               ┌───────────────┼───────────────┐
               │                               │
    ┌──────────▼──────┐           ┌────────────▼────────┐
    │ MySQL Master DB  │           │ MySQL Read Replica   │
    │ (Writes)         │◄─ repl ──►│ (Reads only)         │
    └──────────────────┘           └─────────────────────┘

    [Uploads/PDFs/Videos → AWS S3 + CloudFront CDN]
```

---

## 17. Deployment Architecture

### 17.1 Hosting Plan

A phased deployment strategy is recommended using **DigitalOcean** (for simplicity and cost control at launch) with a migration path to **AWS** as scale demands grow.

| Component | Technology | Hosting Provider |
|---|---|---|
| Web Server | NGINX + PHP-FPM | DigitalOcean Droplet (4 vCPU / 8 GB) |
| Application | Laravel (Octane/ReadyBoost) | Same Droplet or App Platform |
| Database | MySQL 8.x | DigitalOcean Managed Database |
| Cache / Queues | Redis 7.x | DigitalOcean Managed Redis |
| File Storage | Laravel Filesystem (S3 Driver) | AWS S3 Bucket |
| SSL Certificate | Let's Encrypt (auto-renew) | Certbot on NGINX |
| CDN | CloudFront or DigitalOcean Spaces CDN | AWS / DigitalOcean |

### 17.2 Environment Configuration

Laravel's `.env` file manages environment configurations that differ between local development, staging, and production:

```env
APP_ENV=production
APP_DEBUG=false
DB_CONNECTION=mysql
DB_HOST=managed-db.cluster.do.example.com
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
FILESYSTEM_DISK=s3
AWS_BUCKET=iqbrave-lms-uploads
```

### 17.3 CI/CD Pipeline (Conceptual)

```
Developer pushes to GitHub (main branch)
          │
          ▼
GitHub Actions Workflow triggers:
  1. Run PHPUnit tests (php artisan test)
  2. Check code style (PHP CS Fixer / Pint)
  3. Build frontend assets (npm run build)
  ↓ (if all pass)
  4. SSH deploy to production server via Envoyer or Deployer.php:
       - git pull origin main
       - composer install --no-dev --optimize-autoloader
       - php artisan migrate --force
       - php artisan config:cache
       - php artisan route:cache
       - php artisan view:cache
       - Reload PHP-FPM workers (zero-downtime)
```

---

## 18. Testing Strategy

### 18.1 Overview

A robust testing strategy ensures that every critical path through the application is validated before deployment. The Laravel framework provides a first-class testing infrastructure built on **PHPUnit**, with a friendly `TestCase` base class and elegant HTTP assertion helpers.

### 18.2 Unit Testing

Unit tests target individual, isolated components — particularly Model methods and business logic:

```php
// Example: Test progress calculation
public function test_progress_returns_correct_percentage()
{
    $course = Course::factory()->hasLessons(4)->create();
    $student = User::factory()->create(['role' => 'student']);
    // Simulate 2 of 4 lessons completed
    LessonProgress::factory()->count(2)->create(['user_id' => $student->id]);
    $this->assertEquals(50, $course->progressForStudent($student->id));
}
```

### 18.3 Feature Testing

Feature tests validate the full HTTP request lifecycle:

```php
// Example: Test enrolment endpoint
public function test_student_can_enrol_in_course()
{
    $student = User::factory()->create(['role' => 'student']);
    $course  = Course::factory()->create(['status' => 'published']);
    $response = $this->actingAs($student)
                     ->post("/student/courses/{$course->id}/enroll");
    $response->assertRedirect();
    $this->assertDatabaseHas('enrollments', [
        'user_id'   => $student->id,
        'course_id' => $course->id,
    ]);
}
```

### 18.4 Security Testing

```php
// Example: Test role access control
public function test_student_cannot_access_instructor_dashboard()
{
    $student = User::factory()->create(['role' => 'student']);
    $response = $this->actingAs($student)->get('/instructor/dashboard');
    $response->assertStatus(403);
}
```

### 18.5 API Testing (Future)

For the Vue.js SPA integration, Sanctum-authenticated API tests are recommended:

```php
$token = $user->createToken('test-token')->plainTextToken;
$response = $this->withToken($token)->postJson('/api/enroll', ['course_id' => 1]);
$response->assertStatus(200)->assertJson(['enrolled' => true]);
```

### 18.6 Testing Execution

```bash
# Run full test suite
php artisan test

# Run specific test group
php artisan test --filter=EnrolmentTest

# Run with coverage report
php artisan test --coverage
```
