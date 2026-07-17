/// Purpose: Every user-facing string, in English, Somali and Arabic.
/// Responsibilities: Provide GetX Translations maps; NO hardcoded strings in UI.
/// Dependencies: get.
/// Usage: Text('common.save'.tr) — add every new key to ALL THREE maps.

import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': _en,
        'so': _so,
        'ar': _ar,
      };
}

const _en = {
  // App
  'app.name': 'Ganacsi',

  // Common
  'common.save': 'Save',
  'common.cancel': 'Cancel',
  'common.search': 'Search',
  'common.retry': 'Try again',
  'common.loading': 'Loading…',
  'common.settings': 'Settings',
  'common.language': 'Language',
  'common.dark_mode': 'Dark mode',
  'common.logout': 'Log out',

  // Authentication
  'auth.login': 'Log in',
  'auth.email': 'Email',
  'auth.password': 'Password',
  'auth.signout': 'Sign out',

  // Pending
  'auth.pending.title': 'Waiting for approval',
  'auth.pending.body':
      'Your business is being reviewed by Hanti ERP. We will notify you once the review is complete.',
  'auth.pending.refresh': 'Check status',

  // Errors
  'errors.auth':
      'Sign-in problem. Check your email and password.',
  'errors.permission_or_data':
      "You don't have permission for that, or the data was not found.",
  'errors.unexpected':
      'Something went wrong. Try again.',
  'errors.empty':
      'Nothing here yet',

  // Validation
  'validation.required': 'This field is required',
  'validation.email': 'Enter a valid email address',
  'validation.password_length': 'At least 8 characters',
  'validation.password_upper': 'Add an uppercase letter',
  'validation.password_lower': 'Add a lowercase letter',
  'validation.password_digit': 'Add a number',
  'validation.password_special': 'Add a special character',

  // Foundation
  'foundation.title': 'Foundation check',
  'foundation.subtitle':
      'Theme, language and Supabase are wired correctly.',
  'foundation.supabase_ok': 'Supabase connected',
  'foundation.supabase_fail': 'Supabase not reachable',
};

const _so = {
  // App
  'app.name': 'Ganacsi',

  // Common
  'common.save': 'Kaydi',
  'common.cancel': 'Ka noqo',
  'common.search': 'Raadi',
  'common.retry': 'Isku day mar kale',
  'common.loading': 'Waa la soo rarayaa…',
  'common.settings': 'Dejinta',
  'common.language': 'Luqadda',
  'common.dark_mode': 'Muuqaal madow',
  'common.logout': 'Ka bax',

  // Authentication
  'auth.login': 'Soo gal',
  'auth.email': 'Iimayl',
  'auth.password': 'Furaha sirta',
  'auth.signout': 'Ka bax',

  // Pending
  'auth.pending.title': 'Sug oggolaansho',
  'auth.pending.body':
      'Ganacsigaaga waxaa dib u eegaya Hanti ERP. Waxaan ku ogeysiin doonnaa marka dib u eegistu dhammaato.',
  'auth.pending.refresh': 'Hubi xaaladda',

  // Errors
  'errors.auth':
      'Dhibaato gelitaan. Hubi iimaylka iyo furaha sirta.',
  'errors.permission_or_data':
      'Uma lihid ogolaansho, ama xogta lama helin.',
  'errors.unexpected':
      'Khalad ayaa dhacay. Isku day mar kale.',
  'errors.empty':
      'Weli waxba ma jiraan',

  // Validation
  'validation.required': 'Goobtan waa qasab',
  'validation.email': 'Geli iimayl sax ah',
  'validation.password_length': 'Ugu yaraan 8 xaraf',
  'validation.password_upper': 'Ku dar xaraf weyn',
  'validation.password_lower': 'Ku dar xaraf yar',
  'validation.password_digit': 'Ku dar lambar',
  'validation.password_special': 'Ku dar calaamad gaar ah',

  // Foundation
  'foundation.title': 'Hubinta aasaaska',
  'foundation.subtitle':
      'Muuqaalka, luqadda iyo Supabase si sax ah ayay u shaqeynayaan.',
  'foundation.supabase_ok': 'Supabase wuu xiran yahay',
  'foundation.supabase_fail': 'Supabase lama gaari karo',
};

const _ar = {
  // App
  'app.name': 'غنكسي',

  // Common
  'common.save': 'حفظ',
  'common.cancel': 'إلغاء',
  'common.search': 'بحث',
  'common.retry': 'إعادة المحاولة',
  'common.loading': 'جارٍ التحميل…',
  'common.settings': 'الإعدادات',
  'common.language': 'اللغة',
  'common.dark_mode': 'الوضع الداكن',
  'common.logout': 'تسجيل الخروج',

  // Authentication
  'auth.login': 'تسجيل الدخول',
  'auth.email': 'البريد الإلكتروني',
  'auth.password': 'كلمة المرور',
  'auth.signout': 'تسجيل الخروج',

  // Pending
  'auth.pending.title': 'بانتظار الموافقة',
  'auth.pending.body':
      'تتم مراجعة نشاطك التجاري بواسطة Hanti ERP. سنقوم بإشعارك عند اكتمال المراجعة.',
  'auth.pending.refresh': 'تحقق من الحالة',

  // Errors
  'errors.auth':
      'مشكلة في تسجيل الدخول. تحقق من البريد وكلمة المرور.',
  'errors.permission_or_data':
      'ليست لديك صلاحية، أو لم يتم العثور على البيانات.',
  'errors.unexpected':
      'حدث خطأ ما. حاول مرة أخرى.',
  'errors.empty':
      'لا يوجد شيء هنا بعد',

  // Validation
  'validation.required': 'هذا الحقل مطلوب',
  'validation.email': 'أدخل بريدًا إلكترونيًا صحيحًا',
  'validation.password_length': '٨ أحرف على الأقل',
  'validation.password_upper': 'أضف حرفًا كبيرًا',
  'validation.password_lower': 'أضف حرفًا صغيرًا',
  'validation.password_digit': 'أضف رقمًا',
  'validation.password_special': 'أضف رمزًا خاصًا',

  // Foundation
  'foundation.title': 'فحص الأساس',
  'foundation.subtitle':
      'المظهر واللغة وSupabase تعمل بشكل صحيح.',
  'foundation.supabase_ok': 'Supabase متصل',
  'foundation.supabase_fail': 'تعذر الوصول إلى Supabase',
};