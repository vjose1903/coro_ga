import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Coro Games'**
  String get appTitle;

  /// No description provided for @myGames.
  ///
  /// In en, this message translates to:
  /// **'My Games'**
  String get myGames;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get configuration;

  /// No description provided for @emptyGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first game!'**
  String get emptyGamesTitle;

  /// No description provided for @emptyGamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Press the + button to create\na new game'**
  String get emptyGamesSubtitle;

  /// No description provided for @swipeToEditOrDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe to edit or delete'**
  String get swipeToEditOrDelete;

  /// No description provided for @loadingGames.
  ///
  /// In en, this message translates to:
  /// **'Loading games...'**
  String get loadingGames;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @freeVersionLimitGames.
  ///
  /// In en, this message translates to:
  /// **'Free version only allows {count} simultaneous games.'**
  String freeVersionLimitGames(int count);

  /// No description provided for @freeVersionLimitPlayers.
  ///
  /// In en, this message translates to:
  /// **'Free version only allows {count} players.'**
  String freeVersionLimitPlayers(int count);

  /// No description provided for @freeVersionLimitPredefined.
  ///
  /// In en, this message translates to:
  /// **'Free version only allows {count} predefined games.'**
  String freeVersionLimitPredefined(int count);

  /// No description provided for @getPro.
  ///
  /// In en, this message translates to:
  /// **'Get PRO'**
  String get getPro;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get systemTheme;

  /// No description provided for @syncWithDevice.
  ///
  /// In en, this message translates to:
  /// **'Sync with device'**
  String get syncWithDevice;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @youArePro.
  ///
  /// In en, this message translates to:
  /// **'You are PRO'**
  String get youArePro;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @allFeaturesUnlocked.
  ///
  /// In en, this message translates to:
  /// **'All features unlocked'**
  String get allFeaturesUnlocked;

  /// No description provided for @noAdsUnlimitedGames.
  ///
  /// In en, this message translates to:
  /// **'No ads • Unlimited games'**
  String get noAdsUnlimitedGames;

  /// No description provided for @simulatePremiumDev.
  ///
  /// In en, this message translates to:
  /// **'Simulate Premium (Dev)'**
  String get simulatePremiumDev;

  /// No description provided for @createNewGame.
  ///
  /// In en, this message translates to:
  /// **'Create new game'**
  String get createNewGame;

  /// No description provided for @predefined.
  ///
  /// In en, this message translates to:
  /// **'Predefined'**
  String get predefined;

  /// No description provided for @gameName.
  ///
  /// In en, this message translates to:
  /// **'Game name'**
  String get gameName;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @roundCount.
  ///
  /// In en, this message translates to:
  /// **'Round count'**
  String get roundCount;

  /// No description provided for @maxScore.
  ///
  /// In en, this message translates to:
  /// **'Max score'**
  String get maxScore;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @createGame.
  ///
  /// In en, this message translates to:
  /// **'Create Game'**
  String get createGame;

  /// No description provided for @errorRegisteringGame.
  ///
  /// In en, this message translates to:
  /// **'Error registering game.'**
  String get errorRegisteringGame;

  /// No description provided for @checkAllFields.
  ///
  /// In en, this message translates to:
  /// **'Check all text fields.'**
  String get checkAllFields;

  /// No description provided for @maxPlayersReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum players reached'**
  String get maxPlayersReached;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get name;

  /// No description provided for @predefinedGames.
  ///
  /// In en, this message translates to:
  /// **'Predefined Games'**
  String get predefinedGames;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noPredefinedGames.
  ///
  /// In en, this message translates to:
  /// **'No predefined games'**
  String get noPredefinedGames;

  /// No description provided for @tapPlusToCreate.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create one'**
  String get tapPlusToCreate;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDeleteGame.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the game: {name}'**
  String confirmDeleteGame(String name);

  /// No description provided for @confirmDeletePredefined.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the predefined game: {name}'**
  String confirmDeletePredefined(String name);

  /// No description provided for @confirmDeleteScore.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete score {score} from player {player}?'**
  String confirmDeleteScore(int score, String player);

  /// No description provided for @playerScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String playerScore(int score);

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @noScoresRegistered.
  ///
  /// In en, this message translates to:
  /// **'No scores registered'**
  String get noScoresRegistered;

  /// No description provided for @noRoundsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No rounds registered'**
  String get noRoundsRegistered;

  /// No description provided for @minScoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Minimum score must be 0.'**
  String get minScoreWarning;

  /// No description provided for @minRoundWarning.
  ///
  /// In en, this message translates to:
  /// **'Minimum round must be 0.'**
  String get minRoundWarning;

  /// No description provided for @scoreMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Score must be greater than 0'**
  String get scoreMustBeGreaterThanZero;

  /// No description provided for @enterScoreToContinue.
  ///
  /// In en, this message translates to:
  /// **'You must enter a score to continue'**
  String get enterScoreToContinue;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get warning;

  /// No description provided for @increased.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increased;

  /// No description provided for @decreased.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decreased;

  /// No description provided for @coroGamesPro.
  ///
  /// In en, this message translates to:
  /// **'Coro Games PRO'**
  String get coroGamesPro;

  /// No description provided for @unlockFullPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock full potential'**
  String get unlockFullPotential;

  /// No description provided for @unlimitedPlayers.
  ///
  /// In en, this message translates to:
  /// **'Unlimited players'**
  String get unlimitedPlayers;

  /// No description provided for @unlimitedPlayersDesc.
  ///
  /// In en, this message translates to:
  /// **'No player limit per game'**
  String get unlimitedPlayersDesc;

  /// No description provided for @unlimitedGames.
  ///
  /// In en, this message translates to:
  /// **'Unlimited games'**
  String get unlimitedGames;

  /// No description provided for @unlimitedGamesDesc.
  ///
  /// In en, this message translates to:
  /// **'Create as many games as you want'**
  String get unlimitedGamesDesc;

  /// No description provided for @predefinedGamesFeature.
  ///
  /// In en, this message translates to:
  /// **'Predefined games'**
  String get predefinedGamesFeature;

  /// No description provided for @predefinedGamesDesc.
  ///
  /// In en, this message translates to:
  /// **'Save unlimited configurations'**
  String get predefinedGamesDesc;

  /// No description provided for @fullHistory.
  ///
  /// In en, this message translates to:
  /// **'Full history'**
  String get fullHistory;

  /// No description provided for @fullHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Access complete play history'**
  String get fullHistoryDesc;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get noAds;

  /// No description provided for @noAdsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy without interruptions'**
  String get noAdsDesc;

  /// No description provided for @alreadyPremium.
  ///
  /// In en, this message translates to:
  /// **'You are Premium!'**
  String get alreadyPremium;

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'One-time payment • No subscription'**
  String get oneTimePayment;

  /// No description provided for @purchaseRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchase restored! You are Premium.'**
  String get purchaseRestored;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete purchase. Try again.'**
  String get purchaseFailed;

  /// No description provided for @gameType_rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get gameType_rounds;

  /// No description provided for @gameType_score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get gameType_score;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get starting;

  /// No description provided for @gameStarting.
  ///
  /// In en, this message translates to:
  /// **'Game Starting'**
  String get gameStarting;

  /// No description provided for @tie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get tie;

  /// No description provided for @winning.
  ///
  /// In en, this message translates to:
  /// **'Winning'**
  String get winning;

  /// No description provided for @losing.
  ///
  /// In en, this message translates to:
  /// **'Losing'**
  String get losing;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @confirmRestartGame.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restart the game: {name}?'**
  String confirmRestartGame(String name);

  /// No description provided for @newPredefinedGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newPredefinedGame;

  /// No description provided for @editPredefinedGame.
  ///
  /// In en, this message translates to:
  /// **'Edit Game'**
  String get editPredefinedGame;

  /// No description provided for @configureYourPredefined.
  ///
  /// In en, this message translates to:
  /// **'Configure your predefined game'**
  String get configureYourPredefined;

  /// No description provided for @modifyGameData.
  ///
  /// In en, this message translates to:
  /// **'Modify game data'**
  String get modifyGameData;

  /// No description provided for @playerCount.
  ///
  /// In en, this message translates to:
  /// **'Number of players'**
  String get playerCount;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @editGame.
  ///
  /// In en, this message translates to:
  /// **'Edit Game'**
  String get editGame;

  /// No description provided for @editPlayer.
  ///
  /// In en, this message translates to:
  /// **'Edit Player'**
  String get editPlayer;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noName;

  /// No description provided for @gameNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Game name cannot be empty.'**
  String get gameNameCannotBeEmpty;

  /// No description provided for @playerNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Player name cannot be empty.'**
  String get playerNameCannotBeEmpty;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayer;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerName;

  /// No description provided for @currentPlayers.
  ///
  /// In en, this message translates to:
  /// **'Current players'**
  String get currentPlayers;

  /// No description provided for @playersInGame.
  ///
  /// In en, this message translates to:
  /// **'{count} player{count, plural, =1{} other{s}} in the game'**
  String playersInGame(int count);

  /// No description provided for @enterNewPlayerName.
  ///
  /// In en, this message translates to:
  /// **'You must enter the new player\'s name'**
  String get enterNewPlayerName;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'WINNER'**
  String get winner;

  /// No description provided for @rematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get rematch;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'watch ad'**
  String get watchAd;

  /// No description provided for @errorRenewingGame.
  ///
  /// In en, this message translates to:
  /// **'Error renewing game.'**
  String get errorRenewingGame;

  /// No description provided for @maxScoreFull.
  ///
  /// In en, this message translates to:
  /// **'Max Score'**
  String get maxScoreFull;

  /// No description provided for @selectPlayer.
  ///
  /// In en, this message translates to:
  /// **'Select a player'**
  String get selectPlayer;

  /// No description provided for @generalHistory.
  ///
  /// In en, this message translates to:
  /// **'General History'**
  String get generalHistory;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'{count} record{count, plural, =1{} other{s}}'**
  String records(int count);

  /// No description provided for @selectedPlayer.
  ///
  /// In en, this message translates to:
  /// **'Selected player'**
  String get selectedPlayer;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get noRecords;

  /// No description provided for @noPlayers.
  ///
  /// In en, this message translates to:
  /// **'No players'**
  String get noPlayers;

  /// No description provided for @confirmDeletePlayer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the player: {name}'**
  String confirmDeletePlayer(String name);

  /// No description provided for @errorDeletingPlayer.
  ///
  /// In en, this message translates to:
  /// **'Error deleting player: {name}'**
  String errorDeletingPlayer(String name);

  /// No description provided for @minPlayersWarning.
  ///
  /// In en, this message translates to:
  /// **'The number of players cannot be less than 2.'**
  String get minPlayersWarning;

  /// No description provided for @playerNumber.
  ///
  /// In en, this message translates to:
  /// **'Player {number}'**
  String playerNumber(int number);

  /// No description provided for @newVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'New version available!'**
  String get newVersionTitle;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version of Coro Games is available. Update now to enjoy the latest improvements and features.'**
  String get newVersionAvailable;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @unauthorizedVersion.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized Version'**
  String get unauthorizedVersion;

  /// No description provided for @illegitimateCopy.
  ///
  /// In en, this message translates to:
  /// **'This copy of the app is not legitimate.\n\nPlease download the official version from Google Play Store to enjoy all features.'**
  String get illegitimateCopy;

  /// No description provided for @closeApp.
  ///
  /// In en, this message translates to:
  /// **'Close app'**
  String get closeApp;

  /// No description provided for @errorEditingPlayer.
  ///
  /// In en, this message translates to:
  /// **'Could not edit the selected player.'**
  String get errorEditingPlayer;

  /// No description provided for @errorDeletingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error deleting history'**
  String get errorDeletingHistory;

  /// No description provided for @noHistoryForGame.
  ///
  /// In en, this message translates to:
  /// **'The entered game has no history.'**
  String get noHistoryForGame;

  /// No description provided for @minTwoPlayers.
  ///
  /// In en, this message translates to:
  /// **'You must add at least 2 players to the game'**
  String get minTwoPlayers;

  /// No description provided for @noGamesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No games registered.'**
  String get noGamesRegistered;

  /// No description provided for @errorDeletingGame.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the selected game.'**
  String get errorDeletingGame;

  /// No description provided for @errorEditingGame.
  ///
  /// In en, this message translates to:
  /// **'Could not edit the selected game.'**
  String get errorEditingGame;

  /// No description provided for @noPlayersForGame.
  ///
  /// In en, this message translates to:
  /// **'The entered game has no players.'**
  String get noPlayersForGame;

  /// No description provided for @errorDeletingPredefined.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the selected predefined game.'**
  String get errorDeletingPredefined;

  /// No description provided for @errorEditingPredefined.
  ///
  /// In en, this message translates to:
  /// **'Could not edit the selected game.'**
  String get errorEditingPredefined;

  /// No description provided for @errorInsertingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error inserting play history.'**
  String get errorInsertingHistory;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field.'**
  String get fieldRequired;

  /// No description provided for @minValue.
  ///
  /// In en, this message translates to:
  /// **'Minimum value is: {min}'**
  String minValue(String min);
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
