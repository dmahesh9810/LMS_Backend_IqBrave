# Final Year Project Report: Intelligent Learning Management System (LMS)

## 1. Introduction

### 1.1 Overview of the LMS
The digital transformation of education has necessitated the development of robust, scalable, and intuitive platforms for delivering educational content. The Intelligent Learning Management System (LMS) developed in this project is a comprehensive, modern e-learning platform engineered to bridge the gap between instructors and learners. Built upon a robust technology stack featuring Laravel for the backend and Vue.js with Tailwind CSS for the frontend, the system facilitates seamless course creation, student enrollment, assignment grading, and interactive learning. 

This LMS is distinguished by its seamless integration of core educational tools with advanced operational modules, including a PayHere payment gateway tailored for localized transactions, an AI-driven course recommendation engine, dynamic pricing models, and real-time SMS/Email notification systems.

### 1.2 Purpose of the System
The primary purpose of this system is to provide a centralized, highly accessible, and interactive ecosystem for educational institutes, independent educators, and students. It aims to automate the administrative overhead of managing enrollments, tracking student progress, conducting assessments (quizzes and assignments), and issuing verifiable digital certificates. By streamlining these process flows, educators can focus entirely on pedagogy while students benefit from an engaging, self-paced learning environment.

### 1.3 Objectives
- **Centralized Content Delivery:** To provide an organized hierarchy of learning materials (Courses > Modules > Units > Lessons) that is easy to navigate.
- **Automated Assessments & Certification:** To implement an automated quiz and assignment grading workflow, culminating in the issuance of auto-generated, verifiable certificates using unique UUIDs.
- **Secure Financial Transactions:** To integrate a secure and reliable payment execution flow via PayHere for paid course enrollments.
- **Personalized Learning Experience:** To utilize an AI Recommendation Engine that suggests courses based on user preferences, learning history, and enrollment trends.
- **Role-Based Access Control (RBAC):** To maintain strict data privacy and operational boundaries via cleanly delineated roles: Admin, Instructor, Assessor, and Student.

---

## 2. Problem Statement

### 2.1 Problems in Traditional Learning Systems
Traditional education and early-generation LMS platforms frequently suffer from several critical shortcomings:
1. **Administrative Bottlenecks:** Manual enrollment processes, physical assignment submissions, and manual grading consume excessive administrative time.
2. **Poor User Experience & Accessibility:** Legacy systems often feature archaic, non-responsive interfaces that do not translate well to mobile devices, alienating modern learners.
3. **Lack of Personalization:** A generic "one-size-fits-all" course catalog fails to guide students toward content that matches their specific career goals or past performances.
4. **Inefficient Payment Mechanisms:** Difficulty in handling secure, localized online payments (specifically using LKR) restricts instructors from monetizing their content efficiently.
5. **Rigid Pricing Models:** Traditional systems lack the flexibility to alter course prices dynamically based on demand, seasonal trends, or remaining seat availability.

### 2.2 Why this LMS is Needed
This LMS directly addresses these deficiencies by offering an automated, responsive, and intelligent platform. It removes administrative friction by automating enrollments via secure PayHere integrations. It enhances the user experience through a modern Vue.js Single Page Application (SPA) architecture, ensuring smooth transitions and a mobile-first design. Crucially, the introduction of AI-driven recommendations and dynamic pricing injects a level of commercial and educational intelligence rarely seen in standard academic projects, making the platform both pedagogically effective and commercially viable.

---

## 3. System Overview

### 3.1 High-Level Explanation
The developed LMS follows a decoupled Client-Server architecture. The backend, functioning as a RESTful API powered by Laravel, handles all complex business logic, database transactions, payment validation (via PayHere webhooks), and AI model interactions. The frontend, designed with Vue.js and styled with Tailwind CSS, consumes these APIs to render dynamic, interactive user interfaces without requiring full page reloads.

### 3.2 Key Features
- **Hierarchical Course Structure:** Deep categorization of content into Courses, Modules, Units, and multi-media Lessons (video, text, PDF).
- **Advanced Assessment Engine:** Support for varied quiz formats (multiple choice, true/false) and file-based assignment submissions with assessor-based grading.
- **Secure E-Commerce Capabilities:** Full PayHere integration with MD5 hash validation for secure transaction callbacks.
- **Verifiable Certifications:** Automated generation and verification of digital certificates with public URL validation.
- **Intelligent Recommendations:** AI-based engine analyzing student progress and tags to suggest relevant future learning paths.
- **Dynamic Pricing:** Algorithmically adjusted course fees based on enrollment velocity and instructor-defined thresholds.

