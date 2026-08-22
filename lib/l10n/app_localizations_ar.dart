// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String appMenu(Object appName) {
    return 'قائمة $appName';
  }

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختيار اللغة';

  @override
  String get languageUpdated => 'تم تحديث اللغة';

  @override
  String get systemLanguage => 'لغة النظام';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get urdu => 'الأردية';

  @override
  String get bengali => 'البنغالية';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navProjects => 'المشاريع';

  @override
  String get navTasks => 'المهام';

  @override
  String get navSales => 'المبيعات';

  @override
  String get navPurchases => 'المشتريات';

  @override
  String get navAi => 'الذكاء';

  @override
  String get navSmartAdvisor => 'المستشار الذكي';

  @override
  String get drawerTaskFollowUps => 'متابعات المهام';

  @override
  String get drawerHumanResources => 'الموارد البشرية';

  @override
  String get drawerStores => 'المخازن';

  @override
  String get drawerUpdateApp => 'تحديث التطبيق';

  @override
  String get drawerDownloadLatestVersion => 'تحميل أحدث إصدار';

  @override
  String get drawerLogout => 'تسجيل الخروج';

  @override
  String get couldNotOpenUpdateLink => 'تعذر فتح رابط التحديث';

  @override
  String get authSignInToContinue => 'سجّل الدخول للمتابعة';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authRememberMe => 'تذكرني';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authLoginFailed => 'فشل تسجيل الدخول';

  @override
  String get homeWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get homeSalesSubtitle => 'فتح بطاقات المبيعات';

  @override
  String get homeProjectsSubtitle => 'الانتقال إلى كل المشاريع';

  @override
  String get homeHrSubtitle => 'الحضور والانصراف';

  @override
  String get homeStoresSubtitle => 'استلام وتسليم وإرجاع المواد';

  @override
  String get homeMyProjects => 'مشاريعي';

  @override
  String get homeNoProjectsFound => 'لا توجد مشاريع';

  @override
  String get homeShowAllProjects => 'عرض كل المشاريع';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCreate => 'إنشاء';

  @override
  String get commonUpdate => 'تحديث';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonLoading => 'جاري التحميل...';

  @override
  String get commonProcessing => 'جاري التنفيذ...';

  @override
  String get commonSaving => 'جاري الحفظ...';

  @override
  String get commonSuccess => 'تم بنجاح';

  @override
  String get commonFailed => 'فشل';

  @override
  String get actionPleaseWait => 'يرجى الانتظار، قد تستغرق العملية قليلًا.';

  @override
  String createdSuccessfully(Object name) {
    return 'تم إنشاء $name بنجاح';
  }

  @override
  String failedToLoad(Object reason) {
    return 'فشل تحميل $reason';
  }

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get salesTitle => 'المبيعات';

  @override
  String get salesLeads => 'العملاء المحتملون';

  @override
  String get salesLeadsSubtitle => 'العملاء المحتملون وجهات الاتصال';

  @override
  String get salesOpportunities => 'الفرص';

  @override
  String get salesOpportunitiesSubtitle => 'فرص المبيعات المفتوحة';

  @override
  String get salesQuotations => 'عروض الأسعار';

  @override
  String get salesQuotationsSubtitle => 'نظرة عامة على عروض الأسعار';

  @override
  String get storesTitle => 'المخازن';

  @override
  String get storesMode => 'وضع المخازن';

  @override
  String get storesHeroDescription =>
      'توثيق استلام وتسليم وإرجاع المواد مع إثبات بالصور.';

  @override
  String get storesServices => 'خدمات المخازن';

  @override
  String get storesMaterialTransferHandover => 'تسليم تحويل المواد';

  @override
  String get storesMaterialTransferSubtitle =>
      'تأكيد الاستلام والتسليم وإرجاع المواد غير المستخدمة.';

  @override
  String get storesStockBalance => 'رصيد المخزون';

  @override
  String get storesStockBalanceSubtitle => 'عرض توفر الأصناف حسب المستودع.';

  @override
  String get storesStockRequests => 'طلبات المخزون';

  @override
  String get storesStockRequestsSubtitle => 'طلب المواد للمشاريع والعمليات.';

  @override
  String get storesStockReports => 'تقارير المخزون';

  @override
  String get storesStockReportsSubtitle =>
      'مراجعة التحويلات والإرجاعات وتقارير الاستهلاك.';

  @override
  String get hrTitle => 'الموارد البشرية';

  @override
  String get hrMode => 'وضع الموارد البشرية';

  @override
  String get hrHeroDescription =>
      'ابدأ بالحضور اليوم. المزيد من خدمات الموظفين جاهزة للإضافة لاحقًا.';

  @override
  String get hrServices => 'خدمات الموارد البشرية';

  @override
  String get hrAttendance => 'الحضور';

  @override
  String get hrAttendanceReadySubtitle =>
      'تسجيل الحضور والانصراف بجهاز معتمد و GPS.';

  @override
  String get hrAttendanceApprovalRequiredSubtitle =>
      'يجب اعتماد جهاز الجوال قبل تسجيل الحضور.';

  @override
  String get hrLeaveRequest => 'طلب إجازة';

  @override
  String get hrLeaveRequestSubtitle => 'طلب إجازة سنوية أو مرضية أو طارئة.';

  @override
  String get hrAttendanceLog => 'سجل الحضور';

  @override
  String get hrAttendanceLogSubtitle => 'مراجعة سجل الحضور والانصراف اليومي.';

  @override
  String get hrAttendanceReport => 'تقرير الحضور';

  @override
  String get hrAttendanceReportSubtitle =>
      'عرض ملخصات الحضور الشهرية والاستثناءات.';

  @override
  String get hrExportPdf => 'تصدير PDF';

  @override
  String get hrExportPdfSubtitle => 'تحميل تقارير الحضور كملفات PDF.';

  @override
  String get hrVerifyMobileDevice => 'توثيق جهاز الجوال';

  @override
  String get hrPhoneNumber => 'رقم الجوال';

  @override
  String get hrSendRequest => 'إرسال الطلب';

  @override
  String get hrDeviceVerificationSent =>
      'تم إرسال طلب توثيق الجهاز. يرجى انتظار موافقة الموارد البشرية.';

  @override
  String get hrDeviceVerificationRequestFailed =>
      'تعذر إرسال طلب توثيق الجهاز.';

  @override
  String get hrDeviceVerificationNotRequired => 'توثيق جهاز الجوال غير مطلوب.';

  @override
  String get hrDeviceApproved => 'الجهاز معتمد';

  @override
  String get hrPendingApproval => 'بانتظار موافقة الموارد البشرية';

  @override
  String get hrDeviceVerificationRequired => 'توثيق الجهاز مطلوب';

  @override
  String hrStatusLabel(Object status) {
    return 'الحالة: $status';
  }

  @override
  String get hrRequestVerification => 'طلب التوثيق';

  @override
  String get hrRefreshStatus => 'تحديث الحالة';
}
