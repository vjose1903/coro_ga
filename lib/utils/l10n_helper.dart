import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../shared_preferences/preferences.dart';

/// Helper para acceder a las traducciones de forma segura
class L10n {
  static bool get _isEnglish => Preferences.languageCode == 'en';

  // Traducciones estáticas para usar sin context (en modelos)
  static String get errorEditingPlayer => _isEnglish ? 'Could not edit the selected player.' : 'No se pudo editar el jugador seleccionado.';

  static String get errorDeletingHistory => _isEnglish ? 'Error deleting history' : 'Error eliminando el historial';

  static String get noHistoryForGame => _isEnglish ? 'The entered game has no history.' : 'Partida ingresada no tiene historiales.';

  static String get minTwoPlayers => _isEnglish ? 'You must add at least 2 players to the game' : 'Debe de agregar almenos 2 jugadores a la partida';

  static String get noGamesRegistered => _isEnglish ? 'No games registered.' : 'No existen partidas registradas.';

  static String get errorDeletingGame => _isEnglish ? 'Could not delete the selected game.' : 'No se pudo borrar la partida seleccionada.';

  static String get errorEditingGame => _isEnglish ? 'Could not edit the selected game.' : 'No se pudo editar la partida seleccionada.';

  static String get noPlayersForGame => _isEnglish ? 'The entered game has no players.' : 'Partida ingresada no tiene jugadores.';

  static String get errorDeletingPredefined => _isEnglish ? 'Could not delete the selected predefined game.' : 'No se pudo borrar la partida predefinida seleccionada.';

  static String get errorEditingPredefined => _isEnglish ? 'Could not edit the selected game.' : 'No se pudo editar la partida seleccionada.';

  static String get errorInsertingHistory => _isEnglish ? 'Error inserting play history.' : 'Error ingresando el historial de la jugada.';

  static String errorDeletingPlayerName(String nombre) => _isEnglish ? 'Error deleting player: $nombre' : 'Error eliminando al jugador: $nombre';

  static String get someHistoryNotDeleted => _isEnglish ? 'Some play history records could not be deleted' : 'Algunos historiales de jugadas no pudieron ser eliminados';

  static String get fieldRequired => _isEnglish ? 'Required field.' : 'Campo requerido.';

  static String minValue(String min) => _isEnglish ? 'Minimum value is: $min' : 'Valor mínimo es: $min';

  /// Obtiene las traducciones del contexto
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  /// Traduce el tipo de partida (Rondas/Puntuación)
  static String getGameType(BuildContext context, String? tipo) {
    if (tipo == null || tipo.isEmpty) return '';

    final l10n = AppLocalizations.of(context)!;

    switch (tipo) {
      case 'Rondas':
        return l10n.gameType_rounds;
      case 'Puntuación':
        return l10n.gameType_score;
      default:
        return tipo;
    }
  }

  /// Traduce el tipo de acción del historial (aumentar/reducir)
  static String getActionType(BuildContext context, String? tipo) {
    if (tipo == null || tipo.isEmpty) return '';

    final l10n = AppLocalizations.of(context)!;

    switch (tipo) {
      case 'aumentar':
        return l10n.increased;
      case 'reducir':
        return l10n.decreased;
      default:
        return tipo;
    }
  }

  /// Traduce el estado del jugador (ganador, perdedor, empate, no aplica)
  static String getPlayerStatus(BuildContext context, String? status) {
    if (status == null || status.isEmpty) return '';

    final l10n = AppLocalizations.of(context)!;

    // Los valores de Estado son: "Ganador", "Perdedor", "Empate", "Not"
    if (status == Estado.ganador) return l10n.winning;
    if (status == Estado.perdedor) return l10n.losing;
    if (status == Estado.empate) return l10n.tie;
    if (status == Estado.not) return '';

    return status;
  }
}