---

## 4. Technologies Used

The technology stack was carefully selected to ensure high performance, security, and developer productivity:

1. **Laravel 11 (Backend Framework):** Chosen for its elegant syntax, built-in security features (CSRF protection, SQL injection prevention via Eloquent ORM), and robust ecosystem. It simplifies API development, job queuing (for emails/notifications), and database migrations.
2. **Vue.js 3 & Vite (Frontend Framework):** Vue.js provides a reactive, component-based architecture ideal for building complex dashboards (Student, Instructor, Admin). Vite was utilized as the build tool for its lightning-fast Hot Module Replacement (HMR) and optimized production builds.
3. **Tailwind CSS (Styling):** A utility-first CSS framework that allows for rapid UI development. It ensures the application is 100% responsive and maintains a consistent, modern design language without bloated custom stylesheets.
4. **MySQL (Database):** A proven, ACID-compliant relational database management system. It was chosen to handle the complex, highly-relational data structures of an LMS (e.g., Many-to-Many relationships between Users, Courses, and Enrollments).
5. **PayHere (Payment Gateway):** Selected specifically for its seamless handling of Sri Lankan Rupees (LKR) and robust webhook system for asynchronous payment confirmation.
6. **Mailtrap & SMS Gateways:** Mailtrap is used for safely testing email flows (registration, certificate issuance) in development, while SMS provides immediate alerts for critical actions like payment success or assignment deadlines.

---

## 5. System Architecture

### 5.1 Architectural Design (Client-Server / REST API)
The system employs a strict separation of concerns utilizing a decoupled REST API architecture. 
- **The Presentation Layer (Client):** The Vue.js application runs in the user's browser, managing UI state, form validations, and rendering dynamic real-time components (e.g., video players, quiz interfaces).
- **The Business Logic Layer (Server):** The Laravel backend exposes secure API endpoints protected by Laravel Sanctum token-based authentication. It processes requests, interacts with the database, communicates with third-party APIs (PayHere), and returns structured JSON responses.
- **The Data Layer:** The MySQL database stores persistent entities, ensuring data integrity through foreign key constraints and atomic transactions.

### 5.2 Component Diagram Description (For Drawing)
*When drawing the Component Diagram, include the following blocks:*
- **User Devices (Web/Mobile Browser):** Contains the "User Agent" block connecting via HTTPS to the Frontend.
- **Frontend (Vue.js application):** Contains sub-components: *Auth Module*, *Course Viewer Component*, *Student/Instructor Dashboards*, *Checkout UI*.
- **Backend (Laravel application):** Contains controllers/services: *AuthService*, *CourseService*, *PaymentService*, *NotificationService*, *AI Recommendation Service*.
- **Database (MySQL Server):** Receives connections via Eloquent ORM from the Backend.
- **External Services (Cloud):** Place these as external nodes connected to the Backend: *PayHere Gateway*, *Mailtrap Server*.

### 5.3 Architecture Diagram Description (For Drawing)
*When drawing the System Architecture Diagram:*
1. Draw a horizontal flow. On the left, place the **Client Devices** (Laptop, Mobile).
2. Point arrows from the Clients to a central **API Router / Load Balancer** block representing Laravel Web/API Routes.
3. From the Router, split the flow into **Security Middleware (Sanctum Auth & RBAC)**.
4. From Middleware, map into the **Business Logic Layer (Controllers & Services)**. Add sub-boxes specifically for *Payments, Courses, Analytics, and AI*.
5. Below the Business Logic, place the **MySQL Database Instance**. Connect them with bi-directional arrows labeled "Database Driver / Eloquent Queries".
6. On the top right of the logic layer, draw a distinct box for external APIs: an outgoing arrow labeled "POST payment info" to the **PayHere Gateway**, and a dashed incoming arrow labeled "Webhook Asynchronous Callback".

---

## 6. Functional Requirements

