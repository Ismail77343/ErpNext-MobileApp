// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String appMenu(Object appName) {
    return '$appName Menu';
  }

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get systemLanguage => 'System language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get urdu => 'Urdu';

  @override
  String get bengali => 'Bengali';

  @override
  String get navHome => 'Home';

  @override
  String get navProjects => 'Projects';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navSales => 'Sales';

  @override
  String get navPurchases => 'Purchases';

  @override
  String get navAi => 'AI';

  @override
  String get navSmartAdvisor => 'Smart Advisor';

  @override
  String get drawerTaskFollowUps => 'Task Follow Ups';

  @override
  String get drawerHumanResources => 'Human Resources';

  @override
  String get drawerStores => 'Stores';

  @override
  String get drawerUpdateApp => 'Update App';

  @override
  String get drawerDownloadLatestVersion => 'Download latest version';

  @override
  String get drawerLogout => 'Logout';

  @override
  String get couldNotOpenUpdateLink => 'Could not open update link';

  @override
  String get authSignInToContinue => 'Sign in to continue';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authLogin => 'Login';

  @override
  String get authLoginFailed => 'Login failed';

  @override
  String get homeWelcomeBack => 'Welcome Back';

  @override
  String get homeSalesSubtitle => 'Open sales cards';

  @override
  String get homeProjectsSubtitle => 'Go to all projects';

  @override
  String get homeHrSubtitle => 'Attendance check-in and check-out';

  @override
  String get homeStoresSubtitle =>
      'Material handover pickup, delivery, and returns';

  @override
  String get homeMyProjects => 'My Projects';

  @override
  String get homeNoProjectsFound => 'No projects found';

  @override
  String get homeShowAllProjects => 'Show all projects';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonUpdate => 'Update';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonProcessing => 'Processing...';

  @override
  String get commonSaving => 'Saving...';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonFailed => 'Failed';

  @override
  String get actionPleaseWait => 'Please wait, this may take a moment.';

  @override
  String createdSuccessfully(Object name) {
    return '$name created successfully';
  }

  @override
  String failedToLoad(Object reason) {
    return 'Failed to load $reason';
  }

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get salesTitle => 'Sales';

  @override
  String get salesLeads => 'Leads';

  @override
  String get salesLeadsSubtitle => 'Potential customers and contacts';

  @override
  String get salesOpportunities => 'Opportunities';

  @override
  String get salesOpportunitiesSubtitle => 'Open sales opportunities';

  @override
  String get salesQuotations => 'Quotations';

  @override
  String get salesQuotationsSubtitle => 'Sales quotations overview';

  @override
  String get storesTitle => 'Stores';

  @override
  String get storesMode => 'Stores Mode';

  @override
  String get storesHeroDescription =>
      'Document material pickup, delivery, and returns with photo evidence.';

  @override
  String get storesServices => 'Stores Services';

  @override
  String get storesMaterialTransferHandover => 'Material Transfer Handover';

  @override
  String get storesMaterialTransferSubtitle =>
      'Confirm pickup, delivery, and return unused material.';

  @override
  String get storesStockBalance => 'Stock Balance';

  @override
  String get storesStockBalanceSubtitle =>
      'View item availability by warehouse.';

  @override
  String get storesStockRequests => 'Stock Requests';

  @override
  String get storesStockRequestsSubtitle =>
      'Request materials for projects and operations.';

  @override
  String get storesStockReports => 'Stock Reports';

  @override
  String get storesStockReportsSubtitle =>
      'Review transfers, returns, and consumption reports.';

  @override
  String get hrTitle => 'Human Resources';

  @override
  String get hrMode => 'HR Mode';

  @override
  String get hrHeroDescription =>
      'Start with attendance today. More employee services are ready to plug in next.';

  @override
  String get hrServices => 'HR Services';

  @override
  String get hrAttendance => 'Attendance';

  @override
  String get hrAttendanceReadySubtitle =>
      'Clock in and out with approved device and GPS.';

  @override
  String get hrAttendanceApprovalRequiredSubtitle =>
      'Mobile device approval is required before attendance.';

  @override
  String get hrLeaveRequest => 'Leave Request';

  @override
  String get hrLeaveRequestSubtitle =>
      'Request annual, sick, or emergency leave.';

  @override
  String get hrAttendanceLog => 'Attendance Log';

  @override
  String get hrAttendanceLogSubtitle =>
      'Review your daily clock in and clock out history.';

  @override
  String get hrAttendanceReport => 'Attendance Report';

  @override
  String get hrAttendanceReportSubtitle =>
      'View monthly attendance summaries and exceptions.';

  @override
  String get hrExportPdf => 'Export PDF';

  @override
  String get hrExportPdfSubtitle => 'Download attendance reports as PDF files.';

  @override
  String get hrVerifyMobileDevice => 'Verify Mobile Device';

  @override
  String get hrPhoneNumber => 'Phone Number';

  @override
  String get hrSendRequest => 'Send Request';

  @override
  String get hrDeviceVerificationSent =>
      'Device verification request sent. Please wait for HR approval.';

  @override
  String get hrDeviceVerificationRequestFailed =>
      'Unable to request device verification.';

  @override
  String get hrDeviceVerificationNotRequired =>
      'Mobile device verification is not required.';

  @override
  String get hrDeviceApproved => 'Device Approved';

  @override
  String get hrPendingApproval => 'Pending HR Approval';

  @override
  String get hrDeviceVerificationRequired => 'Device Verification Required';

  @override
  String hrStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get hrRequestVerification => 'Request Verification';

  @override
  String get hrRefreshStatus => 'Refresh Status';
}
