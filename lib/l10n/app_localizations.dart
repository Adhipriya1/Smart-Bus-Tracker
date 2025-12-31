import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('ta')
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get support;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get reportBug;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get myDocuments;

  /// No description provided for @uploadDocs.
  ///
  /// In en, this message translates to:
  /// **'Upload License, Aadhar, PAN'**
  String get uploadDocs;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @manageFleet.
  ///
  /// In en, this message translates to:
  /// **'Manage your fleet and staff'**
  String get manageFleet;

  /// No description provided for @assignRoutes.
  ///
  /// In en, this message translates to:
  /// **'Assign Routes'**
  String get assignRoutes;

  /// No description provided for @verifyDocs.
  ///
  /// In en, this message translates to:
  /// **'Verify Docs'**
  String get verifyDocs;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @rideReviews.
  ///
  /// In en, this message translates to:
  /// **'Ride Reviews'**
  String get rideReviews;

  /// No description provided for @adminSettings.
  ///
  /// In en, this message translates to:
  /// **'Admin Settings'**
  String get adminSettings;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Bus Tracker'**
  String get appTitle;

  /// No description provided for @passengerLogin.
  ///
  /// In en, this message translates to:
  /// **'Passenger Login'**
  String get passengerLogin;

  /// No description provided for @conductorLogin.
  ///
  /// In en, this message translates to:
  /// **'Conductor Login'**
  String get conductorLogin;

  /// No description provided for @adminAccess.
  ///
  /// In en, this message translates to:
  /// **'Admin Access'**
  String get adminAccess;

  /// No description provided for @translateUserContent.
  ///
  /// In en, this message translates to:
  /// **'Translate user content'**
  String get translateUserContent;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @issueReportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Issue reported successfully! Support will contact you.'**
  String get issueReportedSuccess;

  /// No description provided for @itemLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item logged successfully!'**
  String get itemLoggedSuccess;

  /// No description provided for @thankYouForReport.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your report has been sent to the Admin team.'**
  String get thankYouForReport;

  /// No description provided for @thankYouForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  /// No description provided for @typeAMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessageHint;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessagesYet;

  /// No description provided for @sayHiToStart.
  ///
  /// In en, this message translates to:
  /// **'Say \'Hi\' to start!'**
  String get sayHiToStart;

  /// No description provided for @supportChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Chat'**
  String get supportChatTitle;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT REVIEW'**
  String get submitReview;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @sendSOS.
  ///
  /// In en, this message translates to:
  /// **'SEND SOS'**
  String get sendSOS;

  /// No description provided for @confirmEmergency.
  ///
  /// In en, this message translates to:
  /// **'Confirm emergency'**
  String get confirmEmergency;

  /// No description provided for @alertSent.
  ///
  /// In en, this message translates to:
  /// **'Admin has been notified with your location. Help is on the way.'**
  String get alertSent;

  /// No description provided for @errorSending.
  ///
  /// In en, this message translates to:
  /// **'Error sending: {error}'**
  String errorSending(Object error);

  /// No description provided for @logItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Log Lost Item'**
  String get logItemLabel;

  /// No description provided for @itemDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetailsLabel;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @subjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT REPORT'**
  String get submitReport;

  /// No description provided for @submitReportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your report has been sent.'**
  String get submitReportSuccess;

  /// No description provided for @noDescriptionProvided.
  ///
  /// In en, this message translates to:
  /// **'No Description provided.'**
  String get noDescriptionProvided;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @noActiveComplaints.
  ///
  /// In en, this message translates to:
  /// **'No active complaints!'**
  String get noActiveComplaints;

  /// No description provided for @resolvedNote.
  ///
  /// In en, this message translates to:
  /// **'✓  RESOLVED (Will auto-delete in 7 days)'**
  String get resolvedNote;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(Object error);

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(Object error);

  /// No description provided for @foundAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Found an issue?'**
  String get foundAnIssue;

  /// No description provided for @describeBug.
  ///
  /// In en, this message translates to:
  /// **'Please describe the bug so we can fix it.'**
  String get describeBug;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., App crashed on payment'**
  String get subjectHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Explain what happened...'**
  String get descriptionHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @commentsOptional.
  ///
  /// In en, this message translates to:
  /// **'Comments (Optional)'**
  String get commentsOptional;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogIn;

  /// No description provided for @myRides.
  ///
  /// In en, this message translates to:
  /// **'My Rides'**
  String get myRides;

  /// No description provided for @noRidesYet.
  ///
  /// In en, this message translates to:
  /// **'No rides yet.'**
  String get noRidesYet;

  /// No description provided for @completedTrip.
  ///
  /// In en, this message translates to:
  /// **'Completed Trip'**
  String get completedTrip;

  /// No description provided for @ongoingTrip.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Trip'**
  String get ongoingTrip;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @atLabel.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get atLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @languageMarathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get languageMarathi;

  /// No description provided for @languageTamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get languageTamil;

  /// No description provided for @myFrequentRoutes.
  ///
  /// In en, this message translates to:
  /// **'My Frequent Routes'**
  String get myFrequentRoutes;

  /// No description provided for @noTravelHistory.
  ///
  /// In en, this message translates to:
  /// **'No travel history'**
  String get noTravelHistory;

  /// No description provided for @pleaseSelectBusAndRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a bus and give a rating.'**
  String get pleaseSelectBusAndRating;

  /// No description provided for @rateYourRide.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Ride'**
  String get rateYourRide;

  /// No description provided for @whichBusWereYouOn.
  ///
  /// In en, this message translates to:
  /// **'Which bus were you on?'**
  String get whichBusWereYouOn;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasYourExperience;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Driver was polite, Bus was clean...'**
  String get reviewHint;

  /// No description provided for @pleaseSelectSourceDestination.
  ///
  /// In en, this message translates to:
  /// **'Please select Source and Destination'**
  String get pleaseSelectSourceDestination;

  /// No description provided for @tripFareCalculator.
  ///
  /// In en, this message translates to:
  /// **'Trip Fare Calculator'**
  String get tripFareCalculator;

  /// No description provided for @getRealtimeFare.
  ///
  /// In en, this message translates to:
  /// **'GET REALTIME FARE'**
  String get getRealtimeFare;

  /// No description provided for @seatsFree.
  ///
  /// In en, this message translates to:
  /// **'seats free'**
  String get seatsFree;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated Arrival'**
  String get estimatedArrival;

  /// No description provided for @whereAreYouGoing.
  ///
  /// In en, this message translates to:
  /// **'Where are you going today?'**
  String get whereAreYouGoing;

  /// No description provided for @topRoutes.
  ///
  /// In en, this message translates to:
  /// **'Top Routes'**
  String get topRoutes;

  /// No description provided for @noRoutesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No routes available.'**
  String get noRoutesAvailable;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @favoriteRoutes.
  ///
  /// In en, this message translates to:
  /// **'Favorite Routes'**
  String get favoriteRoutes;

  /// No description provided for @busTimetable.
  ///
  /// In en, this message translates to:
  /// **'Bus Timetable'**
  String get busTimetable;

  /// No description provided for @myRidesHistory.
  ///
  /// In en, this message translates to:
  /// **'My Rides History'**
  String get myRidesHistory;

  /// No description provided for @trackLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'TRACK LIVE LOCATION'**
  String get trackLiveLocation;

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get noNewNotifications;

  /// No description provided for @selectABus.
  ///
  /// In en, this message translates to:
  /// **'Select a Bus'**
  String get selectABus;

  /// No description provided for @noActiveBusesFound.
  ///
  /// In en, this message translates to:
  /// **'No active buses found.'**
  String get noActiveBusesFound;

  /// No description provided for @realTimeTimetable.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Timetable'**
  String get realTimeTimetable;

  /// No description provided for @noRoutesActive.
  ///
  /// In en, this message translates to:
  /// **'No routes active'**
  String get noRoutesActive;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route:'**
  String get routeLabel;

  /// No description provided for @tripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// No description provided for @estimatedFare.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED FARE'**
  String get estimatedFare;

  /// No description provided for @issueTicket.
  ///
  /// In en, this message translates to:
  /// **'Issue Ticket'**
  String get issueTicket;

  /// No description provided for @totalFare.
  ///
  /// In en, this message translates to:
  /// **'TOTAL FARE'**
  String get totalFare;

  /// No description provided for @seatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'seats available'**
  String get seatsAvailable;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in.'**
  String get mustBeLoggedIn;

  /// No description provided for @errorLoadingChat.
  ///
  /// In en, this message translates to:
  /// **'Error loading chat: {error}'**
  String errorLoadingChat(Object error);

  /// No description provided for @selectABusToViewLocation.
  ///
  /// In en, this message translates to:
  /// **'Select a bus to view location'**
  String get selectABusToViewLocation;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @pleaseUploadClearPhotos.
  ///
  /// In en, this message translates to:
  /// **'Please upload clear photos of your original documents. Admin will verify them shortly.'**
  String get pleaseUploadClearPhotos;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerification;

  /// No description provided for @notUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not Uploaded'**
  String get notUploaded;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @reupload.
  ///
  /// In en, this message translates to:
  /// **'Re-upload'**
  String get reupload;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @documentUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document Uploaded! Wait for verification.'**
  String get documentUploadedSuccess;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture Updated!'**
  String get profilePictureUpdated;

  /// No description provided for @selectBusNumber.
  ///
  /// In en, this message translates to:
  /// **'Select Bus Number'**
  String get selectBusNumber;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signupStart.
  ///
  /// In en, this message translates to:
  /// **'Sign up to start riding'**
  String get signupStart;

  /// No description provided for @loginToTrackYourBus.
  ///
  /// In en, this message translates to:
  /// **'Login to track your bus'**
  String get loginToTrackYourBus;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'Password must be 6+ chars'**
  String get passwordMinChars;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password Updated Successfully!'**
  String get passwordUpdated;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @errorLoadingBuses.
  ///
  /// In en, this message translates to:
  /// **'Error loading buses: {error}'**
  String errorLoadingBuses(Object error);

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error'**
  String get unexpectedError;
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
      <String>['en', 'hi', 'mr', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
