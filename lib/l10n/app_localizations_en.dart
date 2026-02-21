// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coro Games';

  @override
  String get myGames => 'My Games';

  @override
  String get configuration => 'Settings';

  @override
  String get emptyGamesTitle => 'Start your first game!';

  @override
  String get emptyGamesSubtitle => 'Press the + button to create\na new game';

  @override
  String get swipeToEditOrDelete => 'Swipe to edit or delete';

  @override
  String get loadingGames => 'Loading games...';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get loadingDataError => 'Error loading data.';

  @override
  String get adErrorRematch =>
      'There was an error and the rematch could not be completed.';

  @override
  String get rematchExecutionError =>
      'An error occurred while executing the rematch.';

  @override
  String get rewardNotCompletedRematch =>
      'The reward was not completed to trigger the rematch.';

  @override
  String freeVersionLimitGames(int count) {
    return 'Free version only allows $count simultaneous games.';
  }

  @override
  String freeVersionLimitPlayers(int count) {
    return 'Free version only allows $count players.';
  }

  @override
  String freeVersionLimitPredefined(int count) {
    return 'Free version only allows $count predefined games.';
  }

  @override
  String get getPro => 'Get PRO';

  @override
  String get appearance => 'Appearance';

  @override
  String get systemTheme => 'System theme';

  @override
  String get syncWithDevice => 'Sync with device';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get youArePro => 'You are PRO';

  @override
  String get active => 'Active';

  @override
  String get allFeaturesUnlocked => 'All features unlocked';

  @override
  String get noAdsUnlimitedGames => 'No ads • Unlimited games';

  @override
  String get simulatePremiumDev => 'Simulate Premium (Dev)';

  @override
  String get createNewGame => 'Create new game';

  @override
  String get predefined => 'Predefined';

  @override
  String get gameName => 'Game name';

  @override
  String get type => 'Type';

  @override
  String get rounds => 'Rounds';

  @override
  String get score => 'Score';

  @override
  String get roundCount => 'Round count';

  @override
  String get maxScore => 'Max score';

  @override
  String get noMaxScore => 'No max score';

  @override
  String get noMaxRounds => 'No round limit';

  @override
  String get players => 'Players';

  @override
  String get createGame => 'Create Game';

  @override
  String get errorRegisteringGame => 'Error registering game.';

  @override
  String get checkAllFields => 'Check all text fields.';

  @override
  String get maxPlayersReached => 'Maximum players reached';

  @override
  String get name => 'name';

  @override
  String get predefinedGames => 'Predefined Games';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get predefinedEditHint => 'Press and hold to reorder or delete.';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get noPredefinedGames => 'No predefined games';

  @override
  String get tapPlusToCreate => 'Tap + to create one';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get delete => 'Delete';

  @override
  String confirmDeleteGame(String name) {
    return 'Are you sure you want to delete the game: $name';
  }

  @override
  String confirmDeletePredefined(String name) {
    return 'Are you sure you want to delete the predefined game: $name';
  }

  @override
  String confirmDeleteScore(int score, String player) {
    return 'Are you sure you want to delete score $score from player $player?';
  }

  @override
  String get endGame => 'End game';

  @override
  String confirmEndGame(String name) {
    return 'Are you sure you want to end the game: $name?';
  }

  @override
  String playerScore(int score) {
    return 'Score: $score';
  }

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get scoreLabel => 'Score';

  @override
  String get noScoresRegistered => 'No scores registered';

  @override
  String get noRoundsRegistered => 'No rounds registered';

  @override
  String get minScoreWarning => 'Minimum score must be 0.';

  @override
  String get minRoundWarning => 'Minimum round must be 0.';

  @override
  String get scoreMustBeGreaterThanZero => 'Score must be greater than 0';

  @override
  String get enterScoreToContinue => 'You must enter a score to continue';

  @override
  String get warning => 'WARNING';

  @override
  String get increased => 'Increase';

  @override
  String get decreased => 'Decrease';

  @override
  String get coroGamesPro => 'Coro Games PRO';

  @override
  String get unlockFullPotential => 'Unlock full potential';

  @override
  String get unlimitedPlayers => 'Unlimited players';

  @override
  String get unlimitedPlayersDesc => 'No player limit per game';

  @override
  String get unlimitedGames => 'Unlimited games';

  @override
  String get unlimitedGamesDesc => 'Create as many games as you want';

  @override
  String get predefinedGamesFeature => 'Predefined games';

  @override
  String get predefinedGamesDesc => 'Save unlimited configurations';

  @override
  String get fullHistory => 'Full history';

  @override
  String get fullHistoryDesc => 'Access complete play history';

  @override
  String get noAds => 'No ads';

  @override
  String get noAdsDesc => 'Enjoy without interruptions';

  @override
  String get alreadyPremium => 'You are Premium!';

  @override
  String get oneTimePayment => 'One-time payment • No subscription';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get purchaseRestored => 'Purchase restored! You are Premium.';

  @override
  String get purchaseFailed => 'Could not complete purchase. Try again.';

  @override
  String get restoreFailed => 'Could not restore purchase. Try again.';

  @override
  String get gameType_rounds => 'Rounds';

  @override
  String get gameType_score => 'Score';

  @override
  String get language => 'Language';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get starting => 'Starting';

  @override
  String get gameStarting => 'Game Starting';

  @override
  String get tie => 'Tie';

  @override
  String get winning => 'Winning';

  @override
  String get losing => 'Losing';

  @override
  String get edit => 'Edit';

  @override
  String get restart => 'Restart';

  @override
  String confirmRestartGame(String name) {
    return 'Are you sure you want to restart the game: $name?';
  }

  @override
  String get newPredefinedGame => 'New Game';

  @override
  String get editPredefinedGame => 'Edit Game';

  @override
  String get configureYourPredefined => 'Configure your predefined game';

  @override
  String get modifyGameData => 'Modify game data';

  @override
  String get playerCount => 'Number of players';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get editGame => 'Edit Game';

  @override
  String get editPlayer => 'Edit Player';

  @override
  String get noName => 'No name';

  @override
  String get gameNameCannotBeEmpty => 'Game name cannot be empty.';

  @override
  String get playerNameCannotBeEmpty => 'Player name cannot be empty.';

  @override
  String get addPlayer => 'Add Player';

  @override
  String get playerName => 'Player name';

  @override
  String get currentPlayers => 'Current players';

  @override
  String playersInGame(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count player$_temp0 in the game';
  }

  @override
  String get enterNewPlayerName => 'You must enter the new player\'s name';

  @override
  String get winner => 'WINNER';

  @override
  String get rematch => 'Rematch';

  @override
  String get watchAd => 'watch ad';

  @override
  String get errorRenewingGame => 'Error renewing game.';

  @override
  String get maxScoreFull => 'Max Score';

  @override
  String get selectPlayer => 'Select a player';

  @override
  String get generalHistory => 'General History';

  @override
  String records(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count record$_temp0';
  }

  @override
  String get selectedPlayer => 'Selected player';

  @override
  String get noRecords => 'No records';

  @override
  String get noPlayers => 'No players';

  @override
  String confirmDeletePlayer(String name) {
    return 'Are you sure you want to delete the player: $name';
  }

  @override
  String errorDeletingPlayer(String name) {
    return 'Error deleting player: $name';
  }

  @override
  String get minPlayersWarning =>
      'The number of players cannot be less than 2.';

  @override
  String playerNumber(int number) {
    return 'Player $number';
  }

  @override
  String get newVersionTitle => 'New version available!';

  @override
  String get newVersionAvailable =>
      'A new version of Coro Games is available. Update now to enjoy the latest improvements and features.';

  @override
  String get updateNow => 'Update now';

  @override
  String get unauthorizedVersion => 'Unauthorized Version';

  @override
  String get illegitimateCopy =>
      'This copy of the app is not legitimate.\n\nPlease download the official version from Google Play Store to enjoy all features.';

  @override
  String get closeApp => 'Close app';

  @override
  String get errorEditingPlayer => 'Could not edit the selected player.';

  @override
  String get errorDeletingHistory => 'Error deleting history';

  @override
  String get noHistoryForGame => 'The entered game has no history.';

  @override
  String get minTwoPlayers => 'You must add at least 2 players to the game';

  @override
  String get noGamesRegistered => 'No games registered.';

  @override
  String get errorDeletingGame => 'Could not delete the selected game.';

  @override
  String get errorEditingGame => 'Could not edit the selected game.';

  @override
  String get noPlayersForGame => 'The entered game has no players.';

  @override
  String get errorDeletingPredefined =>
      'Could not delete the selected predefined game.';

  @override
  String get errorEditingPredefined => 'Could not edit the selected game.';

  @override
  String get errorInsertingHistory => 'Error inserting play history.';

  @override
  String get fieldRequired => 'Required field.';

  @override
  String minValue(String min) {
    return 'Minimum value is: $min';
  }

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppTitle => 'What is Coro Games?';

  @override
  String get aboutAppDescription =>
      'Coro Games is your perfect companion for keeping score in your favorite board games. Whether it\'s dominoes, cards, dice or any other game, our app lets you record scores, manage players and view game history quickly and easily.';

  @override
  String get privacyPolicyTitle => 'Privacy & Transparency';

  @override
  String get privacyPolicyDescription =>
      'At Coro Games we respect your privacy. We do not request personal data such as names or email addresses.\n\n• Game Data: Stored locally on your device and never leaves it.\n\n• Third-Party Services: We use Google Firebase for performance analytics and Google AdMob to display ads. These services may collect device advertising identifiers for proper operation.\n\nYou can read our full Privacy Policy at the following link:';

  @override
  String get viewFullPrivacyPolicy => 'Privacy Policy';

  @override
  String get reviewCardTitle => 'Do you like the app?';

  @override
  String get reviewCardDescription =>
      'Your rating keeps Coro Games improving. Leave it on the store so other players can discover it.';

  @override
  String get reviewCardButton => 'Rate now';

  @override
  String get reviewFallbackMessage =>
      'Unable to open the review prompt. Search for Coro Games in the store to leave your feedback.';

  @override
  String get noInternetTitle => 'No internet connection';

  @override
  String get noInternetMessage =>
      'To use the app you need an internet connection.';

  @override
  String get noInternetWaiting => 'Waiting for connection...';
}
