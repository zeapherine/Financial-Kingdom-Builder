import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

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
    Locale('es'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Financial Kingdom Builder'**
  String get appTitle;

  /// Education section title
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// Lessons section title
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// Progress section title
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Achievements section title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Experience points label
  ///
  /// In en, this message translates to:
  /// **'Experience Points'**
  String get experiencePoints;

  /// Overall progress label
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// Learning path title
  ///
  /// In en, this message translates to:
  /// **'Learning Path'**
  String get learningPath;

  /// Current milestone label
  ///
  /// In en, this message translates to:
  /// **'Current Milestone'**
  String get currentMilestone;

  /// Achievement unlock notification
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// Start animation button text
  ///
  /// In en, this message translates to:
  /// **'Start Animation'**
  String get startAnimation;

  /// Playing animation status
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get playing;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Blockchain visualization title
  ///
  /// In en, this message translates to:
  /// **'Blockchain Process Visualization'**
  String get blockchainProcessVisualization;

  /// Block structure section title
  ///
  /// In en, this message translates to:
  /// **'Block Structure'**
  String get blockStructure;

  /// Construction permits title
  ///
  /// In en, this message translates to:
  /// **'Financial Construction Permits'**
  String get financialConstructionPermits;

  /// Construction permits description
  ///
  /// In en, this message translates to:
  /// **'Build your financial knowledge step by step, just like constructing a building'**
  String get buildYourFinancialKnowledge;

  /// Requirements label
  ///
  /// In en, this message translates to:
  /// **'Requirements:'**
  String get requirements;

  /// Building analogy label
  ///
  /// In en, this message translates to:
  /// **'Building Analogy:'**
  String get buildingAnalogy;

  /// Unlocks label
  ///
  /// In en, this message translates to:
  /// **'Unlocks:'**
  String get unlocks;

  /// Final inspection title
  ///
  /// In en, this message translates to:
  /// **'Final Building Inspection'**
  String get finalBuildingInspection;

  /// Inspection score label
  ///
  /// In en, this message translates to:
  /// **'Inspection Score:'**
  String get inspectionScore;

  /// Passing score requirement
  ///
  /// In en, this message translates to:
  /// **'Need {score} to pass'**
  String needToPass(int score);

  /// Inspection passed message
  ///
  /// In en, this message translates to:
  /// **'Inspection Passed!'**
  String get inspectionPassed;

  /// Risk meter title
  ///
  /// In en, this message translates to:
  /// **'Risk Meter'**
  String get riskMeter;

  /// Risk level display
  ///
  /// In en, this message translates to:
  /// **'Risk Level: {level}'**
  String riskLevel(String level);

  /// Low risk label
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// Moderate risk label
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get moderateRisk;

  /// High risk label
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// Minutes duration
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutes(int count);

  /// Estimated completion time
  ///
  /// In en, this message translates to:
  /// **'Estimated time: {minutes}'**
  String estimatedTime(String minutes);

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Correct answer feedback
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// Incorrect answer feedback
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// Loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error state text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
