# ميزان V12 — مكتب فريد حسام عبدالهادي

تطبيق Flutter عربي RTL لإدارة مكتب المحاماة والعميل، متصل بـ Supabase.

## الوظائف
- تسجيل دخول وإنشاء حساب عميل.
- لوحة مكتب للمحامي/الإداري.
- العملاء والقضايا والجلسات.
- الإشعارات.
- مستندات القضايا ورفعها إلى Supabase Storage الخاص.
- واجهة العميل لمتابعة القضايا والمواعيد والإشعارات والمستندات.

## إعداد Supabase
نفّذ ملف `supabase_schema_v8.sql` كاملًا في SQL Editor. الملف متوافق مع النسخ السابقة ويضيف `profiles.role` و`public.is_staff()` إذا لم يكونا موجودين، ويجهز Storage والمستندات والإشعارات.

بعد التنفيذ، يمكن التحقق من حساب المحامي:

```sql
select id, email from auth.users where email='fareedhosam983@gmail.com';
select id, full_name, role from public.profiles
where id=(select id from auth.users where email='fareedhosam983@gmail.com');
```

## بناء APK من GitHub
يوجد Workflow جاهز في `.github/workflows/android-apk.yml`.
من GitHub افتح **Actions → Mizan Android APK → Run workflow**.
بعد نجاح البناء افتح الـArtifact باسم `mizan-release-apk` ونزّل `app-release.apk`.

> لا ترفع أي Service Role key داخل التطبيق. المفتاح الموجود في `main.dart` هو Publishable/Client key فقط.
