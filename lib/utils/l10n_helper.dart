import 'package:flutter/material.dart';
import 'package:game_score/l10n/app_localizations.dart';

/// Helper para acceder a las traducciones de forma segura
class L10n {
  /// Obtiene las traducciones del contexto
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  /// Traduce el tipo de partida (Rondas/Puntuación)
  /// Recibe la clave guardada en BD y retorna el texto traducido
  static String getGameType(BuildContext context, String? tipo) {
    if (tipo == null || tipo.isEmpty) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    // Las claves en BD son "Rondas" y "Puntuación" (español)
    // Las traducimos según el idioma actual
    switch (tipo) {
      case 'Rondas':
        return l10n.gameType_rounds;
      case 'Puntuación':
        return l10n.gameType_score;
      default:
        return tipo; // Fallback al valor original
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

  /// Traduce el estado del jugador (ganador/perdedor/empate)
  static String getPlayerStatus(BuildContext context, String? estado) {
    if (estado == null || estado.isEmpty) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    switch (estado) {
      case 'ganador':
        return l10n.winning;
      case 'perdedor':
        return l10n.losing;
      case 'empate':
        return l10n.tie;
      default:
        return estado;
    }
  }
}

