import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
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
    Locale('it')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'FlutterTemplate'**
  String get appTitle;

  /// No description provided for @sampleItems.
  ///
  /// In en, this message translates to:
  /// **'Sample Items'**
  String get sampleItems;

  /// No description provided for @sampleItem.
  ///
  /// In en, this message translates to:
  /// **'Sample Item'**
  String get sampleItem;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sys_theme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get sys_theme;

  /// No description provided for @dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get dark_theme;

  /// No description provided for @ligth_theme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get ligth_theme;

  /// No description provided for @item_details.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get item_details;

  /// No description provided for @no_info_here.
  ///
  /// In en, this message translates to:
  /// **'No information here'**
  String get no_info_here;

  /// No description provided for @logInApp.
  ///
  /// In en, this message translates to:
  /// **'Log in to FlutterTemplate'**
  String get logInApp;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get validEmail;

  /// No description provided for @insertPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get insertPassword;

  /// No description provided for @pass7Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 7 characters long'**
  String get pass7Chars;

  /// No description provided for @keepConnection.
  ///
  /// In en, this message translates to:
  /// **'Stay connected'**
  String get keepConnection;

  /// No description provided for @logInProgress.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get logInProgress;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @ifNoAccount.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t have an account, sign up by clicking'**
  String get ifNoAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'sign up'**
  String get register;

  /// No description provided for @visitSite.
  ///
  /// In en, this message translates to:
  /// **'For more information, visit the website '**
  String get visitSite;

  /// No description provided for @goGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get goGuest;

  /// No description provided for @recoverPassword.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get recoverPassword;

  /// No description provided for @request_recover_mail_ok.
  ///
  /// In en, this message translates to:
  /// **'The password change request was successful. Check your received emails (including spam) and proceed with credential recovery.'**
  String get request_recover_mail_ok;

  /// No description provided for @insert_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get insert_email;

  /// No description provided for @insert_valid_mail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get insert_valid_mail;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @password_forgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get password_forgot;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @wrong_email_inserted.
  ///
  /// In en, this message translates to:
  /// **'Invalid email inserted.'**
  String get wrong_email_inserted;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get client;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chat;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @click_to_add.
  ///
  /// In en, this message translates to:
  /// **'Click on the + icon to add'**
  String get click_to_add;

  /// No description provided for @a_client.
  ///
  /// In en, this message translates to:
  /// **'a client'**
  String get a_client;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @access_denied.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get access_denied;

  /// No description provided for @ban.
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get ban;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Sub'**
  String get subscriptions;

  /// No description provided for @access.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get access;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @here.
  ///
  /// In en, this message translates to:
  /// **'here'**
  String get here;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm log out'**
  String get logout_confirmation;

  /// No description provided for @are_you_sure_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get are_you_sure_logout;

  /// No description provided for @already_logged_in_with.
  ///
  /// In en, this message translates to:
  /// **'You are already logged in with:'**
  String get already_logged_in_with;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
