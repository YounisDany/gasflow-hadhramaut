# GasFlow — ربط Firebase (خطوة بخطوة)

التطبيق صار **Firebase بالكامل**: مصادقة (Auth) + قاعدة بيانات لحظية (Firestore) + إشعارات (FCM) + تخزين (Storage).
الكود جاهز — تبقّى تربط **مشروعك** بأوامر بسيطة. التطبيق يبني حالياً بـ **0 أخطاء**.

---

## ما الذي أنجزته بالفعل (في الكود)
- حِزم Firebase في `pubspec.yaml` (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `firebase_storage`, `share_plus`).
- تهيئة Firebase في `lib/main.dart` + ربط المخزن اللحظي + طلب صلاحية الإشعارات.
- طبقة الخدمات في `lib/data/services/`: `auth_service.dart`, `messaging_service.dart`, `seed_service.dart`, `storage_service.dart`.
- `lib/data/store/app_store.dart` صار مدعوماً بـ Firestore (listeners + writes).
- إعداد Gradle لأندرويد: بلَجِن `com.google.gms.google-services` + `minSdk = 23`.
- قواعد الأمان: `firestore.rules` و `storage.rules`.
- دالة سحابية للإشعارات: `functions/index.js`.

---

## الخطوات المطلوبة منك (≈ ١٠ دقائق)

