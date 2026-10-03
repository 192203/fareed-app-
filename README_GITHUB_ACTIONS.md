# ميزان — GitHub Actions V11

هذه النسخة مجهزة لبناء APK من GitHub Actions بدون Codemagic.

## التشغيل
1. ارفع محتويات هذا المجلد إلى Repository في GitHub.
2. يجب أن يظهر الملف `.github/workflows/android-apk.yml`.
3. افتح Actions ثم `Mizan Android APK`.
4. اختر `Run workflow` أو ادفع Commit إلى فرع `main`.
5. بعد نجاح البناء افتح الـRun ثم قسم Artifacts وحمّل `mizan-release-apk`.

## مهم
- لا ترفع مفاتيح Supabase السرية أو service_role key.
- ملف `supabase_schema_v8.sql` هو مخطط قاعدة البيانات المستخدم في المشروع.
