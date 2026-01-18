import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/l10n/app_localizations.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/layout.dart';
import 'package:provider/provider.dart';

class JugadoresActuales extends StatelessWidget {
  const JugadoresActuales({Key? key, required this.pageController, required this.jugadoresController, required this.rebuildWidget}) : super(key: key);
  final PageController pageController;
  final Function rebuildWidget;
  final ScrollController jugadoresController;

  @override
  Widget build(BuildContext context) {
    return ListJugadores(pageController: pageController, jugadoresController: jugadoresController, rebuildWidget: rebuildWidget);
  }
}

class ListJugadores extends StatelessWidget {
  const ListJugadores({Key? key, required this.pageController, required this.jugadoresController, required this.rebuildWidget}) : super(key: key);
  final PageController pageController;
  final ScrollController jugadoresController;
  final Function rebuildWidget;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
    final PageEditarProvider pageEditarProvider = context.read<PageEditarProvider>();

    List<Jugador> jugadores = partidaProvider.partidaEnTurno!.jugadoresSort;
    final double actualPage = pageEditarProvider.getActualPage();

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
              child: FaIcon(
                FontAwesomeIcons.userSlash,
                size: 24,
                color: AppThemes.colorPrimero.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.noPlayers,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
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
    
    return ListView.builder(
      key: UniqueKey(),
      controller: effectiveController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      itemCount: jugadores.length,
      itemBuilder: (context, index) {
        Jugador jugador = jugadores[index];

        pageController.addListener(() async {
          Fun.logColor(color: Colores.yellow, body: "actualPage: $actualPage");

          if (actualPage == 1.0 && pageController.page == 0.0) {
            Fun.logColor(color: Colores.green, body: "ENTREEE");
            await Future.delayed(const Duration(milliseconds: 100));
            rebuildWidget();
          }

          Fun.logColor(color: Colores.red, body: "pageController.page: ${pageController.page}");
          pageEditarProvider.setActualPage(pageController.page);
        });

        return _JugadorItem(
          jugador: jugador,
          index: index,
          canDelete: partidaProvider.partidaEnTurno!.jugadores!.length > 2,
          onEdit: () async {
            jugadorProvider.jugadorEditar = jugador;
            nextPage();
            await Future.delayed(const Duration(milliseconds: 200));
            jugadorProvider.formJugador.patchValue(jugadorProvider.jugadorEditar!.toMap());
          },
          onDelete: () {
            jugadorProvider.deleteJugador(context, jugador: jugador, callBack: (value) async {
              if (value["tipo"] == "aceptar") {
                double actualPosition = jugadoresController.position.pixels;
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

  nextPage() {
    pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }
}

class _JugadorItem extends StatelessWidget {
  const _JugadorItem({
    required this.jugador,
    required this.index,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  final Jugador jugador;
  final int index;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
              ? [Colors.white.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0.02)]
              : [Colors.white, Colors.grey.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
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
                    child: Text(
                      jugador.nombre != null && jugador.nombre!.isNotEmpty 
                          ? jugador.nombre![0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Nombre
                Expanded(
                  child: Text(
                    jugador.nombre ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : AppThemes.colorQuinto,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Puntuación
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppThemes.colorPrimero.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    jugador.puntuacion.toString(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.colorPrimero,
                    ),
                  ),
                ),
                
                // Botón editar
                const SizedBox(width: 8),
                _MiniButton(
                  icon: FontAwesomeIcons.penToSquare,
                  onTap: onEdit,
                ),
                
                // Botón eliminar
                if (canDelete) ...[
                  const SizedBox(width: 6),
                  _MiniButton(
                    icon: FontAwesomeIcons.trash,
                    onTap: onDelete,
                    isDestructive: true,
                  ),
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
    this.isDestructive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

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
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
