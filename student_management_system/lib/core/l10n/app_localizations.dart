import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

class AppLocalizations {
  final String locale; // 'ar' or 'en'
  AppLocalizations(this.locale);

  bool get isEn => locale == 'en';

  // ───────────── COMMON ─────────────
  String get cancel => isEn ? 'Cancel' : 'إلغاء';
  String get save => isEn ? 'Save' : 'حفظ';
  String get close => isEn ? 'Close' : 'إغلاق';
  String get ok => isEn ? 'OK' : 'حسنا';
  String get required => isEn ? 'Required' : 'مطلوب';
  String errorOccurred(String err) =>
      isEn ? 'An error occurred: $err' : 'حدث خطأ: $err';
  String get loading => isEn ? 'Loading...' : 'جاري التحميل...';
  String get studentManagementSystem =>
      isEn ? 'Student Management System' : 'نظام إدارة الطلاب';

  // ───────────── HOME SCREEN ─────────────
  String get welcome => isEn ? 'Welcome!' : 'مرحباً بك!';
  String get quickStats => isEn ? 'Quick Statistics' : 'إحصائيات سريعة';
  String presentCountToday(int count) => isEn
      ? '$count students marked present today'
      : 'تم تسجيل حضور $count طالب اليوم';

  String get registerStudent => isEn ? 'Register Student' : 'تسجيل طالب';
  String get registerStudentSub =>
      isEn ? 'Add a new student to the system' : 'إضافة طالب جديد للنظام';

  String get recordAttendance => isEn ? 'Record Attendance' : 'تسجيل الحضور';
  String get recordAttendanceSub =>
      isEn ? 'Track student attendance and absence' : 'رصد غياب وحضور الطلاب';

  String get studentDirectory => isEn ? 'Students Directory' : 'سجل الطلاب';
  String get studentDirectorySub =>
      isEn ? 'View all students data' : 'عرض بيانات جميع الطلاب';

  String get settings => isEn ? 'Settings' : 'الإعدادات';
  String get settingsSub =>
      isEn ? 'Customize app settings' : 'تخصيص إعدادات التطبيق';

  String get importExport => isEn ? 'Import & Export' : 'استيراد وتصدير';
  String get importExportSub =>
      isEn ? 'Manage data and files' : 'إدارة البيانات والملفات';

  String get analytics => isEn ? 'Analytics' : 'التحليلات';
  String get analyticsSub =>
      isEn ? 'Live statistics and reports' : 'إحصائيات وتقارير مباشرة';

  // ───────────── STUDENT LIST SCREEN ─────────────
  String get searchById =>
      isEn ? 'Search by ID...' : 'البحث عن طريق الكود (ID)...';
  String gradeLabel(String grade) => isEn ? 'Grade $grade' : 'الصف $grade';
  String get studentDetails => isEn ? 'Student Details' : 'بيانات الطالب';
  String get name => isEn ? 'Name' : 'الاسم';
  String get id => isEn ? 'ID' : 'ID';
  String get grade => isEn ? 'Grade' : 'الصف';
  String get address => isEn ? 'Address' : 'العنوان';
  String get whatsapp => isEn ? 'WhatsApp' : 'واتساب';
  String get mobile => isEn ? 'Mobile' : 'الموبايل';
  String get whatsappFollowup =>
      isEn ? 'WhatsApp Follow-up Message' : 'رسالة افتقاد واتساب';

  String whatsappMessage(String name) {
    final firstName = name.split(' ')[0];
    return "سلام ونعمة من حصة صموئيل النبى. كنا مستنينك النهاردة يا $firstName افتقدناك النهارده، نتمنى تكون بخير ونشوفك المرة الجاية!🙏";
  }

  String get attendanceDate => isEn ? 'Date' : 'التاريخ';
  String get notesOptional => isEn ? 'Notes (Optional)' : 'ملاحظات (اختياري)';
  String get classLabel => isEn ? 'Class' : 'حصة';
  String get classExcuse => isEn ? 'Class Excuse' : 'اعتذار حصة';
  String get theDivineLiturgyLabel => isEn ? 'The Divine Liturgy' : 'قداس';
  String get theDivineLiturgyExcuse =>
      isEn ? 'The Divine Liturgy Excuse' : 'اعتذار قداس';
  String get recordingAttendance => isEn ? 'Recording...' : 'جاري التسجيل...';
  String get attendanceRecordedSuccess =>
      isEn ? 'Recorded successfully! ✅' : 'تم التسجيل بنجاح! ✅';
  String get attendanceRecordedFailed =>
      isEn ? 'Failed to record ❌' : 'فشل التسجيل ❌';

