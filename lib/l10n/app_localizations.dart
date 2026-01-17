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
  /// In es, this message translates to:
  /// **'Coro Games'**
  String get appTitle;

  /// No description provided for @myGames.
  ///
  /// In es, this message translates to:
  /// **'Mis Partidas'**
  String get myGames;

  /// No description provided for @configuration.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configuration;

  /// No description provided for @emptyGamesTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Comienza tu primera partida!'**
  String get emptyGamesTitle;

  /// No description provided for @emptyGamesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Presiona el botón + para crear\nuna nueva partida'**
  String get emptyGamesSubtitle;

  /// No description provided for @swipeToEditOrDelete.
  ///
  /// In es, this message translates to:
  /// **'Desliza para editar o borrar'**
  String get swipeToEditOrDelete;

  /// No description provided for @loadingGames.
  ///
  /// In es, this message translates to:
  /// **'Cargando partidas...'**
  String get loadingGames;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @freeVersionLimitGames.
  ///
  /// In es, this message translates to:
  /// **'La versión gratis solo permite {count} partidas simultáneas.'**
  String freeVersionLimitGames(int count);

  /// No description provided for @freeVersionLimitPlayers.
  ///
  /// In es, this message translates to:
  /// **'La versión gratis solo permite {count} jugadores.'**
  String freeVersionLimitPlayers(int count);

  /// No description provided for @freeVersionLimitPredefined.
  ///
  /// In es, this message translates to:
  /// **'La versión gratis solo permite {count} partidas predefinidas.'**
  String freeVersionLimitPredefined(int count);

  /// No description provided for @getPro.
  ///
  /// In es, this message translates to:
  /// **'Obtener PRO'**
  String get getPro;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @systemTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema del sistema'**
  String get systemTheme;

  /// No description provided for @syncWithDevice.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar con el dispositivo'**
  String get syncWithDevice;

  /// No description provided for @lightTheme.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get darkTheme;

  /// No description provided for @youArePro.
  ///
  /// In es, this message translates to:
  /// **'Eres PRO'**
  String get youArePro;

  /// No description provided for @active.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get active;

  /// No description provided for @allFeaturesUnlocked.
  ///
  /// In es, this message translates to:
  /// **'Todas las funciones desbloqueadas'**
  String get allFeaturesUnlocked;

  /// No description provided for @noAdsUnlimitedGames.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios • Partidas ilimitadas'**
  String get noAdsUnlimitedGames;

  /// No description provided for @simulatePremiumDev.
  ///
  /// In es, this message translates to:
  /// **'Simular Premium (Dev)'**
  String get simulatePremiumDev;

  /// No description provided for @createNewGame.
  ///
  /// In es, this message translates to:
  /// **'Crear nueva partida'**
  String get createNewGame;

  /// No description provided for @predefined.
  ///
  /// In es, this message translates to:
  /// **'Predefinidas'**
  String get predefined;

  /// No description provided for @gameName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la partida'**
  String get gameName;

  /// No description provided for @type.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @rounds.
  ///
  /// In es, this message translates to:
  /// **'Rondas'**
  String get rounds;

  /// No description provided for @score.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get score;

  /// No description provided for @roundCount.
  ///
  /// In es, this message translates to:
  /// **'Cant. rondas'**
  String get roundCount;

  /// No description provided for @maxScore.
  ///
  /// In es, this message translates to:
  /// **'Punt. Máxima'**
  String get maxScore;

  /// No description provided for @players.
  ///
  /// In es, this message translates to:
  /// **'Jugadores'**
  String get players;

  /// No description provided for @createGame.
  ///
  /// In es, this message translates to:
  /// **'Crear Partida'**
  String get createGame;

  /// No description provided for @errorRegisteringGame.
  ///
  /// In es, this message translates to:
  /// **'Error registrando partida.'**
  String get errorRegisteringGame;

  /// No description provided for @checkAllFields.
  ///
  /// In es, this message translates to:
  /// **'Revisar todos los campos de texto.'**
  String get checkAllFields;

  /// No description provided for @maxPlayersReached.
  ///
  /// In es, this message translates to:
  /// **'Máximo de jugadores alcanzados'**
  String get maxPlayersReached;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'nombre'**
  String get name;

  /// No description provided for @predefinedGames.
  ///
  /// In es, this message translates to:
  /// **'Partidas Predefinidas'**
  String get predefinedGames;

  /// No description provided for @dragToReorder.
  ///
  /// In es, this message translates to:
  /// **'Arrastra para reordenar'**
  String get dragToReorder;

  /// No description provided for @tapToSelect.
  ///
  /// In es, this message translates to:
  /// **'Toca para seleccionar'**
  String get tapToSelect;

  /// No description provided for @done.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get done;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @noPredefinedGames.
  ///
  /// In es, this message translates to:
  /// **'Sin partidas predefinidas'**
  String get noPredefinedGames;

  /// No description provided for @tapPlusToCreate.
  ///
  /// In es, this message translates to:
  /// **'Toca + para crear una'**
  String get tapPlusToCreate;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get delete;

  /// No description provided for @confirmDeleteGame.
  ///
  /// In es, this message translates to:
  /// **'Seguro que desea eliminar la partida: {name}'**
  String confirmDeleteGame(String name);

  /// No description provided for @confirmDeletePredefined.
  ///
  /// In es, this message translates to:
  /// **'Seguro que desea eliminar la partida predefinida: {name}'**
  String confirmDeletePredefined(String name);

  /// No description provided for @confirmDeleteScore.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que desea eliminar la puntuación {score} del jugador {player}?'**
  String confirmDeleteScore(int score, String player);

  /// No description provided for @playerScore.
  ///
  /// In es, this message translates to:
  /// **'Puntuación: {score}'**
  String playerScore(int score);

  /// No description provided for @increase.
  ///
  /// In es, this message translates to:
  /// **'Aumentar'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In es, this message translates to:
  /// **'Reducir'**
  String get decrease;

  /// No description provided for @scoreLabel.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get scoreLabel;

  /// No description provided for @noScoresRegistered.
  ///
  /// In es, this message translates to:
  /// **'No hay puntuaciones registradas'**
  String get noScoresRegistered;

  /// No description provided for @noRoundsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No tiene rondas registradas'**
  String get noRoundsRegistered;

  /// No description provided for @minScoreWarning.
  ///
  /// In es, this message translates to:
  /// **'La puntuación minima debe de ser 0.'**
  String get minScoreWarning;

  /// No description provided for @minRoundWarning.
  ///
  /// In es, this message translates to:
  /// **'La ronda minima debe de ser 0.'**
  String get minRoundWarning;

  /// No description provided for @scoreMustBeGreaterThanZero.
  ///
  /// In es, this message translates to:
  /// **'Puntuación debe de ser mayor a 0'**
  String get scoreMustBeGreaterThanZero;

  /// No description provided for @enterScoreToContinue.
  ///
  /// In es, this message translates to:
  /// **'Debe introducir una puntutación para continuar'**
  String get enterScoreToContinue;

  /// No description provided for @warning.
  ///
  /// In es, this message translates to:
  /// **'AVISO'**
  String get warning;

  /// No description provided for @increased.
  ///
  /// In es, this message translates to:
  /// **'Aumentar'**
  String get increased;

  /// No description provided for @decreased.
  ///
  /// In es, this message translates to:
  /// **'Reducir'**
  String get decreased;

  /// No description provided for @coroGamesPro.
  ///
  /// In es, this message translates to:
  /// **'Coro Games PRO'**
  String get coroGamesPro;

  /// No description provided for @unlockFullPotential.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea todo el potencial'**
  String get unlockFullPotential;

  /// No description provided for @unlimitedPlayers.
  ///
  /// In es, this message translates to:
  /// **'Jugadores ilimitados'**
  String get unlimitedPlayers;

  /// No description provided for @unlimitedPlayersDesc.
  ///
  /// In es, this message translates to:
  /// **'Sin límite de jugadores por partida'**
  String get unlimitedPlayersDesc;

  /// No description provided for @unlimitedGames.
  ///
  /// In es, this message translates to:
  /// **'Partidas ilimitadas'**
  String get unlimitedGames;

  /// No description provided for @unlimitedGamesDesc.
  ///
  /// In es, this message translates to:
  /// **'Crea todas las partidas que quieras'**
  String get unlimitedGamesDesc;

  /// No description provided for @predefinedGamesFeature.
  ///
  /// In es, this message translates to:
  /// **'Partidas predefinidas'**
  String get predefinedGamesFeature;

  /// No description provided for @predefinedGamesDesc.
  ///
  /// In es, this message translates to:
  /// **'Guarda configuraciones ilimitadas'**
  String get predefinedGamesDesc;

  /// No description provided for @fullHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial completo'**
  String get fullHistory;

  /// No description provided for @fullHistoryDesc.
  ///
  /// In es, this message translates to:
  /// **'Accede a todo el historial de jugadas'**
  String get fullHistoryDesc;

  /// No description provided for @noAds.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios'**
  String get noAds;

  /// No description provided for @noAdsDesc.
  ///
  /// In es, this message translates to:
  /// **'Disfruta sin interrupciones'**
  String get noAdsDesc;

  /// No description provided for @alreadyPremium.
  ///
  /// In es, this message translates to:
  /// **'¡Ya eres Premium!'**
  String get alreadyPremium;

  /// No description provided for @oneTimePayment.
  ///
  /// In es, this message translates to:
  /// **'Pago único • Sin suscripción'**
  String get oneTimePayment;

  /// No description provided for @purchaseRestored.
  ///
  /// In es, this message translates to:
  /// **'¡Compra restaurada! Ya eres Premium.'**
  String get purchaseRestored;

  /// No description provided for @purchaseFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la compra. Intenta de nuevo.'**
  String get purchaseFailed;

  /// No description provided for @gameType_rounds.
  ///
  /// In es, this message translates to:
  /// **'Rondas'**
  String get gameType_rounds;

  /// No description provided for @gameType_score.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get gameType_score;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @starting.
  ///
  /// In es, this message translates to:
  /// **'Iniciando'**
  String get starting;

  /// No description provided for @gameStarting.
  ///
  /// In es, this message translates to:
  /// **'Partida Iniciando'**
  String get gameStarting;

  /// No description provided for @tie.
  ///
  /// In es, this message translates to:
  /// **'Empate'**
  String get tie;

  /// No description provided for @winning.
  ///
  /// In es, this message translates to:
  /// **'Ganando'**
  String get winning;

  /// No description provided for @losing.
  ///
  /// In es, this message translates to:
  /// **'Perdiendo'**
  String get losing;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @newPredefinedGame.
  ///
  /// In es, this message translates to:
  /// **'Nueva Partida'**
  String get newPredefinedGame;

  /// No description provided for @editPredefinedGame.
  ///
  /// In es, this message translates to:
  /// **'Editar Partida'**
  String get editPredefinedGame;

  /// No description provided for @configureYourPredefined.
  ///
  /// In es, this message translates to:
  /// **'Configura tu partida predefinida'**
  String get configureYourPredefined;

  /// No description provided for @modifyGameData.
  ///
  /// In es, this message translates to:
  /// **'Modifica los datos de la partida'**
  String get modifyGameData;

  /// No description provided for @playerCount.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de jugadores'**
  String get playerCount;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @editGame.
  ///
  /// In es, this message translates to:
  /// **'Editar Partida'**
  String get editGame;

  /// No description provided for @editPlayer.
  ///
  /// In es, this message translates to:
  /// **'Editar Jugador'**
  String get editPlayer;

  /// No description provided for @noName.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre'**
  String get noName;

  /// No description provided for @gameNameCannotBeEmpty.
  ///
  /// In es, this message translates to:
  /// **'El nombre de la partida no puede estar vacio.'**
  String get gameNameCannotBeEmpty;

  /// No description provided for @playerNameCannotBeEmpty.
  ///
  /// In es, this message translates to:
  /// **'El nombre del jugador no puede estar vacio.'**
  String get playerNameCannotBeEmpty;

  /// No description provided for @addPlayer.
  ///
  /// In es, this message translates to:
  /// **'Agregar Jugador'**
  String get addPlayer;

  /// No description provided for @playerName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del jugador'**
  String get playerName;

  /// No description provided for @currentPlayers.
  ///
  /// In es, this message translates to:
  /// **'Jugadores actuales'**
  String get currentPlayers;

  /// No description provided for @playersInGame.
  ///
  /// In es, this message translates to:
  /// **'{count} jugador{count, plural, =1{} other{es}} en la partida'**
  String playersInGame(int count);

  /// No description provided for @enterNewPlayerName.
  ///
  /// In es, this message translates to:
  /// **'Debe introducir el nombre del nuevo jugador'**
  String get enterNewPlayerName;

  /// No description provided for @winner.
  ///
  /// In es, this message translates to:
  /// **'GANADOR'**
  String get winner;

  /// No description provided for @rematch.
  ///
  /// In es, this message translates to:
  /// **'Revancha'**
  String get rematch;

  /// No description provided for @watchAd.
  ///
  /// In es, this message translates to:
  /// **'ver anuncio'**
  String get watchAd;

  /// No description provided for @errorRenewingGame.
  ///
  /// In es, this message translates to:
  /// **'Error renovando partida.'**
  String get errorRenewingGame;

  /// No description provided for @maxScoreFull.
  ///
  /// In es, this message translates to:
  /// **'Puntuación Máxima'**
  String get maxScoreFull;

  /// No description provided for @selectPlayer.
  ///
  /// In es, this message translates to:
  /// **'Seleccione un jugador'**
  String get selectPlayer;

  /// No description provided for @generalHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial General'**
  String get generalHistory;

  /// No description provided for @records.
  ///
  /// In es, this message translates to:
  /// **'{count} registro{count, plural, =1{} other{s}}'**
  String records(int count);

  /// No description provided for @selectedPlayer.
  ///
  /// In es, this message translates to:
  /// **'Jugador seleccionado'**
  String get selectedPlayer;

  /// No description provided for @noRecords.
  ///
  /// In es, this message translates to:
  /// **'No hay registros'**
  String get noRecords;
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