### 1) تثبيت الأدوات (مرة واحدة)
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
```

### 2) اربط المشروع وولّد الإعداد
من جذر المشروع:
```bash
flutterfire configure
```
- اختر مشروع Firebase حقّك.
- اختر منصتي **Android** و **iOS** (كلاهما مجهّز في المشروع).
- هذا الأمر:
  - يولّد `lib/firebase_options.dart`.
  - يضيف `android/app/google-services.json` تلقائياً.
  - يضيف `ios/Runner/GoogleService-Info.plist` تلقائياً.

> التطبيق يهيّئ Firebase عبر `Firebase.initializeApp()` (بدون options)، فيقرأ ملفات الإعداد الأصلية مباشرةً (`google-services.json` / `GoogleService-Info.plist`). فما يحتاج تعدّل `main.dart`.

> **مهم:** لازم `applicationId` في `android/app/build.gradle.kts` (حالياً `com.example.gas_app`) يطابق **اسم حزمة أندرويد** المسجّل في مشروعك على Firebase. إن اختلف، غيّر أحدهما ليتطابقا.

### 3) فعّل الخدمات في كونسول Firebase
- **Authentication** → Sign-in method → فعّل **Email/Password**.
- **Firestore Database** → Create database (Production mode).
- **Storage** → Get started.
- **Cloud Messaging** → مفعّل تلقائياً.

### 4) أنشئ حساب المشرف الثابت
في **Authentication → Users → Add user**:
- Email: `admin@gmail.com`
- Password: `12345678`

(التطبيق يعرف هذا الإيميل كمشرف تلقائياً. أول تسجيل دخول للمشرف يزرع بيانات تجريبية في Firestore.)

### 5) انشر قواعد الأمان
```bash
firebase deploy --only firestore:rules,storage
```
(أو الصقها يدوياً من `firestore.rules` و `storage.rules` في الكونسول.)

### 6) انشر دالة الإشعارات (FCM Push)
```bash
cd functions && npm install && cd ..
firebase deploy --only functions
```
بدونها تشتغل **الإشعارات داخل التطبيق** (صفحة الإشعارات + الشارة) عادي؛ الدالة فقط تضيف **Push** يوصل والتطبيق مقفل.

### 7) شغّل التطبيق
```bash
flutter run
```

---

## كيف تختبر التدفّق الكامل
1. **مشرف:** ادخل بـ `admin@gmail.com` / `12345678` → يزرع البيانات → وافِق على وكيل في «إدارة الوكلاء» → يصل إشعار.
2. **وكيل تجريبي:** سجّل حساب جديد واختر «وكيل» → يظهر للمشرف كطلب معلّق.
3. **مواطن:** سجّل حساب → أكمل البيانات → يظهر للوكيل في «طلبات العملاء» → الوكيل يقبله → يُولَّد رمز QR + يصل إشعار → اطلب غاز → تابِع الحالة (تتحرك مع قبول الوكيل).

---

## iOS (آيفون) 🍏
- **Bundle ID:** `com.example.gasApp` — لازم تسجّله بنفس الاسم كتطبيق iOS في مشروع Firebase (يسوّيه `flutterfire configure` تلقائياً).
- بعد `flutterfire configure`، ركّب الـ pods:
  ```bash
  cd ios && pod install && cd ..
  ```
  لو طلع خطأ ترميز (Ruby/CocoaPods):
  ```bash
  cd ios && LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install && cd ..
  ```
- شغّل على آيفون: افتح `ios/Runner.xcworkspace` في Xcode → اختر فريق التوقيع (Signing → Team) → شغّل، أو:
  ```bash
  flutter run -d <iphone-id>
  ```
- **إشعارات Push على iOS مؤجّلة** (تحتاج حساب Apple Developer + APNs Key). **الإشعارات داخل التطبيق** (صفحة الإشعارات + الشارة، لحظية عبر Firestore) **تشتغل عادي على iOS**. لتفعيل Push لاحقاً: ارفع APNs Key في Firebase ← Cloud Messaging، وأضف خاصية **Push Notifications** في Xcode ← Signing & Capabilities.

> الإعداد جاهز: `Podfile` على iOS 15، وInfo.plist فيه background modes للإشعارات.

---

## ملاحظات
- **الإشعارات حالياً تُبثّ للجميع** (broadcast). للتوجيه لمستخدم محدّد: استخدم حقل `to` في وثيقة الإشعار وفلتر التوكنات في `functions/index.js`.
- إن ظهرت السطور فارغة وطلع في الـ log `⚠️ Firebase init failed` → لم يكتمل `flutterfire configure` أو ناقص `google-services.json`.
- لتشديد قواعد الأمان قبل الإنتاج: راجِع `firestore.rules` (حالياً متساهلة لتسهيل التجربة).

---

## تحديثات هذه الجلسة (مطلوب منك في الكونسول) 🔧

### أ) تفعيل تسجيل الدخول عبر Google
الكود صار يستخدم تدفّق Google الحقيقي (`AuthService.signInWithGoogle()` عبر `signInWithProvider`). علشان يشتغل على جوالك لازم خطوتين في الكونسول:

1. **فعّل مزوّد Google:**
   - Firebase Console → مشروع `gas-app-f3481` → **Authentication → Sign-in method**.
   - اضغط **Google** → **Enable** → اختر *Project support email* → **Save**.

2. **أضف بصمة SHA-1 (وSHA-256) لتطبيق أندرويد:**
   - ولّد البصمة من جذر المشروع:
     ```bash
     cd android && ./gradlew signingReport
     ```
     (على ويندوز: `cd android; .\gradlew signingReport`) — انسخ سطر **SHA1** و**SHA-256** من إعداد `debug`.
   - في الكونسول → **Project settings (⚙️) → General → Your apps → تطبيق أندرويد** → **Add fingerprint** → الصق SHA-1 ثم SHA-256 → **Save**.
   - حمّل `google-services.json` المحدّث وضعه في `android/app/` (استبدل القديم)، ثم أعد البناء.

> بدون هاتين الخطوتين زر Google يطلع خطأ. زر Apple يبقى «سيتوفر قريباً» (يحتاج حساب Apple Developer).

### ب) قواعد Firestore (تم نشرها ✅)
- نشرتُ `firestore.rules` **مفتوحة بالكامل** (`allow read, write: if true`) لمشروع `gas-app-f3481` عبر:
  ```bash
  firebase deploy --only firestore:rules
  ```
- هذا يسمح للتطبيق ببذر البيانات وقراءتها بدون تسجيل دخول (وضع تجريبي مدرسي). **شدّدها قبل الإنتاج.**

### ج) الإشعارات
- **داخل التطبيق:** تشتغل لحظياً عبر Firestore (صفحة الإشعارات + الشارة) — جاهزة.
- **Push (والتطبيق مقفل):** انشر الدالة السحابية:
  ```bash
  cd functions && npm install && cd ..
  firebase deploy --only functions
  ```
  (تحتاج تفعيل الفوترة Blaze لتشغيل Cloud Functions. بدونها الإشعارات داخل التطبيق تكفي للعرض.)
