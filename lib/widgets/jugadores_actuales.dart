import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import 'widgets.dart';

class JugadoresActuales extends StatelessWidget {
  const JugadoresActuales(
      {required this.jugadoresController,
      required this.rebuildWidget,
      required this.onEditJugador,
      required this.useLandscapeLayout,
      required this.isWide,
      super.key});
  final Function rebuildWidget;
  final ScrollController jugadoresController;
  final bool useLandscapeLayout;
  final bool isWide;
  final Function(Jugador) onEditJugador;

  @override
  Widget build(BuildContext context) {
    return ListJugadores(
      jugadoresController: jugadoresController,
      rebuildWidget: rebuildWidget,
      onEditJugador: onEditJugador,
      useLandscapeLayout: useLandscapeLayout,
      isWide: isWide,
    );
  }
}

class ListJugadores extends StatelessWidget {
  const ListJugadores(
      {required this.jugadoresController,
      required this.rebuildWidget,
      required this.onEditJugador,
      required this.useLandscapeLayout,
      required this.isWide,
      super.key});
  final ScrollController jugadoresController;
  final Function rebuildWidget;
  final Function(Jugador) onEditJugador;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();

    final List<Jugador> jugadores =
        partidaProvider.partidaEnTurno!.jugadoresSort;

    if (jugadores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemes.colorPrimero.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconScale(
                FontAwesomeIcons.userSlash,
                size: 24,
                color: AppThemes.colorPrimero.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            TextScale(
              AppLocalizations.of(context)!.noPlayers,
              size: 12,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Usar el scrollController del SlideUp si está disponible
    final slideUpController = SlideUpScrollController.of(context);
    final effectiveController = slideUpController ?? jugadoresController;

    if (useLandscapeLayout) {
      return GridView.builder(
        controller: effectiveController,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 6,
          mainAxisExtent: isWide ? 70 : 66,
        ),
        itemCount: jugadores.length,
        itemBuilder: (context, index) {
          final Jugador jugador = jugadores[index];

          return _JugadorItem(
            jugador: jugador,
            index: index,
            useLandscapeLayout: useLandscapeLayout,
            isWide: isWide,
            canDelete: partidaProvider.partidaEnTurno!.jugadores!.length > 2,
            onEdit: () => onEditJugador(jugador),
            onDelete: () {
              jugadorProvider.deleteJugador(context, jugador: jugador,
                  callBack: (value) async {
                if (value['tipo'] == 'aceptar') {
                  final double actualPosition =
                      jugadoresController.position.pixels;
                  rebuildWidget();
                  await Future.delayed(const Duration(milliseconds: 50));
                  jugadoresController.jumpTo(actualPosition);
                }
              });
            },
          );
        },
      );
    }

    return ListView.builder(
      controller: effectiveController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      itemCount: jugadores.length,
      itemBuilder: (context, index) {
        final Jugador jugador = jugadores[index];

        return _JugadorItem(
          jugador: jugador,
          index: index,
          useLandscapeLayout: useLandscapeLayout,
          isWide: isWide,
          canDelete: partidaProvider.partidaEnTurno!.jugadores!.length > 2,
          onEdit: () => onEditJugador(jugador),
          onDelete: () {
            jugadorProvider.deleteJugador(context, jugador: jugador,
                callBack: (value) async {
              if (value['tipo'] == 'aceptar') {
                final double actualPosition =
                    jugadoresController.position.pixels;
                rebuildWidget();
                await Future.delayed(const Duration(milliseconds: 50));
                jugadoresController.jumpTo(actualPosition);
              }
            });
          },
        );
      },
    );
  }
}

class _JugadorItem extends StatelessWidget {
  const _JugadorItem({
    required this.jugador,
    required this.index,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
    required this.useLandscapeLayout,
    required this.isWide,
  });

  final Jugador jugador;
  final int index;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.02)
                ]
              : [Colors.white, Colors.grey.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Avatar con inicial
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppThemes.colorPrimero,
                        AppThemes.colorTercero,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: TextScale(
                      jugador.nombre != null && jugador.nombre!.isNotEmpty
                          ? jugador.nombre![0].toUpperCase()
                          : '?',
                      size: 14,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Nombre
                Expanded(
                  child: TextScale(
                    jugador.nombre ?? '',
                    size: 13,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppThemes.colorQuinto,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Puntuación
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppThemes.colorPrimero.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextScale(
                    jugador.puntuacion.toString(),
                    size: isWide ? 12 : 14,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppThemes.colorPrimero,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Botón editar
                _MiniButton(
                    icon: FontAwesomeIcons.penToSquare,
                    onTap: onEdit,
                    isWide: isWide,
                    useLandscapeLayout: useLandscapeLayout),

                // Botón eliminar
                if (canDelete) ...[
                  const SizedBox(width: 6),
                  _MiniButton(
                      icon: FontAwesomeIcons.trash,
                      onTap: onDelete,
                      isDestructive: true,
                      isWide: isWide,
                      useLandscapeLayout: useLandscapeLayout),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.icon,
    required this.onTap,
    required this.isWide,
    required this.useLandscapeLayout,
    this.isDestructive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final color = isDestructive
        ? Colors.red[400]!
        : (isDark ? Colors.grey[400]! : Colors.grey[600]!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconScale(
            icon,
            size: useLandscapeLayout ? (isWide ? 14 : 12) : 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
