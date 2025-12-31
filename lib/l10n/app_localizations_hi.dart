// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get account => 'खाता';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get preferences => 'पसंदीदा';

  @override
  String get darkTheme => 'डार्क थीम';

  @override
  String get support => 'सहायता और कानूनी';

  @override
  String get reportBug => 'बग रिपोर्ट करें';

  @override
  String get terms => 'नियम और शर्तें';

  @override
  String get privacy => 'गोपनीयता नीति';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get myDocuments => 'मेरे दस्तावेज़';

  @override
  String get uploadDocs => 'लाइसेंस, आधार, पैन अपलोड करें';

  @override
  String get adminPortal => 'एडमिन पोर्टल';

  @override
  String get hello => 'नमस्ते';

  @override
  String get login => 'लॉग इन';

  @override
  String get signup => 'साइन अप';

  @override
  String get overview => 'अवलोकन';

  @override
  String get manageFleet => 'अपने बेड़े और कर्मचारियों का प्रबंधन करें';

  @override
  String get assignRoutes => 'रूट असाइन करें';

  @override
  String get verifyDocs => 'दस्तावेज़ सत्यापित करें';

  @override
  String get liveTracking => 'लाइव ट्रैकिंग';

  @override
  String get collections => 'संग्रह';

  @override
  String get complaints => 'शिकायतें';

  @override
  String get rideReviews => 'सवारी समीक्षा';

  @override
  String get adminSettings => 'एडमिन सेटिंग्स';

  @override
  String get session => 'सत्र';

  @override
  String get appTitle => 'स्मार्ट बस ट्रैकर';

  @override
  String get passengerLogin => 'यात्री लॉगिन';

  @override
  String get conductorLogin => 'कंडक्टर लॉगिन';

  @override
  String get adminAccess => 'प्रशासन लॉगिन';

  @override
  String get translateUserContent => 'उपयोगकर्ता सामग्री का अनुवाद करें';

  @override
  String get pleaseFillAllFields => 'कृपया सभी फ़ील्ड भरें';

  @override
  String get issueReportedSuccess =>
      'रिपोर्ट सफलतापूर्वक भेजी गई! सपोर्ट आपसे संपर्क करेगा।';

  @override
  String get itemLoggedSuccess => 'आइटम सफलतापूर्वक लॉग किया गया!';

  @override
  String get thankYouForReport =>
      'धन्यवाद! आपकी रिपोर्ट एडमिन टीम को भेज दी गई है।';

  @override
  String get thankYouForFeedback => 'प्रतिक्रिया के लिए धन्यवाद!';

  @override
  String get typeAMessageHint => 'संदेश टाइप करें...';

  @override
  String get noMessagesYet => 'कोई संदेश नहीं है।';

  @override
  String get sayHiToStart => 'शुरू करने के लिए \'हाय\' कहें!';

  @override
  String get supportChatTitle => 'सपोर्ट चैट';

  @override
  String get submitReview => 'समीक्षा सबमिट करें';

  @override
  String get close => 'बंद करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get sendSOS => 'SOS भेजें';

  @override
  String get confirmEmergency => 'आपातकाल की पुष्टि करें';

  @override
  String get alertSent =>
      'एडमिन को आपकी लोकेशन सूचित कर दी गई है। मदद आ रही है।';

  @override
  String errorSending(Object error) {
    return 'संदेश भेजने में त्रुटि: $error';
  }

  @override
  String get logItemLabel => 'खोया हुआ आइटम लॉग करें';

  @override
  String get itemDetailsLabel => 'आइटम विवरण';

  @override
  String get tapToAddPhoto => 'फोटो जोड़ने के लिए टैप करें';

  @override
  String get subjectLabel => 'विषय';

  @override
  String get descriptionLabel => 'विवरण';

  @override
  String get submitReport => 'रिपोर्ट सबमिट करें';

  @override
  String get submitReportSuccess => 'धन्यवाद! आपकी रिपोर्ट भेज दी गई है।';

  @override
  String get noDescriptionProvided => 'कोई विवरण प्रदान नहीं किया गया है।';

  @override
  String get noReviewsYet => 'अभी तक कोई समीक्षा नहीं हैं';

  @override
  String get noActiveComplaints => 'कोई सक्रिय शिकायतें नहीं!';

  @override
  String get resolvedNote => '✓  हल (7 दिनों में ऑटो-डिलीट होगा)';

  @override
  String get profileUpdated => 'प्रोफ़ाइल सफलतापूर्वक अपडेट हो गई!';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get saveChanges => 'परिवर्तन सहेजें';

  @override
  String errorPickingImage(Object error) {
    return 'छवि चुनने में त्रुटि: $error';
  }

  @override
  String updateFailed(Object error) {
    return 'अपडेट विफल: $error';
  }

  @override
  String get foundAnIssue => 'कोई समस्या मिली?';

  @override
  String get describeBug => 'कृपया बग का वर्णन करें ताकि हम इसे ठीक कर सकें।';

  @override
  String get subjectHint => 'उदा., ऐप भुगतान पर क्रैश हुआ';

  @override
  String get descriptionHint => 'क्या हुआ इसका विवरण लिखें...';

  @override
  String get email => 'ईमेल';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get password => 'पासवर्ड';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get commentsOptional => 'टिप्पणियाँ (वैकल्पिक)';

  @override
  String get pleaseLogIn => 'कृपया लॉग इन करें';

  @override
  String get myRides => 'मेरी सवारी';

  @override
  String get noRidesYet => 'अभी तक कोई सवारी नहीं है।';

  @override
  String get completedTrip => 'पूरा हुआ सफर';

  @override
  String get ongoingTrip => 'चालू सफर';

  @override
  String get rateNow => 'अब रेट करें';

  @override
  String get atLabel => 'पर';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get languageTamil => 'தமிழ்';

  @override
  String get myFrequentRoutes => 'मेरे बारंबार मार्ग';

  @override
  String get noTravelHistory => 'कोई यात्रा इतिहास नहीं';

  @override
  String get pleaseSelectBusAndRating => 'कृपया एक बस चुनें और रेटिंग दें।';

  @override
  String get rateYourRide => 'अपनी सवारी को रेट करें';

  @override
  String get whichBusWereYouOn => 'आप किस बस में थे?';

  @override
  String get howWasYourExperience => 'आपका अनुभव कैसा था?';

  @override
  String get reviewHint => 'ड्राइवर विनम्र था, बस साफ थी...';

  @override
  String get pleaseSelectSourceDestination => 'कृपया स्रोत और गंतव्य चुनें';

  @override
  String get tripFareCalculator => 'यात्रा किराया कैलकुलेटर';

  @override
  String get getRealtimeFare => 'रीयलटाइम किराया प्राप्त करें';

  @override
  String get seatsFree => 'सीटें खाली';

  @override
  String get estimatedArrival => 'अनुमानित आगमन';

  @override
  String get whereAreYouGoing => 'आज आप कहाँ जा रहे हैं?';

  @override
  String get topRoutes => 'शीर्ष मार्ग';

  @override
  String get noRoutesAvailable => 'कोई मार्ग उपलब्ध नहीं।';

  @override
  String get menu => 'मेनू';

  @override
  String get favoriteRoutes => 'पसंदीदा मार्ग';

  @override
  String get busTimetable => 'बस टाइमटेबल';

  @override
  String get myRidesHistory => 'मेरी सवारी इतिहास';

  @override
  String get trackLiveLocation => 'लाइव लोकेशन ट्रैक करें';

  @override
  String get noNewNotifications => 'कोई नई अधिसूचना नहीं';

  @override
  String get selectABus => 'एक बस चुनें';

  @override
  String get noActiveBusesFound => 'कोई सक्रिय बस नहीं मिली।';

  @override
  String get realTimeTimetable => 'रीयल-टाइम टाइमटेबल';

  @override
  String get noRoutesActive => 'कोई मार्ग सक्रिय नहीं';

  @override
  String get routeLabel => 'मार्ग:';

  @override
  String get tripDetails => 'यात्रा विवरण';

  @override
  String get estimatedFare => 'अनुमानित किराया';

  @override
  String get issueTicket => 'टिकट जारी करें';

  @override
  String get totalFare => 'कुल किराया';

  @override
  String get seatsAvailable => 'सीटें उपलब्ध';

  @override
  String get mustBeLoggedIn => 'आपको लॉग इन होना चाहिए।';

  @override
  String errorLoadingChat(Object error) {
    return 'चैट लोड करने में त्रुटि: $error';
  }

  @override
  String get selectABusToViewLocation => 'लोकेशन देखने के लिए एक बस चुनें';

  @override
  String get viewOnMap => 'मानचित्र पर देखें';

  @override
  String get pleaseUploadClearPhotos =>
      'कृपया अपने मूल दस्तावेज़ों की स्पष्ट तस्वीरें अपलोड करें। एडमिन उन्हें शीघ्र सत्यापित करेगा।';

  @override
  String get verified => 'सत्यापित';

  @override
  String get pendingVerification => 'सत्यापन लंबित';

  @override
  String get notUploaded => 'अपलोड नहीं किया गया';

  @override
  String get done => 'हो गया';

  @override
  String get reupload => 'पुनः अपलोड';

  @override
  String get upload => 'अपलोड';

  @override
  String get documentUploadedSuccess =>
      'दस्तावेज़ अपलोड! सत्यापन के लिए प्रतीक्षा करें।';

  @override
  String get profilePictureUpdated => 'प्रोफ़ाइल चित्र अपडेट!';

  @override
  String get selectBusNumber => 'बस नंबर चुनें';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get welcomeBack => 'वापसी पर स्वागत';

  @override
  String get signupStart => 'सवारी शुरू करने के लिए साइन अप करें';

  @override
  String get loginToTrackYourBus => 'अपनी बस को ट्रैक करने के लिए लॉग इन करें';

  @override
  String get pleaseEnterEmail => 'कृपया ईमेल दर्ज करें';

  @override
  String get passwordMinChars => 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए';

  @override
  String get passwordUpdated => 'पासवर्ड सफलतापूर्वक अपडेट हुआ!';

  @override
  String get update => 'अपडेट करें';

  @override
  String errorLoadingBuses(Object error) {
    return 'बस लोड करने में त्रुटि: $error';
  }

  @override
  String get alreadyHaveAnAccount => 'पहले से खाता है?';

  @override
  String get dontHaveAnAccount => 'खाता नहीं है?';

  @override
  String get unexpectedError => 'अप्रत्याशित त्रुटि';
}