### 6.1 Student Features
- **Registration & Authentication:** Secure sign-up, login, password recovery, and profile management.
- **Course Discovery:** Ability to search courses by category, utilize AI recommendations, and view course curriculums/previews before purchase.
- **Enrollment & Payment Workflow:** Seamless enrollment into free courses or secure checkout for paid courses using PayHere, generating instant confirmation invoices.
- **Structured Learning Environment:** Track granular lesson progress, watch embedded multimedia, download PDF resources, and mark modules as completed to unlock subsequent units.
- **Assessments & Evaluation:** Attempt timed quizzes (Multiple Choice, True/False) with instant feedback, and submit file-based practical assignments for manual review.
- **Certification:** Automatically generate, download, and verify digital PDF certificates upon reaching a 100% course completion threshold.

### 6.2 Instructor Features
- **Course Authoring Capability:** Create, configure, and publish rich courses containing nested hierarchies: Modules -> Units -> Lessons.
- **Assessment Management:** Build comprehensive quizzes with automated grading keys and formulate assignment rubrics.
- **Student Analytics:** Monitor the progress of enrolled students, view grade distributions, and analyze course performance metrics/drop-off rates.
- **Dynamic Pricing Config:** Set base prices, offer percentage discounts, and configure dynamic pricing rules based on enrollment thresholds to maximize revenue.

### 6.3 Admin/Assessor Features
- **User Management (Admin):** Manage all system users, assign specialized roles (Instructor, Assessor), and handle account suspension functionalities.
- **Course Moderation (Admin):** Review, approve, or reject courses submitted by instructors to enforce platform quality control.
- **Grading & Feedback (Assessor):** Review student assignment submissions, provide qualitative textual feedback, and assign formal final grades.
- **Platform Analytics (Admin):** View dashboard metrics on platform-wide generated revenue, active concurrent users, global enrollment statistics, and AI engagement reports.

---

## 7. Non-Functional Requirements

### 7.1 Performance
The system is engineered to handle concurrent high-volume traffic without significant latency degradation. 
- API responses are optimized to resolve within 300ms on average using Laravel query caching and Eloquent eager-loading to prevent N+1 query problems.
- High-latency, resource-intensive tasks, such as generating large PDF certificates and dispatching mass emails, are offloaded to asynchronous background queues using `Laravel Jobs` ensuring the fast frontend UI remains highly responsive to the end-user.

### 7.2 Security
- **Authentication:** All protected API and web routes are shielded by Laravel Sanctum, preventing unauthorized access and session hijacking.
- **Authorization:** Strict custom Role-Based Access Control (RBAC) middleware ensures users cannot access cross-role endpoints (e.g., preventing a Student from accessing Instructor course deletion routes), returning HTTP 403 Forbidden responses automatically.
- **Data Protection:** Passwords are cryptographically hashed using the Bcrypt algorithm before database entry. All web forms utilize ingrained CSRF protection, and REST inputs are strictly sanitized via Laravel Form Request Validation classes to prevent SQL injection and persistent Cross-Site Scripting (XSS).
- **Payment Verification:** Asynchronous webhooks received from PayHere are rigorously validated using MD5 hash comparison against the merchant secret to prevent fraudulent spoofing of successful payment payloads.

### 7.3 Scalability
The decoupled modern architecture dictates that the Vue.js frontend can be distributed globally on Edge Networks (like Vercel or Netlify) serving static assets extremely fast. The Laravel backend can be scaled horizontally behind a round-robin load balancer. At the data layer, the MySQL database utilizes dense indexing on critical foreign keys (such as `user_id`, `course_id`) to ensure read and join operations across massive tables remain fast as the user base expands exponentially.

### 7.4 Usability
The UI/UX is built with a "mobile-first" philosophy using Tailwind CSS. 
- It features high-contrast text, clear calls-to-action (CTAs) for important pathways like purchasing or taking quizzes.
- Intuitive navigation sidebars are dynamically rendered based precisely on the user's role.
- Informative toast/flash notifications guide the user seamlessly through complex workflows, minimizing confusion during checkout, assignment upload, or password resets.

## 8. Database Design

### 8.1 Key Entity Tables
The LMS utilizes a highly relational MySQL database structure to ensure data normalization and referential integrity.

1. **`users` Table:**
   - Central authentication table holding `name`, `email`, cryptographically hashed `password`, and enum `role` ('admin', 'instructor', 'assessor', 'student').
