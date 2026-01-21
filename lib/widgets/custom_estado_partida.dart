import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/l10n/app_localizations.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:provider/provider.dart';

class CustomEstadoPartida extends StatelessWidget {
  const CustomEstadoPartida({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final partida = partidaProvider.partidaEnTurno!;
    final l10n = AppLocalizations.of(context)!;

    if (partida.isSinIniciar) {
      return _EstadoChip(
        icon: Icons.play_arrow_rounded,
        label: l10n.gameStarting,
        color: Colors.blue,
      );
    } else if (partida.isEmpate) {
      return _EstadoChip(
        icon: Icons.swap_horiz_rounded,
        label: l10n.tie,
        color: Colors.amber[700]!,
      );
    } else {
      return _GanadorPerdedor(partida: partida);
    }
  }
}

class _EstadoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _EstadoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    // Mismo ancho que los 2 tags de ganador/perdedor juntos + el espacio entre ellos
    final double totalWidth = (ResponsiveApp.size.width * 0.38 * 2) + 12;
    
    return Container(
      width: totalWidth,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: ResponsiveApp.scaleText(14),
              fontWeight: FontWeight.w600,
              color: Preferences.isDarkMode ? color : color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _GanadorPerdedor extends StatelessWidget {
  const _GanadorPerdedor({Key? key, required this.partida}) : super(key: key);
  final Partida partida;

  String _getTranslatedLabel(BuildContext context, String name) {
    if (name == Estado.empate) return AppLocalizations.of(context)!.tie;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PlayerStatusChip(
          icon: Icons.trending_up_rounded,
          label: _getTranslatedLabel(context, partida.getGandorOrPerdedorName(tipo: Estado.ganador)),
          color: Colors.green,
          isWinner: true,
        ),
        const SizedBox(width: 12),
        _PlayerStatusChip(
          icon: Icons.trending_down_rounded,
          label: _getTranslatedLabel(context, partida.getGandorOrPerdedorName(tipo: Estado.perdedor)),
          color: Colors.red[400]!,
          isWinner: false,
        ),
      ],
    );
  }
}

class _PlayerStatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isWinner;

  const _PlayerStatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveApp.size.width * 0.38,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: ResponsiveApp.scaleText(14),
                fontWeight: FontWeight.w600,
                color: Preferences.isDarkMode ? color : color.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
