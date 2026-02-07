// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Coro Games';

  @override
  String get myGames => 'Mis Partidas';

  @override
  String get configuration => 'Configuración';

  @override
  String get emptyGamesTitle => '¡Comienza tu primera partida!';

  @override
  String get emptyGamesSubtitle =>
      'Presiona el botón + para crear\nuna nueva partida';

  @override
  String get swipeToEditOrDelete => 'Desliza para editar o borrar';

  @override
  String get loadingGames => 'Cargando partidas...';

  @override
  String get loading => 'Cargando...';

  @override
  String get loadingData => 'Cargando datos...';

  @override
  String get loadingDataError => 'Error al cargar datos.';

  @override
  String get adErrorRematch =>
      'Hubo un error y no se pudo completar la revancha.';

  @override
  String get rewardNotCompletedRematch =>
      'No se completó la recompensa para hacer la revancha.';

  @override
  String freeVersionLimitGames(int count) {
    return 'La versión gratis solo permite $count partidas simultáneas.';
  }

  @override
  String freeVersionLimitPlayers(int count) {
    return 'La versión gratis solo permite $count jugadores.';
  }

  @override
  String freeVersionLimitPredefined(int count) {
    return 'La versión gratis solo permite $count partidas predefinidas.';
  }

  @override
  String get getPro => 'Obtener PRO';

  @override
  String get appearance => 'Apariencia';

  @override
  String get systemTheme => 'Tema del sistema';

  @override
  String get syncWithDevice => 'Sincronizar con el dispositivo';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get youArePro => 'Eres PRO';

  @override
  String get active => 'Activo';

  @override
  String get allFeaturesUnlocked => 'Todas las funciones desbloqueadas';

  @override
  String get noAdsUnlimitedGames => 'Sin anuncios • Partidas ilimitadas';

  @override
  String get simulatePremiumDev => 'Simular Premium (Dev)';

  @override
  String get createNewGame => 'Crear nueva partida';

  @override
  String get predefined => 'Predefinidas';

  @override
  String get gameName => 'Nombre de la partida';

  @override
  String get type => 'Tipo';

  @override
  String get rounds => 'Rondas';

  @override
  String get score => 'Puntuación';

  @override
  String get roundCount => 'Cant. rondas';

  @override
  String get maxScore => 'Punt. Máxima';

  @override
  String get noMaxScore => 'Sin puntuación máxima';

  @override
  String get noMaxRounds => 'Sin límite de rondas';

  @override
  String get players => 'Jugadores';

  @override
  String get createGame => 'Crear Partida';

  @override
  String get errorRegisteringGame => 'Error registrando partida.';

  @override
  String get checkAllFields => 'Revisar todos los campos de texto.';

  @override
  String get maxPlayersReached => 'Máximo de jugadores alcanzados';

  @override
  String get name => 'nombre';

  @override
  String get predefinedGames => 'Partidas Predefinidas';

  @override
  String get dragToReorder => 'Arrastra para reordenar';

  @override
  String get predefinedEditHint =>
      'Mantén presionado para reordenar o eliminar.';

  @override
  String get tapToSelect => 'Toca para seleccionar';

  @override
  String get done => 'Listo';

  @override
  String get close => 'Cerrar';

  @override
  String get noPredefinedGames => 'Sin partidas predefinidas';

  @override
  String get tapPlusToCreate => 'Toca + para crear una';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get accept => 'Aceptar';

  @override
  String get delete => 'Borrar';

  @override
  String confirmDeleteGame(String name) {
    return 'Seguro que desea eliminar la partida: $name';
  }

  @override
  String confirmDeletePredefined(String name) {
    return 'Seguro que desea eliminar la partida predefinida: $name';
  }

  @override
  String confirmDeleteScore(int score, String player) {
    return '¿Seguro que desea eliminar la puntuación $score del jugador $player?';
  }

  @override
  String get endGame => 'Terminar partida';

  @override
  String confirmEndGame(String name) {
    return '¿Seguro que desea terminar la partida: $name?';
  }

  @override
  String playerScore(int score) {
    return 'Puntuación: $score';
  }

  @override
  String get increase => 'Aumentar';

  @override
  String get decrease => 'Reducir';

  @override
  String get scoreLabel => 'Puntuación';

  @override
  String get noScoresRegistered => 'No hay puntuaciones registradas';

  @override
  String get noRoundsRegistered => 'No tiene rondas registradas';

  @override
  String get minScoreWarning => 'La puntuación minima debe de ser 0.';

  @override
  String get minRoundWarning => 'La ronda minima debe de ser 0.';

  @override
  String get scoreMustBeGreaterThanZero => 'Puntuación debe de ser mayor a 0';

  @override
  String get enterScoreToContinue =>
      'Debe introducir una puntutación para continuar';

  @override
  String get warning => 'AVISO';

  @override
  String get increased => 'Aumentar';

  @override
  String get decreased => 'Reducir';

  @override
  String get coroGamesPro => 'Coro Games PRO';

  @override
  String get unlockFullPotential => 'Desbloquea todo el potencial';

  @override
  String get unlimitedPlayers => 'Jugadores ilimitados';

  @override
  String get unlimitedPlayersDesc => 'Sin límite de jugadores por partida';

  @override
  String get unlimitedGames => 'Partidas ilimitadas';

  @override
  String get unlimitedGamesDesc => 'Crea todas las partidas que quieras';

  @override
  String get predefinedGamesFeature => 'Partidas predefinidas';

  @override
  String get predefinedGamesDesc => 'Guarda configuraciones ilimitadas';

  @override
  String get fullHistory => 'Historial completo';

  @override
  String get fullHistoryDesc => 'Accede a todo el historial de jugadas';

  @override
  String get noAds => 'Sin anuncios';

  @override
  String get noAdsDesc => 'Disfruta sin interrupciones';

  @override
  String get alreadyPremium => '¡Ya eres Premium!';

  @override
  String get oneTimePayment => 'Pago único • Sin suscripción';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchaseRestored => '¡Compra restaurada! Ya eres Premium.';

  @override
  String get purchaseFailed =>
      'No se pudo completar la compra. Intenta de nuevo.';

  @override
  String get restoreFailed =>
      'No se pudo restaurar la compra. Intenta de nuevo.';

  @override
  String get gameType_rounds => 'Rondas';

  @override
  String get gameType_score => 'Puntuación';

  @override
  String get language => 'Idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get starting => 'Iniciando';

  @override
  String get gameStarting => 'Partida Iniciando';

  @override
  String get tie => 'Empate';

  @override
  String get winning => 'Ganando';

  @override
  String get losing => 'Perdiendo';

  @override
  String get edit => 'Editar';

  @override
  String get restart => 'Reiniciar';

  @override
  String confirmRestartGame(String name) {
    return '¿Seguro que desea reiniciar la partida: $name?';
  }

  @override
  String get newPredefinedGame => 'Nueva Partida';

  @override
  String get editPredefinedGame => 'Editar Partida';

  @override
  String get configureYourPredefined => 'Configura tu partida predefinida';

  @override
  String get modifyGameData => 'Modifica los datos de la partida';

  @override
  String get playerCount => 'Cantidad de jugadores';

  @override
  String get back => 'Volver';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get editGame => 'Editar Partida';

  @override
  String get editPlayer => 'Editar Jugador';

  @override
  String get noName => 'Sin nombre';

  @override
  String get gameNameCannotBeEmpty =>
      'El nombre de la partida no puede estar vacio.';

  @override
  String get playerNameCannotBeEmpty =>
      'El nombre del jugador no puede estar vacio.';

  @override
  String get addPlayer => 'Agregar Jugador';

  @override
  String get playerName => 'Nombre del jugador';

  @override
  String get currentPlayers => 'Jugadores actuales';

  @override
  String playersInGame(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'es',
      one: '',
    );
    return '$count jugador$_temp0 en la partida';
  }

  @override
  String get enterNewPlayerName =>
      'Debe introducir el nombre del nuevo jugador';

  @override
  String get winner => 'GANADOR';

  @override
  String get rematch => 'Revancha';

  @override
  String get watchAd => 'ver anuncio';

  @override
  String get errorRenewingGame => 'Error renovando partida.';

  @override
  String get maxScoreFull => 'Puntuación Máxima';

  @override
  String get selectPlayer => 'Seleccione un jugador';

  @override
  String get generalHistory => 'Historial General';

  @override
  String records(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count registro$_temp0';
  }

  @override
  String get selectedPlayer => 'Jugador seleccionado';

  @override
  String get noRecords => 'No hay registros';

  @override
  String get noPlayers => 'Sin jugadores';

  @override
  String confirmDeletePlayer(String name) {
    return 'Seguro que desea eliminar el jugador: $name';
  }

  @override
  String errorDeletingPlayer(String name) {
    return 'Error eliminando al jugador: $name';
  }

  @override
  String get minPlayersWarning =>
      'La cantidad de jugadores no puede ser menor a 2.';

  @override
  String playerNumber(int number) {
    return 'Jugador $number';
  }

  @override
  String get newVersionTitle => '¡Nueva versión disponible!';

  @override
  String get newVersionAvailable =>
      'Hay una nueva versión de Coro Games disponible. Actualiza ahora para disfrutar de las últimas mejoras y funcionalidades.';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get unauthorizedVersion => 'Versión No Autorizada';

  @override
  String get illegitimateCopy =>
      'Esta copia de la aplicación no es legítima.\n\nPor favor, descarga la versión oficial desde Google Play Store para disfrutar de todas las funciones.';

  @override
  String get closeApp => 'Cerrar aplicación';

  @override
  String get errorEditingPlayer => 'No se pudo editar el jugador seleccionado.';

  @override
  String get errorDeletingHistory => 'Error eliminando el historial';

  @override
  String get noHistoryForGame => 'Partida ingresada no tiene historiales.';

  @override
  String get minTwoPlayers =>
      'Debe de agregar almenos 2 jugadores a la partida';

  @override
  String get noGamesRegistered => 'No existen partidas registradas.';

  @override
  String get errorDeletingGame => 'No se pudo borrar la partida seleccionada.';

  @override
  String get errorEditingGame => 'No se pudo editar la partida seleccionada.';

  @override
  String get noPlayersForGame => 'Partida ingresada no tiene jugadores.';

  @override
  String get errorDeletingPredefined =>
      'No se pudo borrar la partida predefinida seleccionada.';

  @override
  String get errorEditingPredefined =>
      'No se pudo editar la partida seleccionada.';

  @override
  String get errorInsertingHistory =>
      'Error ingresando el historial de la jugada.';

  @override
  String get fieldRequired => 'Campo requerido.';

  @override
  String minValue(String min) {
    return 'Valor mínimo es: $min';
  }

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutAppTitle => '¿Qué es Coro Games?';

  @override
  String get aboutAppDescription =>
      'Coro Games es tu compañero perfecto para llevar el puntaje de tus juegos de mesa favoritos. Ya sea dominó, cartas, dados o cualquier otro juego, nuestra app te permite registrar puntuaciones, gestionar jugadores y ver el historial de partidas de forma fácil y rápida.';

  @override
  String get privacyPolicyTitle => 'Privacidad y Transparencia';

  @override
  String get privacyPolicyDescription =>
      'En Coro Games respetamos tu privacidad. No solicitamos datos personales como nombres o correos electrónicos.\n\n• Datos de Partida: Se guardan localmente en tu dispositivo y no salen de él.\n\n• Servicios de Terceros: Utilizamos Google Firebase para estadísticas de rendimiento y Google AdMob para mostrar anuncios. Estos servicios pueden recopilar identificadores de publicidad del dispositivo para su correcto funcionamiento.\n\nPuedes consultar nuestra Política de Privacidad completa en el siguiente enlace:';

  @override
  String get viewFullPrivacyPolicy => 'Política de Privacidad';

  @override
  String get reviewCardTitle => '¿Te gusta la app?';

  @override
  String get reviewCardDescription =>
      'Tu calificación nos ayuda a seguir mejorando Coro Games. Déjala directamente en la tienda para que más jugadores nos encuentren.';

  @override
  String get reviewCardButton => 'Calificar ahora';

  @override
  String get reviewFallbackMessage =>
      'No pudimos abrir el cuadro de reseñas. Busca Coro Games en la tienda para dejar tu opinión.';

  @override
  String get noInternetTitle => 'Sin conexión a internet';

  @override
  String get noInternetMessage =>
      'Para utilizar la app necesitas conexión a internet.';

  @override
  String get noInternetWaiting => 'Esperando conexión...';
}
