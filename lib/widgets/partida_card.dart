import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/alert_dialog.dart';
import 'icon_scale.dart';
import 'responsive_layout_builder.dart';
import 'text_scale.dart';

class PartidaCard extends StatefulWidget {
  const PartidaCard({
    super.key,
    required this.partida,
    required this.functionBorrar,
    required this.functionEditar,
    required this.functionReiniciar,
    required this.index,
    required this.onTap,
  });

  final int index;
  final Partida partida;
  final Function functionBorrar;
  final Function functionEditar;
  final Function functionReiniciar;
  final Function onTap;

  @override
  State<PartidaCard> createState() => _PartidaCardState();
}

class _PartidaCardState extends State<PartidaCard> {
  late SwipeActionController _swipeController;

  @override
  void initState() {
    super.initState();
    _swipeController = SwipeActionController();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveLayoutBuilder(
      builder: (context, constraints, info) {
        final useLandscapeLayout = info.useLandscapeLayout;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppThemes.themeColor_2,
            borderRadius: useLandscapeLayout ? ResponsiveApp.borderRadius(10) : ResponsiveApp.borderRadius(16),
            border: Border.all(
              color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppThemes.colorCuarto.withValues(alpha: Preferences.isDarkMode ? 0.2 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: useLandscapeLayout ? ResponsiveApp.borderRadius(10) : ResponsiveApp.borderRadius(16),
            child: SwipeActionCell(
              backgroundColor: Colors.transparent,
              key: ValueKey(widget.partida.id),
              controller: _swipeController,
              index: widget.index,
              trailingActions: <SwipeAction>[
                SwipeAction(
                  icon: IconScale(Icons.delete_outline_rounded, color: Colors.white, size: useLandscapeLayout ? 20 : 22),
                  title: l10n.delete,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white),
                  onTap: (CompletionHandler handler) async => widget.functionBorrar(handler),
                  color: Colors.red[400]!,
                ),
                if (!widget.partida.isSinIniciar)
                  SwipeAction(
                    icon: IconScale(Icons.restart_alt_rounded, color: Colors.white, size: useLandscapeLayout ? 20 : 22),
                    title: l10n.restart,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white),
                    onTap: (CompletionHandler handler) async {
                      CustomAlertDialog.show(
                        context,
                        title: l10n.confirm,
                        menssage: l10n.confirmRestartGame(widget.partida.nombre!),
                        dialogType: DialogType.warning,
                        buttonsList: [
                          CustomActionsButtons.cancelButton({
                            'label': l10n.cancel,
                            'onTap': () {
                              Navigator.pop(context);
                              handler(false);
                            }
                          }),
                          CustomActionsButtons.aceptarButton({
                            'label': l10n.accept,
                            'onTap': () async {
                              Navigator.pop(context);
                              await widget.functionReiniciar();
                              await handler(false);
                            }
                          }),
                        ],
                      );
                    },
                    color: Colors.amber[700]!,
                  ),
                SwipeAction(
                    icon: IconScale(Icons.edit_outlined, color: Colors.white, size: useLandscapeLayout ? 20 : 22),
                    title: l10n.edit,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white),
                    onTap: (CompletionHandler handler) async {
                      widget.functionEditar();
                      await handler(false);
                    },
                    color: Colors.blueGrey)
              ],
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onTap(),
                  onLongPress: () => _swipeController.openCellAt(index: widget.index, trailing: true),
                  borderRadius: useLandscapeLayout ? ResponsiveApp.borderRadius(10) : ResponsiveApp.borderRadius(16),
                  child: Padding(
                    padding: useLandscapeLayout ? ResponsiveApp.all(8) : ResponsiveApp.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextScale(
                                      widget.partida.nombre!,
                                      size: 18,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: Preferences.isDarkMode ? Colors.white : AppThemes.colorCuarto,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: ResponsiveApp.symmetric(horizontal: useLandscapeLayout ? 5 : 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppThemes.colorPrimero.withValues(alpha: 0.12),
                                      borderRadius: ResponsiveApp.borderRadius(20),
                                    ),
                                    child: TextScale(
                                      widget.partida.tipo == 'Rondas' ? l10n.gameType_rounds : l10n.gameType_score,
                                      size: useLandscapeLayout ? 12 : 10,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        color: AppThemes.colorPrimero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveApp.scaleHeight(12)),
                              Row(
                                children: [
                                  _InfoChip(
                                    icon: FontAwesomeIcons.users,
                                    label: widget.partida.cantJugadores.toString(),
                                    useLandscapeLayout: useLandscapeLayout,
                                  ),
                                  SizedBox(width: useLandscapeLayout ? ResponsiveApp.scaleWidth(10) : ResponsiveApp.scaleWidth(12)),
                                  Expanded(child: EstadoPartida(partida: widget.partida, useLandscapeLayout: useLandscapeLayout)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: ResponsiveApp.scaleWidth(8)),
                        // Flecha
                        Container(
                          padding: useLandscapeLayout ? ResponsiveApp.all(3) : ResponsiveApp.all(8),
                          decoration: BoxDecoration(
                            color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: IconScale(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey[400],
                            size: useLandscapeLayout ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.useLandscapeLayout});
  final IconData icon;
  final String label;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveApp.symmetric(horizontal: useLandscapeLayout ? 3 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: ResponsiveApp.borderRadius(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          IconScale(icon, size: 11, color: Colors.grey[500]),
          SizedBox(width: ResponsiveApp.scaleWidth(5)),
          TextScale(
            label,
            size: useLandscapeLayout ? 20 : 13,
            style: TextStyle(
              color: Colors.grey[600],
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class EstadoPartida extends StatelessWidget {
  const EstadoPartida({super.key, required this.partida, required this.useLandscapeLayout});

  final Partida partida;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (partida.isSinIniciar) {
      return _EstadoChip(icon: Icons.play_arrow_rounded, label: l10n.starting, color: Colors.blue, useLandscapeLayout: useLandscapeLayout);
    } else if (partida.isEmpate) {
      return _EstadoChip(icon: Icons.swap_horiz_rounded, label: l10n.tie, color: Colors.amber[700]!, useLandscapeLayout: useLandscapeLayout);
    } else {
      return _GanadorPerdedor(partida: partida, useLandscapeLayout: useLandscapeLayout);
    }
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.icon, required this.label, required this.color, required this.useLandscapeLayout});
  final IconData icon;
  final String label;
  final Color color;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveApp.symmetric(horizontal: useLandscapeLayout ? 4 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: ResponsiveApp.borderRadius(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconScale(icon, size: 14, color: color),
          SizedBox(width: useLandscapeLayout ? ResponsiveApp.scaleWidth(3) : ResponsiveApp.scaleWidth(5)),
          TextScale(
            label,
            size: useLandscapeLayout ? 16 : 12,
            style: TextStyle(
              color: color,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GanadorPerdedor extends StatelessWidget {
  const _GanadorPerdedor({super.key, required this.partida, required this.useLandscapeLayout});
  final Partida partida;
  final bool useLandscapeLayout;

  String _getTranslatedName(BuildContext context, String name) {
    if (name == Estado.empate) return AppLocalizations.of(context)!.tie;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final ganador = partida.getGanadorOrPerdedor(tipo: Estado.ganador);
    final perdedor = partida.getGanadorOrPerdedor(tipo: Estado.perdedor);

    return Row(
      children: [
        Expanded(
          child: _PlayerStatus(
            icon: Icons.trending_up_rounded,
            name: _getTranslatedName(context, ganador['nombre']),
            puntuacion: ganador['puntuacion'],
            color: Colors.green,
            useLandscapeLayout: useLandscapeLayout,
          ),
        ),
        SizedBox(width: ResponsiveApp.scaleWidth(8)),
        Expanded(
          child: _PlayerStatus(
            icon: Icons.trending_down_rounded,
            name: _getTranslatedName(context, perdedor['nombre']),
            puntuacion: perdedor['puntuacion'],
            color: Colors.red[400]!,
            useLandscapeLayout: useLandscapeLayout,
          ),
        ),
      ],
    );
  }
}

class _PlayerStatus extends StatelessWidget {
  const _PlayerStatus({required this.icon, required this.name, required this.puntuacion, required this.color, required this.useLandscapeLayout});
  final IconData icon;
  final String name;
  final num puntuacion;
  final Color color;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveApp.symmetric(horizontal: useLandscapeLayout ? 4 : 8, vertical: useLandscapeLayout ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: ResponsiveApp.borderRadius(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconScale(icon, size: 12, color: color),
          SizedBox(width: useLandscapeLayout ? ResponsiveApp.scaleWidth(2) : ResponsiveApp.scaleWidth(4)),
          Expanded(
            child: TextScale(
              name,
              size: useLandscapeLayout ? 16 : 11,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: useLandscapeLayout ? ResponsiveApp.scaleWidth(4) : ResponsiveApp.scaleWidth(8)),
          TextScale(
            puntuacion.toString(),
            size: 11,
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, color: color),
          )
        ],
      ),
    );
  }
}
