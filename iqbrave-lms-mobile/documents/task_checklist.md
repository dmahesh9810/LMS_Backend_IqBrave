# Flutter Mobile App Development - Task Checklist (IQBrave LMS)

අපගේ Mobile App එකෙහි වැඩකටයුතු පිළිවෙලින් අවසන් කිරීම සඳහා මෙම ලැයිස්තුව භාවිතා කළ හැක. පියවරෙන් පියවර මේවා අවසන් වන විට මා විසින් `[x]` ලෙස යාවත්කාලීන කරනු ඇත.

## 1. Project Initialization & Setup
- [x] අලුත් Flutter Project එකක් නිර්මාණය කිරීම (`flutter create .`).
- [x] අවශ්‍ය වන මූලික Packages ලැයිස්තුව `pubspec.yaml` එකට දැමීම (`flutter_riverpod`, `dio`, `shared_preferences`, `google_fonts`, `fl_chart`).
- [x] Blueprint එකෙහි ඇති ආකාරයට `lib` ෆෝල්ඩරය යටතේ නිවැරදි Folder Structure එක (models, views, controllers, core) සැකසීම.

## 2. Core Theme & Configurations
- [x] App එකට අදාල අලුත් වර්ණ (Colors) සහ "Inter" Font එක යොදා Global Theme එක (Premium Glassmorphism Style) සකස් කිරීම.
- [x] Laravel Server එකට කතා කිරීමට `Dio` (HTTP client) එක අවශ්‍ය Configurations සමඟ ලිවීම (Base URL සකස් කිරීම).

## 3. Authentication Module
- [x] `user_model.dart` සහ `auth_provider.dart` සෑදීම.
- [x] Splash Screen එක සහ ලස්සන UI එකක් සහිත Login Screen එක නිර්මාණය කිරීම.
- [x] API එකෙන එන Token එක Local Device එකේ (Secure Storage/Prefs) save කරගෙන ඊළඟ වතාවේදී කෙලින්ම Dashboard එකට යන පරිදි සැකසීම.

## 4. Knowledge Tracking Dashboard
- [x] ශිෂ්‍යයාගේ නම සහ පිළිගැනීමේ වාක්‍යය සහිත Home Screen UI එක සෑදීම.
- [x] `fl_chart` භාවිතයෙන් Radar Chart (Spider Chart) එක අඳින Custom Widget එක සෑදීම (`radar_chart_widget.dart`).
- [x] Backend API (`/knowledge/mastery`) එකෙන් දත්ත ලබාගෙන Radar Chart එකට ලබා දීමට `knowledge_provider.dart` ලිවීම.
- [x] දුර්වලම විෂය කරුණු පෙන්වන "Focus Areas" section එක නිර්මාණය කිරීම.

## 5. Courses & Lessons Module
- [x] ළමයාගේ Courses/Modules පෙන්වන Screen එක නිර්මාණය කිරීම.
- [x] අදාල Course එකේ Video සහ PDF Materials පෙන්වන Lesson Detail Screen එක හැදීම. (PDF හෝ Videos වෙනුවෙන් අවශ්‍ය UI).

## 6. Assessments Module (Quizzes & Assignments)
- [x] **Quiz UI:** Timer (කාලය) එකක් සහිතව ප්‍රශ්න එකින් එක දර්ශනය වන සහ උත්තර තෝරන Screen එක හදලා, අවසානයේදී results submit කිරීමේ ක්‍රියාවලිය ලිවීම.
- [x] **Assignments UI:** ගුරුවරයා දෙන Rubrics/Criteria පෙන්වා, දුරකථනයෙන් PDF File එකක් අරගෙන Upload කිරීමේ ක්‍රියාවලිය ලිවීම.

## 7. App Review & Final Polish
- [ ] App එක පුරාම Button/Screen transition Animations තවදුරටත් ලස්සන කිරීම (Micro-animations).
- [ ] සියලුම Screen වල Errors (උදා: internet නැතිවිට පෙනෙන Screens) නිවැරදි කිරීම.
