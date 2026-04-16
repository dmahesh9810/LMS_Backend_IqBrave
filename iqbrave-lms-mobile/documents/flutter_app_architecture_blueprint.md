# IQBrave LMS - Mobile App Architecture & UI Blueprint

මෙම ලේඛනය (Blueprint) ඔබගේ නව Flutter Mobile App එක සංවර්ධනය කිරීමට අදාළ සම්පූර්ණ සැලසුම (Architecture, Folder Structure, UI Guidelines) පැහැදිලි කරයි. මෙම ලේඛනය ඔබගේ Mobile App ෆෝල්ඩරයේ සුරක්ෂිතව තබා ගැනීමෙන් අනාගතයේදී Agent සමඟ වැඩ කිරීම ඉතාමත් පහසු වේ.

---

## 1. තාක්ෂණික සැලසුම (Tech Stack & Architecture)

*   **Framework:** Flutter (වඩාත් අලුත්ම සංස්කරණය)
*   **State Management:** Riverpod 2.0 (වඩාත් නවීන හා නම්‍යශීලී ක්‍රමවේදය) හෝ GetX (සරල ක්‍රමවේදයක් අවශ්‍ය නම්). නිර්දේශ කරන්නේ **Riverpod** යпыт.
*   **API Network Call Handling:** `Dio` package එක. (Laravel Sanctum token එක දමා හැසිරවීමට මෙය වඩාත් පහසුය).
*   **Charts & Graphs:** `fl_chart` හෝ `syncfusion_flutter_charts` (Knowledge Radar chart එක නිර්මාණය කිරීම සඳහා).
*   **Architecture Pattern:** MVC (Model-View-Controller) / MVVM මත පදනම් වූ Feature-First Folder Structure.

---

## 2. මූලික ෆෝල්ඩර ව්‍යුහය (Folder Structure)

App එක develop කිරීමේදී පහත Folder Structure එක `lib/` ෆෝල්ඩරය ඇතුලත භාවිතා කළ යුතුය.

```text
lib/
 ├── main.dart
 ├── app.dart
 ├── core/                    # (මුළු App එකටම පොදු දෑ)
 │    ├── constants/          # API endpoints, Strings
 │    ├── theme/              # App Colors, Fonts (Premium look)
 │    └── network/            # Dio HTTP Client configurations
 ├── models/                  # (Laravel එකෙන් එන දත්තවලට අදාල Dart Classes)
 │    ├── user_model.dart
 │    ├── course_model.dart
 │    └── mastery_model.dart
 ├── providers/               # (State Management - Riverpod/GetX)
 │    ├── auth_provider.dart
 │    ├── course_provider.dart
 │    └── tracking_provider.dart
 └── views/                   # (Screens සහ UIs)
      ├── auth/               # Login Screen
      ├── dashboard/          # Student Knowledge Radar Dashboard
      ├── courses/            # Lesson & PDF Viewers
      └── assessments/        # Quizzes & Assignment Upload UI
```

---

## 3. UI සහ UX නිර්මාණ ප්‍රමිතිය (Design Aesthetics)

App එක විවෘත කළ සැනින් "Premium" සහ "WOW" හැඟීමක් ගෙනදීමට පහත Design Guidelines භාවිතා කෙරේ:

1.  **Typography (අකුරු විලාසය):** System Default අකුරු වෙනුවට "Google Fonts" හි ඇති **'Inter'** හෝ **'Outfit'** Font එක භාවිතා කිරීම.
2.  **Color Palette (වර්ණ):** සාමාන්‍ය තද වර්ණ වෙනුවට, Glassmorphism සහ Soft Gradients යොදාගැනීම.
    *   Primary Gradient: Deep Purple සිට Soft Violet දක්වා.
    *   Dark Mode පවත්වා ගැනීම නිර්දේශ කෙරේ (Sleek Dark Theme).
3.  **Animations (සජීවිකරණ):** බටන් ඔබන විට සහ පිටු (Screens) මාරු වන විට Smooth Micro-animations (Hero transitions) භාවිතා කිරීම.

---

## 4. නිර්මාණය කෙරෙන ප්‍රධාන පිටු (Core Screens Flow)

1.  **Splash Screen & Login Screen:**
    *   Dynamic background එකක් සමඟ Login Interface එක.
    *   Email, Password ඇතුලත් කර Laravel Sanctum හරහා Token එක ගෙන Local Storage (SharedPreferences) හි සඟවා ගැනීම.

2.  **Student Home / Dashboard (Knowledge Hub):**
    *   ඉහළින්ම ළමයාගේ නම සහ පිළිගැනීම.
    *   **Knowledge Radar Chart:** පද්ධතියෙන් එන මාතෘකා අනුව ළමයා දක්ෂ කුමන කරුණු වලටද යන්න පෙන්වන සුන්දර ප්‍රස්ථාරය.
    *   සුළු Animations සහිතව "ඔබගේ දුර්වලතා" සහ අදාල පාඩම් Suggestion Cards වලින් පෙන්වීම.

3.  **Courses & Lessons Screen:**
    *   ළමයාගේ Modules ලැයිස්තුව.
    *   පාඩම Click කළ විට PDF එක හෝ Video එක App එක ඇතුලතම (In-app WebView / PDFViewer) දර්ශනය කිරීම.

4.  **Quiz Attempt Screen (Interactive):**
    *   කාලය (Timer) දුවන ලස්සන UI එකක්. (උදා: Circular Progress bar එකකින් තත්පර ගණන අඩුවීම පෙන්වීම).
    *   ප්‍රශ්නයෙන් ප්‍රශ්නයට යද්දී Smooth transition එකක් භාවිතා කිරීම.

5.  **Assignment Upload Screen:**
    *   ගුරුවරයා ලබාදී ඇති Marking Criteria (Rubrics) පැහැදිලිව පෙන්වීම.
    *   "Drag & Drop" හෝ File picker එකක් මගින් ෆෝන් එකෙ ඇති PDF එක අප්ලෝඩ් කිරීම.
