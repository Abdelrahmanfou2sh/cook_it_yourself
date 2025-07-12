# Cook It Yourself

تطبيق وصفات طبخ يساعدك على اكتشاف وصفات جديدة وتعلم كيفية تحضيرها بنفسك.

## المميزات

### 🍳 الوصفات
- استعراض مجموعة متنوعة من وصفات الطبخ
- البحث عن وصفات محددة
- البحث بالمكونات المتوفرة لديك
- تصفية الوصفات حسب نوع المطبخ
- اقتراحات ذكية للوصفات بناءً على الوقت من اليوم

### 👤 المصادقة
- إنشاء حساب جديد
- تسجيل الدخول بالبريد الإلكتروني
- تحديث الملف الشخصي
- تغيير كلمة المرور
- إعادة تعيين كلمة المرور

### 🎨 واجهة المستخدم
- وضع الظلام (Dark Mode)
- تصميم عصري وسهل الاستخدام
- واجهة سلسة ومتجاوبة

## التقنيات المستخدمة

### 🎯 الواجهة الأمامية
- Flutter
- Cubit (إدارة الحالة)
- Infinite Scroll Pagination
- Shared Preferences
- Flutter Native Splash

### 🔥 الخدمات السحابية
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Spoonacular API (لبيانات الوصفات)

### 🏗️ الهيكل التنظيمي
- Clean Architecture
- SOLID Principles
- Dependency Injection
- Repository Pattern

## التثبيت

### 📋 المتطلبات الأساسية
1. تأكد من تثبيت Flutter على جهازك
2. قم بإنشاء مشروع Firebase جديد وتهيئة:
   - Firebase Authentication
   - Cloud Firestore
   - Firebase Storage
3. احصل على مفتاح API من [Spoonacular](https://spoonacular.com/food-api)

### 🚀 خطوات التثبيت
1. استنسخ هذا المستودع:
   ```bash
   git clone https://github.com/your-username/cook-it-yourself.git
   cd cook-it-yourself
   ```

2. قم بتثبيت التبعيات:
   ```bash
   flutter pub get
   ```

3. قم بتهيئة Firebase في المشروع:
   - أضف ملف `google-services.json` إلى مجلد `android/app`
   - أضف ملف `GoogleService-Info.plist` إلى مجلد `ios/Runner`
   - قم بتحديث `firebase_options.dart` بمعلومات مشروعك

4. قم بإنشاء ملف `.env` في المجلد الرئيسي وأضف مفتاح Spoonacular API:
   ```
   SPOONACULAR_API_KEY=your_api_key_here
   ```

5. قم بتشغيل التطبيق:
    ```bash
    flutter run
    ```
