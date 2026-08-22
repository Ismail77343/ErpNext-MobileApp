import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appMenu.
  ///
  /// In en, this message translates to:
  /// **'{appName} Menu'**
  String appMenu(Object appName);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// No description provided for @navPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get navPurchases;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAi;

  /// No description provided for @navSmartAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Smart Advisor'**
  String get navSmartAdvisor;

  /// No description provided for @drawerTaskFollowUps.
  ///
  /// In en, this message translates to:
  /// **'Task Follow Ups'**
  String get drawerTaskFollowUps;

  /// No description provided for @drawerHumanResources.
  ///
  /// In en, this message translates to:
  /// **'Human Resources'**
  String get drawerHumanResources;

  /// No description provided for @drawerStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get drawerStores;

  /// No description provided for @drawerUpdateApp.
  ///
  /// In en, this message translates to:
  /// **'Update App'**
  String get drawerUpdateApp;

  /// No description provided for @drawerDownloadLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'Download latest version'**
  String get drawerDownloadLatestVersion;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// No description provided for @couldNotOpenUpdateLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open update link'**
  String get couldNotOpenUpdateLink;

  /// No description provided for @authSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSignInToContinue;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get authLoginFailed;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get homeWelcomeBack;

  /// No description provided for @homeSalesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open sales cards'**
  String get homeSalesSubtitle;

  /// No description provided for @homeProjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go to all projects'**
  String get homeProjectsSubtitle;

  /// No description provided for @homeHrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance check-in and check-out'**
  String get homeHrSubtitle;

  /// No description provided for @homeStoresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Material handover pickup, delivery, and returns'**
  String get homeStoresSubtitle;

  /// No description provided for @homeMyProjects.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get homeMyProjects;

  /// No description provided for @homeNoProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get homeNoProjectsFound;

  /// No description provided for @homeShowAllProjects.
  ///
  /// In en, this message translates to:
  /// **'Show all projects'**
  String get homeShowAllProjects;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get commonProcessing;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get commonSaving;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get commonFailed;

  /// No description provided for @actionPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait, this may take a moment.'**
  String get actionPleaseWait;

  /// No description provided for @createdSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} created successfully'**
  String createdSuccessfully(Object name);

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load {reason}'**
  String failedToLoad(Object reason);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @salesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesTitle;

  /// No description provided for @salesLeads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get salesLeads;

  /// No description provided for @salesLeadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Potential customers and contacts'**
  String get salesLeadsSubtitle;

  /// No description provided for @salesOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get salesOpportunities;

  /// No description provided for @salesOpportunitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open sales opportunities'**
  String get salesOpportunitiesSubtitle;

  /// No description provided for @salesQuotations.
  ///
  /// In en, this message translates to:
  /// **'Quotations'**
  String get salesQuotations;

  /// No description provided for @salesQuotationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sales quotations overview'**
  String get salesQuotationsSubtitle;

  /// No description provided for @storesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get storesTitle;

  /// No description provided for @storesMode.
  ///
  /// In en, this message translates to:
  /// **'Stores Mode'**
  String get storesMode;

  /// No description provided for @storesHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Document material pickup, delivery, and returns with photo evidence.'**
  String get storesHeroDescription;

  /// No description provided for @storesServices.
  ///
  /// In en, this message translates to:
  /// **'Stores Services'**
  String get storesServices;

  /// No description provided for @storesMaterialTransferHandover.
  ///
  /// In en, this message translates to:
  /// **'Material Transfer Handover'**
  String get storesMaterialTransferHandover;

  /// No description provided for @storesMaterialTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm pickup, delivery, and return unused material.'**
  String get storesMaterialTransferSubtitle;

  /// No description provided for @storesStockBalance.
  ///
  /// In en, this message translates to:
  /// **'Stock Balance'**
  String get storesStockBalance;

  /// No description provided for @storesStockBalanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View item availability by warehouse.'**
  String get storesStockBalanceSubtitle;

  /// No description provided for @storesStockRequests.
  ///
  /// In en, this message translates to:
  /// **'Stock Requests'**
  String get storesStockRequests;

  /// No description provided for @storesStockRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request materials for projects and operations.'**
  String get storesStockRequestsSubtitle;

  /// No description provided for @storesStockReports.
  ///
  /// In en, this message translates to:
  /// **'Stock Reports'**
  String get storesStockReports;

  /// No description provided for @storesStockReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review transfers, returns, and consumption reports.'**
  String get storesStockReportsSubtitle;

  /// No description provided for @hrTitle.
  ///
  /// In en, this message translates to:
  /// **'Human Resources'**
  String get hrTitle;

  /// No description provided for @hrMode.
  ///
  /// In en, this message translates to:
  /// **'HR Mode'**
  String get hrMode;

  /// No description provided for @hrHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Start with attendance today. More employee services are ready to plug in next.'**
  String get hrHeroDescription;

  /// No description provided for @hrServices.
  ///
  /// In en, this message translates to:
  /// **'HR Services'**
  String get hrServices;

  /// No description provided for @hrAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get hrAttendance;

  /// No description provided for @hrAttendanceReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clock in and out with approved device and GPS.'**
  String get hrAttendanceReadySubtitle;

  /// No description provided for @hrAttendanceApprovalRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile device approval is required before attendance.'**
  String get hrAttendanceApprovalRequiredSubtitle;

  /// No description provided for @hrLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Leave Request'**
  String get hrLeaveRequest;

  /// No description provided for @hrLeaveRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request annual, sick, or emergency leave.'**
  String get hrLeaveRequestSubtitle;

  /// No description provided for @hrAttendanceLog.
  ///
  /// In en, this message translates to:
  /// **'Attendance Log'**
  String get hrAttendanceLog;

  /// No description provided for @hrAttendanceLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your daily clock in and clock out history.'**
  String get hrAttendanceLogSubtitle;

  /// No description provided for @hrAttendanceReport.
  ///
  /// In en, this message translates to:
  /// **'Attendance Report'**
  String get hrAttendanceReport;

  /// No description provided for @hrAttendanceReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View monthly attendance summaries and exceptions.'**
  String get hrAttendanceReportSubtitle;

  /// No description provided for @hrExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get hrExportPdf;

  /// No description provided for @hrExportPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download attendance reports as PDF files.'**
  String get hrExportPdfSubtitle;

  /// No description provided for @hrVerifyMobileDevice.
  ///
  /// In en, this message translates to:
  /// **'Verify Mobile Device'**
  String get hrVerifyMobileDevice;

  /// No description provided for @hrPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get hrPhoneNumber;

  /// No description provided for @hrSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get hrSendRequest;

  /// No description provided for @hrDeviceVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Device verification request sent. Please wait for HR approval.'**
  String get hrDeviceVerificationSent;

  /// No description provided for @hrDeviceVerificationRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to request device verification.'**
  String get hrDeviceVerificationRequestFailed;

  /// No description provided for @hrDeviceVerificationNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile device verification is not required.'**
  String get hrDeviceVerificationNotRequired;

  /// No description provided for @hrDeviceApproved.
  ///
  /// In en, this message translates to:
  /// **'Device Approved'**
  String get hrDeviceApproved;

  /// No description provided for @hrPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending HR Approval'**
  String get hrPendingApproval;

  /// No description provided for @hrDeviceVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Device Verification Required'**
  String get hrDeviceVerificationRequired;

  /// No description provided for @hrStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String hrStatusLabel(Object status);

  /// No description provided for @hrRequestVerification.
  ///
  /// In en, this message translates to:
  /// **'Request Verification'**
  String get hrRequestVerification;

  /// No description provided for @hrRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get hrRefreshStatus;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'bn', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