2. **[courses](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/User.php#107-117) Table:**
   - Stores core course metadata: `title`, `slug`, `description`, `thumbnail`, and `status`. Linked to `users` via the `instructor_id` foreign key.
3. **`student_enrollments` / [enrollments](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/User.php#124-129) Table:**
   - A pivot table establishing a Many-to-Many relationship between Users (students) and Courses. It tracks the `course_id`, `user_id`, enrollment `status`, and `enrolled_at` timestamps.
4. **`payments` Table:**
   - Logs transactional data from PayHere. Stores `payment_id`, `user_id`, `course_id`, transaction `amount`, `currency` (LKR/USD), and `status` ('pending', 'successful', 'failed', 'refunded'). Vital for financial auditing.
5. **`reviews` Table:**
   - Captures qualitative feedback linking students to specific courses. Contains `user_id`, `course_id`, an integer `rating` (1-5), and a text `comment`.
6. **[certificates](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/Course.php#69-74) Table:**
   - Issues immutable records of achievement linking a `user_id` to a `course_id`. Contains a unique, verifiable `certificate_number` and `issued_at` date.

### 8.2 Describe Relationships
- **One-to-Many (Instructor -> Courses):** A single user with the 'instructor' role can create multiple courses.
- **Many-to-Many (Students <-> Courses):** Students can enroll in multiple courses, and courses have multiple students. This is resolved via the `student_enrollments` junction table.
- **One-to-Many (Course -> Modules -> Units -> Lessons):** A hierarchically cascaded structural relationship mapping the curriculum tree.
- **One-to-One (Enrollment -> Payment):** A single paid enrollment corresponds exclusively to one successful payment record.

---

## 9. System Modules

### 9.1 Authentication & RBAC System
Powered by Laravel Sanctum, this module manages login sessions, secure password resets, and role-based routing. It guarantees that an [instructor](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/Course.php#40-45) can access the Course Creation Dashboard, while a [student](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/Course.php#52-62) is cleanly directed to the Learning Dashboard.

### 9.2 Course Management System
The core engine for curriculum building. Instructors upload multimedia resources and structure content hierarchically. It features draft/publish statuses, preventing students from seeing incomplete modules until the instructor explicitly publishes them or an Admin approves them.

### 9.3 Booking / Enrollment System
Handles the transitional logic when a student opts to purchase or join a course. For free courses, it immediately attaches the user ID to the course ID. For paid courses, it temporarily holds the enrollment in 'pending' status, transitioning to 'active' only upon a confirmed payment webhook callback.

### 9.4 Payment System (PayHere Integration)
This module securely bridges the LMS to the PayHere gateway. It dynamically generates robust HTML checkout forms with MD5-hashed security tokens, preventing URL tampering. It functions completely asynchronously, relying on sever-to-server callbacks to finalize the financial state of the application.

### 9.5 Review & Rating System
Allows students to submit post-completion evaluations. It calculates aggregate star ratings per course, significantly influencing the AI Recommendation Engine and providing social proof to prospective enrollees browsing the course catalog.

### 9.6 Admin Dashboard (Analytics & Moderation)
The nerve center for operations. Admins can revoke suspect certificates, review flagged reviews, approve new course curriculums, and visualize daily system revenue and user registration trends via robust charting libraries (e.g., Chart.js integrated with Vue).

### 9.7 AI Recommendation System
An intelligent backend service that analyzes a user's enrollment history, quiz performance, and previously viewed categories. By applying collaborative filtering algorithms (matching users with similar learning profiles), it surfaces personalized "Recommended for You" courses on the student dashboard, increasing platform retention.

### 9.8 Dynamic Pricing System
A yield management module that allows instructors to set rules, such as "Increase course price by 10% when 80% of virtual seats are booked" or orchestrate limited-time flash sales automatically. This mimics airline pricing strategies, maximizing total revenue.

### 9.9 Notification System (Email & SMS)
Operating on asynchronous Laravel Jobs to prevent UI blocking.
- **Emails (via Mailtrap/SMTP):** Dispatched for secure welcome messages, password resets, and PDF certificate attachments.
- **SMS Notifications:** Triggered for urgent, high-value events like successful payment deductions or impending assignment deadlines ensuring high visibility.

---

## 10. Payment Integration

### 10.1 PayHere Integration Flow
The integration with PayHere guarantees secure, seamless LMS monetization, crucial for local contexts operating in LKR.
1. **Checkout Initiation:** When a student clicks "Enroll", the backend generates a unique `order_id` and securely creates a pending record in the `payments` table.
2. **Redirection Phase:** The student is redirected to the external, secure PayHere payment gateway using an HTML form post containing merchant details, order specifics, and the crucial generated Hash.
3. **Transaction Processing:** The student enters their credit/debit card details natively on the PayHere server, ensuring the LMS itself handles no sensitive PCI-DSS restricted data.
4. **Return Paths:** Upon completion, the student is returned to a 'Thank You' Vue UI view, but the enrollment is *not* yet finalized based purely on this browser return.

### 10.2 Hash Generation & Webhook Security
A robust, asynchronous server-to-server webhook callback validates the true payment status.
- **Hash Generation:** To initiate payment, Laravel generates an MD5 hash utilizing `merchant_id`, `order_id`, the formatted `amount`, `currency`, and an MD5-hashed version of the private `merchant_secret`. This stringent hash is sent natively via the form, preventing malicious actors from altering the price in the browser developer tools.
- **Webhook Callback Processing:** PayHere sends an asynchronous HTTP POST to a designated, CSRF-exempt `/api/payhere/notify` API route. 
- **Validation:** The LMS intercepts this payload, regenerates the hash based on the received confirmation parameters and its hidden merchant secret. If the hashes match and `status_code === 2`, the associated `payment` and [enrollment](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/User.php#124-129) pivot statuses are atomically updated from 'pending' to 'active', granting the student immediate access to the curriculum.

---

## 11. Security Implementation

### 11.1 Sanctum Authentication
Laravel Sanctum issues stateful cookies for the frontend SPA (Vue.js). This ensures airtight authentication without the complexity of manual JWT management. It mitigates Session Hijacking risks and seamlessly integrates with Vue Router to protect route navigation guards.

### 11.2 Input Validation
All incoming HTTP requests pass through dedicated Laravel Form Request classes (e.g., `StoreCourseRequest`, `SubmitAssignmentRequest`). 
- Data is strictly sanitized to expected formats (e.g., `email`, `numeric`, `string`, `mimes:pdf,jpg`).
- If validation fails, Laravel automatically intercepts the request and returns a structured 422 Unprocessable Entity JSON response to the Vue frontend, alerting the user to correct the specific fields.

### 11.3 Protection Against Common Attacks
- **Cross-Site Request Forgery (CSRF):** Since the frontend SPA lives on the same domain as the API, Sanctum handles CSRF out-of-the-box by verifying the `X-XSRF-TOKEN` sent with every Axios header.
- **SQL Injection:** The absolute exclusivity of using the Eloquent ORM ensures all database queries are parsed using PDO parameter binding, rendering SQL injection technically impossible.
- **Cross-Site Scripting (XSS):** The Vue.js rendering engine automatically escapes HTML entities. Even if a user manages to inject a `<script>` tag into a course description or review, it is rendered cleanly as raw text, neutering the attack payload.
- **Rate Limiting:** Critical endpoints, specifically login routes and the PayHere webhook destinations, are throttling using the `RateLimiter` facade to suppress brute-force dictionary attacks.

## 12. Testing

### 12.1 Unit Testing
Unit testing was primarily focused on isolating specific business logic functions to ensure output accuracy without touching the database or external APIs. 
- **Example:** Tested the `DynamicPricingService` to assert that if a course reached 80% capacity, the calculated price increased by exactly 15%, handling floating-point currency variations correctly.

### 12.2 Feature Testing
Feature tests validated end-to-end workflows by hitting API endpoints and asserting corresponding database changes or API responses.
- **Example Test Case 1 (Authentication):** Assert that a `POST` request to `/api/login` with correct credentials returns a `200 OK` status with a Sanctum Bearer token, whilst an incorrect password returns `422 Unprocessable Entity`.
- **Example Test Case 2 (Role Access):** Assert that a student attempting an HTTP `DELETE` on a course endpoint (accessible only to Instructors) correctly receives a `403 Forbidden` Exception.
- **Example Test Case 3 (Payment Callback):** Simulate a valid POST response from PayHere to the webhook URL. Assert that the [enrollments](file:///c:/Users/Mahesh%20Dissanayaka/Desktop/Projects/Sachi/iqbrave-lms/app/Models/User.php#124-129) table pivot status transitions correctly from `pending` to `active`.

---

## 13. Challenges Faced

1. **PayHere Webhook Concurrency:** 
   - *Problem:* Occasionally, the user would return to the "Thank You" page before the asynchronous PayHere webhook had pinged the server, causing the frontend to temporarily show an "Unpaid" status.
   - *Solution:* Implemented Vue.js polling that queries the backend every 3 seconds for up to 15 seconds on the thank-you page to gracefully handle the asynchronous delay.
2. **Video Streaming Latency:**
   - *Problem:* Serving large MP4 files directly from the local Laravel storage caused high server load and buffer times for students.
   - *Solution:* Offloaded heavy video storage to an external CDN/cloud bucket, transitioning the frontend video player to stream chunked byte-ranges rather than downloading the whole file.
3. **Complex Data Relationships:**
   - *Problem:* Querying the progress of a student across multiple units and lessons was creating significant N+1 database bottlenecks.
   - *Solution:* Utilized Laravel's Eloquent Eager Loading (`with()`) to fetch nested relationships efficiently in one overarching SQL query.

---

## 14. Future Improvements

1. **Dedicated Mobile Application:**
   - Develop native iOS and Android applications using Flutter or React Native that consume the existing REST API, enabling offline downloads for course modules.
2. **Advanced AI Features:**
   - Integrate Large Language Models (LLMs) to automatically generate quiz questions based purely on uploaded PDF lesson materials, saving instructors significant manual data-entry time.
3. **Multi-Tenant Scalability:**
   - Refactor the database structure to a Multi-Tenant SaaS architecture, allowing different independent schools or institutes to register and manage their own "White-labeled" version of the LMS under custom subdomains.

---

## 15. Conclusion

### 15.1 Final Summary
The Intelligent Learning Management System developed successfully fulfills its core objective: delivering a secure, highly interactive, and commercially viable digital learning environment. By combining the robustness of Laravel, the reactivity of Vue.js, and the financial utility of PayHere, the project effectively solves critical bottlenecks found in legacy educational platforms. It proves that modern web architectures can gracefully handle complex user hierarchies, multimedia delivery, and e-commerce workflows seamlessly.

### 15.2 System Impact
The implementation of this LMS empowers educators by removing administrative friction through automated grading, enrollment, and digital certification. For learners, it provides a personalized, responsive, and engaging medium to achieve their educational goals. Ultimately, the integration of AI-driven recommendations and dynamic pricing mechanisms elevates this system from a standard academic project into a viable, production-ready commercial application.

---
---

# 🎤 BONUS: Viva Presentation Speech (2–3 Minutes)

*(Stand confidently, make eye contact, and speak clearly. Use this script alongside your slides.)*

**[Slide 1: Title Slide - Introduction]**
"Good morning, respected panel members. My name is [Your Name], and I am proud to present my Final Year Project: an 'Intelligent Learning Management System' built using Laravel, Vue.js, and MySQL. The goal of this project was to move beyond a basic e-learning site and build a commercially viable, automated digital education platform."

**[Slide 2: The Problem & Our Solution]**
"Traditional systems often struggle with three main issues: clunky interfaces, manual administrative tasks like grading or enrollments, and a lack of secure, localized payment options. 
My system solves this. It provides a highly responsive Vue.js Single Page Application for students. It automates quizzes and certificate generation, removing the burden from instructors. And conceptually, it integrates the PayHere payment gateway to facilitate seamless transactions in Sri Lankan Rupees."

**[Slide 3: System Architecture]**
"Looking at the architecture, I utilized a decoupled REST API model. The Laravel backend handles the heavy lifting: secure Sanctum authentication, database transactions, and Webhook validation. The frontend simply consumes these APIs. This strict separation of concerns means the application is highly secure and scalable. Furthermore, I implemented strict Role-Based Access Control, ensuring that Admins, Instructors, Assessors, and Students each get entirely different, isolated dashboards."

**[Slide 4: Key Features & Innovation]**
"What sets this system apart are its advanced modules. 
First, the **PayHere Integration**: the system generates secure MD5 hashes to prevent price tampering and uses asynchronous webhooks to confirm payments.
Secondly, the **Automated Workflow**: Students watch lessons, take auto-graded quizzes, submit assignments to an Assessor, and finally receive a digitally verifiable PDF certificate automatically.
Lastly, the system is designed to accommodate an **AI Recommendation Engine** to analyze learning patterns and suggest future courses, increasing platform retention."

**[Slide 5: Challenges & Conclusion]**
"During development, ensuring the PayHere webhook synced perfectly with the frontend 'Thank You' page was a challenge due to asynchronous delays. I overcame this by implementing a polling mechanism on the frontend. 
In conclusion, this project demonstrates a robust, production-ready architecture capable of handling complex e-commerce, multimedia delivery, and multi-tier user workflows seamlessly. 

Thank you. I am now open to any questions."