  // ───────────── REGISTER STUDENT SCREEN ─────────────
  String get registerNewStudent =>
      isEn ? 'Register New Student' : 'تسجيل طالب جديد';
  String get basicInfo => isEn ? 'Basic Information' : 'المعلومات الأساسية';
  String get fullName => isEn ? 'Full Name' : 'الاسم بالكامل';
  String get enterNamePrompt =>
      isEn ? 'Please enter the name' : 'برجاء ادخال الاسم';
  String get gradeSelect => isEn ? 'Grade' : 'المرحلة';
  String gradeItem(String g) => isEn ? 'Grade $g' : 'صف $g';
  String get status => isEn ? 'Status' : 'الحالة';
  String get yes => isEn ? 'Yes' : 'نعم';
  String get no => isEn ? 'No' : 'لا';
  String get girl => isEn ? 'Girl' : 'بنت';
  String get contactInfo => isEn ? 'Contact Information' : 'معلومات الاتصال';
  String get additions => isEn ? 'Additional' : 'إضافات';
  String get notes => isEn ? 'Notes' : 'ملحوظات';
  String get saveData => isEn ? 'Save Data' : 'حفظ البيانات';
  String get phoneValidationMatch => isEn
      ? 'Must be 11 digits starting with 01'
      : 'يجب أن يكون 11 رقم ويبدأ بـ 01';
  String get registerSuccess =>
      isEn ? 'Student registered successfully ✅' : 'تم تسجيل الطالب بنجاح ✅';
  String get registerFailed =>
      isEn ? 'Error during registration ❌' : 'حدث خطأ أثناء التسجيل ❌';

  // ───────────── IMPORT / EXPORT SCREEN ─────────────
  String get importExportTitle =>
      isEn ? 'Import & Export Data' : 'استيراد وتصدير البيانات';
  String get importExcel => isEn ? 'Import from Excel' : 'استيراد من Excel';
  String get importExcelSub => isEn
      ? 'Add a group of students from an external file'
      : 'إضافة مجموعة طلاب من ملف خارجي';
  String get exportExcel => isEn ? 'Export to Excel' : 'تصدير إلى Excel';
  String get exportExcelSub => isEn
      ? 'Save student list and attendance to a file'
      : 'حفظ قائمة الطلاب والغياب في ملف';
  String get nameFileTitle => isEn ? 'Name File' : 'تسمية الملف';
  String get nameFilePrompt => isEn
      ? 'Enter the name of the Excel file to export'
      : 'أدخل اسم ملف Excel المراد تصديره';
  String get enterFileNameError =>
      isEn ? 'Please enter a file name' : 'الرجاء إدخال اسم الملف';
  String get fileNameHint => isEn ? 'File Name' : 'اسم الملف';
  String get exportBtn => isEn ? 'Export' : 'تصدير';
  String get fileEmptyError => isEn
      ? 'File is empty or invalid format'
      : 'الملف فارغ أو بتنسيق غير صحيح';
  String get importOptionsTitle => isEn ? 'Import Options' : 'خيارات الاستيراد';
  String importFoundPrompt(int count) => isEn
      ? 'Found $count students. How do you want to import them?'
      : 'تم العثور على $count طالب. كيف تريد استيرادهم؟';
  String get addToCurrent =>
      isEn ? 'Add to existing data' : 'إضافة للبيانات الحالية';
  String get replaceAll =>
      isEn ? 'Replace all (Clear existing)' : 'استبدال الكل (مسح الحالي)';
  String fileSelectError(String e) =>
      isEn ? 'Error selecting file: $e' : 'خطأ أثناء اختيار الملف: $e';
  String get importing => isEn ? 'Importing...' : 'جاري الاستيراد...';
  String get importSuccess =>
      isEn ? 'Imported successfully! ✅' : 'تم الاستيراد بنجاح! ✅';
  String get importFailed => isEn
      ? 'Import failed ❌ (Check error log)'
      : 'فشل الاستيراد ❌ (راجع سجل الأخطاء)';
  String get preparingExcel =>
      isEn ? 'Preparing Excel file...' : 'جاري تحضير ملف Excel...';
  String get noStudentsToExport =>
      isEn ? 'No students to export' : 'لا يوجد طلاب لتصديرهم';
  String get exportSuccess =>
      isEn ? 'Exported successfully! ✅' : 'تم تصدير الملف بنجاح! ✅';
  String exportFailed(String e) =>
      isEn ? 'Export failed: $e' : 'فشل التصدير: $e';

  // ───────────── ANALYTICS SCREEN ─────────────
  String get analyticsHeader => isEn ? '📊 Analytics' : '📊 التحليلات';
  String get dayPrefix => isEn ? 'Day:' : 'يوم:';
  String get today => isEn ? 'Today' : 'النهارده';

  String dayName(int weekday) {
    if (isEn) {
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return days[weekday - 1];
    }
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[weekday - 1];
  }

