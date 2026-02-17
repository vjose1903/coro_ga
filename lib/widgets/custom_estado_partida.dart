import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../shared_preferences/preferences.dart';
import 'icon_scale.dart';
import 'text_scale.dart';

class CustomEstadoPartida extends StatelessWidget {
  const CustomEstadoPartida({required this.useLandscapeLayout, required this.isWide, super.key});
  final bool useLandscapeLayout;
  final bool isWide;

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
      return _GanadorPerdedor(partida: partida, useLandscapeLayout: useLandscapeLayout, isWide: isWide);
    }
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

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
            child: IconScale(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          TextScale(
            label,
            size: 14,
            style: TextStyle(
              fontFamily: 'Poppins',
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
  const _GanadorPerdedor({required this.partida, required this.useLandscapeLayout, required this.isWide});
  final Partida partida;
  final bool useLandscapeLayout;
  final bool isWide;

  String _getTranslatedLabel(BuildContext context, String name) {
    if (name == Estado.empate) return AppLocalizations.of(context)!.tie;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return useLandscapeLayout
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PlayerStatusChip(icon: Icons.trending_up_rounded, label: _getTranslatedLabel(context, partida.getGandorOrPerdedorName(tipo: Estado.ganador)), color: Colors.green, isWinner: true, useLandscapeLayout: useLandscapeLayout, isWide: isWide),
              const SizedBox(height: 10),
              _PlayerStatusChip(icon: Icons.trending_down_rounded, label: _getTranslatedLabel(context, partida.getGandorOrPerdedorName(tipo: Estado.perdedor)), color: Colors.red[400]!, isWinner: false, useLandscapeLayout: useLandscapeLayout, isWide: isWide),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _PlayerStatusChip(icon: Icons.trending_up_rounded, label: _getTranslatedLabel(context, partida.getGandorOrPerdedorName(tipo: Estado.ganador)), color: Colors.green, isWinner: true, useLandscapeLayout: useLandscapeLayout, isWide: isWide),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlayerStatusChip(icon: Icons.trending_down_rounded, label: _getTranslatedLabel(context, partida.getGandorOrPerdedorName(tipo: Estado.perdedor)), color: Colors.red[400]!, isWinner: false, useLandscapeLayout: useLandscapeLayout, isWide: isWide),
              ),
            ],
          );
  }
}

class _PlayerStatusChip extends StatelessWidget {
  const _PlayerStatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isWinner,
    required this.useLandscapeLayout,
    required this.isWide,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool isWinner;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: useLandscapeLayout ? 5 : 10),
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
            child: IconScale(icon, size: isWide ? 16 : 12, color: color),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: TextScale(
              label,
              size: isWide ? 14 : 15,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
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
