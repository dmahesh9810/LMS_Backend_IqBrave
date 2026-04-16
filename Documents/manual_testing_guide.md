# IQBrave LMS - Manual Testing Guide

The system currently passes all automated feature tests (14 tests, 37 assertions). To manually verify the workflows against the real UI, follow this step-by-step testing guide.

---

## 👨‍🎓 1. Student Testing

**Prerequisites:** You need a registered student account and a published course containing an active assignment.

### Step 1: Login & Dashboard
- **Action:** Go to the `/login` page and log in using student credentials.
- **Expected Result:** You are immediately redirected to the Student Dashboard (`/student/dashboard`).

### Step 2: Enroll in a Course
- **Action:** Click on "Browse Courses" or navigate to `/student/courses`. Find a published course and click the **"Enroll"** button.
- **Expected Result:** The page reloads, showing a success message. You now have access to the course content and assignments.

### Step 3: Submit an Assignment
- **Action:** Navigate to your assignments (`/student/assignments`). Click on an active assignment. Choose a file (e.g., a PDF) and click **"Submit"**.
- **Expected Result:** You are redirected to the submission details page. The visible status badge must say **"Submitted"**.

### Step 4: Resubmit an Assignment
- **Action:** On the same submission details page, upload a *new* file and click **"Resubmit"**.
- **Expected Result:** A success message appears. If the submission had prior instructor or assessor feedback, that feedback is fully erased, and the status returns to **"Resubmitted"** (or "Submitted").

---

## 👨‍🏫 2. Instructor Testing

**Prerequisites:** You need an instructor account who owns the course the student just submitted an assignment for.

### Step 1: Login & Submissions View
- **Action:** Log out of the student account and log in as the Instructor. Navigate to **"Assignments"** in the sidebar, find the assignment, and click **"View Submissions"**.
- **Expected Result:** You see a list of student submissions. The student from the previous test should be listed with a "Submitted" status.

### Step 2: Instructor Review & Grade
- **Action:** Click **"Add Review & Grade"** next to the student's name. Download/view their file. Select **Competent** or **Not Yet Competent**, type feedback into the text area, and click **"Save Grade & Forward"**.
- **Expected Result:** The submission is saved securely. The status badge must change to **"Instructor Assessed"**. The submission is now functionally forwarded to the Assessor for Verification.

---

## 🕵️‍♂️ 3. Assessor Testing

**Prerequisites:** You need an Assessor account. 

### Step 1: Open Verification Dashboard
- **Action:** Log out of the instructor account and log in as the Assessor. Click on **"Grading Queue"** (`/assessor/grading`) in the sidebar.
- **Expected Result:** You should see the submission that was just "Instructor Assessed". You should **NOT** see any assignments that are merely "Submitted" or already "Verified".

### Step 2: Verify & Endorse
- **Action:** Click **"Verify"** (eye icon) on the pending submission. You will see the student's file and the instructor's Competent/NYC decision. Under the "Audit Action" section, select **"Verify & Endorse"**, add an optional TVEC auditing note, and hit **"Submit Verification"**.
- **Expected Result:** The page redirects to the queue with a success message. The submission physically moves to the "Recently Verified" list at the bottom. The status is permanently locked to **"Verified"**, and the TVEC audit log securely records who made this endorsement.

---

## 👑 4. Admin Testing

**Prerequisites:** You need the primary Admin account.

### Step 1: Approve Course
- **Action:** Log in as Admin. From the dashboard, look at the **"Pending Courses"** table for any course submitted by an instructor for review. Click the **"Approve"** button.
- **Expected Result:** The course disappears from the pending table and its status becomes "Published", making it visible to students.

### Step 2: Manage Certificates
- **Action:** Navigate to **"Certificates"** (`/admin/certificates`) in the sidebar. Find an active certificate in the list and click **"Revoke"**.
- **Expected Result:** The certificate page reloads. The specific certificate's badge dynamically updates from "Active" to **"Revoked"**. (Optional: click "Reinstate" to ensure it reverts to Active).

### Step 3: TVEC Verification Audit Logs
- **Action:** Navigate to **"TVEC Verification Logs"** (`/admin/audits`) or manually go there in your URL. 
- **Expected Result:** You will see a highly detailed table showing the EXACT DATE the Assessor verified the submission, what the Instructor's decision was, and the Assessor's note. This satisfies the Sri Lankan NVQ standard audit trail constraint.

---

### Final Validation
If all the above manual steps perfectly match their "Expected Results" without encountering 500 server errors, the 2-Level NVQ grading workflow and RBAC matrix are verified stable for production deployment.