  String get totalStudents => isEn ? 'Total Students' : 'إجمالي الطلاب';
  String get classAttendance => isEn ? 'Class Attendance' : 'حضور الحصة';
  String get theDivineLiturgyAttendance =>
      isEn ? 'The Divine Liturgy Attendance' : 'حضور القداس';
  String get attendanceRate => isEn ? 'Attendance Rate' : 'نسبة الحضور';
  String get activityDetails => isEn ? 'Activity Details' : 'تفاصيل النشاط';

  String get saturdayClassPresent =>
      isEn ? 'Saturday Class Attendance' : 'حضور حصة السبت';
  String get fridayTheDivineLiturgyPresent =>
      isEn ? 'Friday The Divine Liturgy Attendance' : 'حضور قداس الجمعة';
  String get saturdayClassExcuse =>
      isEn ? 'Saturday Class Excuse' : 'اعتذار عن حصة السبت';
  String get fridayTheDivineLiturgyExcuse =>
      isEn ? 'Friday The Divine Liturgy Excuse' : 'اعتذار عن قداس الجمعة';

  String get noAttendanceData => isEn
      ? 'No attendance data for this day'
      : 'لا توجد بيانات حضور لهذا اليوم';
  String get attendanceDistribution =>
      isEn ? 'Attendance Distribution' : 'توزيع الحضور';
  String get legendClassPresent => isEn ? 'Class Present' : 'حضور حصة';
  String get legendTheDivineLiturgyPresent =>
      isEn ? 'The Divine Liturgy Present' : 'حضور قداس';
  String get legendClassExcuse => isEn ? 'Class Excuse' : 'اعتذار حصة';
  String get legendTheDivineLiturgyExcuse =>
      isEn ? 'The Divine Liturgy Excuse' : 'اعتذار قداس';

  String get classAttendanceRate =>
      isEn ? 'Class Attendance Rate' : 'نسبة حضور الحصة';
  String get theDivineLiturgyAttendanceRate =>
      isEn ? 'The Divine Liturgy Attendance Rate' : 'نسبة حضور القداس';

  String absentTheDivineLiturgyWarning(int count) => isEn
      ? 'Absent from The Divine Liturgy without excuse ($count)'
      : 'اللي ماجوش قداس منغير عذر ($count)';
  String absentClassWarning(int count) => isEn
      ? 'Absent from Class without excuse ($count)'
      : 'اللي ماحضروش حصة منغير عذر ($count)';

  String get theDivineLiturgyExcusesTitle =>
      isEn ? 'The Divine Liturgy Excuses' : 'اعذار القداس';
  String get classExcusesTitle => isEn ? 'Class Excuses' : 'اعذار الحصة';
  String get noExcuses => isEn ? 'No excuses' : 'لا توجد اعتذارات';
  String get excuseDetails => isEn ? 'Excuse Details' : 'تفاصيل الاعتذار';
  String get student => isEn ? 'Student' : 'الطالب';

  // ───────────── SETTINGS SCREEN ─────────────
  String get settingsTitle => isEn ? 'Settings' : 'الإعدادات';

  String get language => isEn ? 'Language' : 'اللغة';
  String get languageAr => isEn ? 'Arabic' : 'العربية';
  String get languageEn => isEn ? 'English' : 'English';
  String get langName => isEn ? 'English' : 'العربية';

  String get serverConfig => isEn ? 'Server Configuration' : 'الخادم (Server)';
  String get aboutApp => isEn ? 'About App' : 'عن التطبيق';
  String get aboutAppSub => isEn ? 'Version 1.0.0' : 'الإصدار 1.0.0';
  String get appVersion => aboutAppSub;
  String get appTitle => studentManagementSystem;
  String get appDescription => aboutDescription;

  String get chooseAppearance => isEn ? 'Choose Appearance' : 'اختر المظهر';
  String get chooseLanguage => isEn ? 'Choose Language' : 'اختر اللغة';
  String get serverConfigTitle =>
      isEn ? 'Server Configuration' : 'إعدادات الخادم (Server)';
  String get enterServerUrlPrompt => isEn
      ? 'Enter the Google Apps Script Web App URL:'
      : 'أدخل رابط تطبيق Google Apps Script:';
  String get enterServerUrl => enterServerUrlPrompt;
  String get resetDefault => isEn ? 'Reset Default' : 'إعادة ضبط للافتراضي';
  String get serverResetSuccess => isEn
      ? 'Server URL reset to default successfully'
      : 'تمت إعادة ضبط رابط الخادم للافتراضي بنجاح';
  String get serverSaveSuccess =>
      isEn ? 'Server URL saved successfully' : 'تم حفظ رابط الخادم بنجاح';
  String get aboutDescription => isEn
      ? 'A comprehensive application for managing student registration, attendance, and instant analytical reports.'
      : 'تطبيق متكامل لإدارة تسجيل الطلاب ورصد الحضور والغياب وتقديم تقارير تحليلية فورية.';
}

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final settings = ref.watch(settingsProvider);
  return AppLocalizations(settings.language);
});
