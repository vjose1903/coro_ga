import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/alert_dialog.dart';
import 'responsive_layout_builder.dart';

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
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppThemes.themeColor_2,
            borderRadius: isLandscape ? ResponsiveApp.borderRadius(10) : ResponsiveApp.borderRadius(16),
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
            borderRadius: isLandscape ? ResponsiveApp.borderRadius(10) : ResponsiveApp.borderRadius(16),
            child: SwipeActionCell(
              backgroundColor: Colors.transparent,
              key: ValueKey(widget.partida.id),
              controller: _swipeController,
              index: widget.index,
              trailingActions: <SwipeAction>[
                SwipeAction(icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22), title: l10n.delete, style: TextStyle(fontFamily: 'Poppins', fontSize: ResponsiveApp.scaleText(12), color: Colors.white), onTap: (CompletionHandler handler) async => widget.functionBorrar(handler), color: Colors.red[400]!),
                if (!widget.partida.isSinIniciar)
                  SwipeAction(
                      icon: const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 22),
                      title: l10n.restart,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: ResponsiveApp.scaleText(12), color: Colors.white),
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
                      color: Colors.amber[700]!),
                SwipeAction(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                    title: l10n.edit,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: ResponsiveApp.scaleText(12), color: Colors.white),
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
                  borderRadius: ResponsiveApp.borderRadius(16),
                  child: Padding(
                    padding: isLandscape ? ResponsiveApp.all(8) : ResponsiveApp.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.partida.nombre!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: ResponsiveApp.scaleText(16),
                                        color: Preferences.isDarkMode ? Colors.white : AppThemes.colorCuarto,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: ResponsiveApp.symmetric(horizontal: isLandscape ? 5 : 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppThemes.colorPrimero.withValues(alpha: 0.12),
                                      borderRadius: ResponsiveApp.borderRadius(20),
                                    ),
                                    child: Text(
                                      widget.partida.tipo == 'Rondas' ? l10n.gameType_rounds : l10n.gameType_score,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: isLandscape ? ResponsiveApp.scaleText(12) : ResponsiveApp.scaleText(10),
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
                                    isLandscape: isLandscape,
                                  ),
                                  SizedBox(width: isLandscape ? ResponsiveApp.scaleWidth(10) : ResponsiveApp.scaleWidth(12)),
                                  Expanded(child: EstadoPartida(partida: widget.partida, isLandscape: isLandscape)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: ResponsiveApp.scaleWidth(8)),
                        // Flecha
                        Container(
                          padding: isLandscape ? ResponsiveApp.all(3) : ResponsiveApp.all(8),
                          decoration: BoxDecoration(
                            color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey[400],
                            size: isLandscape ? ResponsiveApp.scaleWidth(6) : ResponsiveApp.scaleWidth(6),
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
  const _InfoChip({required this.icon, required this.label, required this.isLandscape});
  final IconData icon;
  final String label;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveApp.symmetric(horizontal: isLandscape ? 4 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: ResponsiveApp.borderRadius(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: isLandscape ? ResponsiveApp.scaleWidth(6) : ResponsiveApp.scaleWidth(12), color: Colors.grey[500]),
          SizedBox(width: isLandscape ? ResponsiveApp.scaleWidth(4) : ResponsiveApp.scaleWidth(6)),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isLandscape ? ResponsiveApp.scaleText(20) : ResponsiveApp.scaleText(13),
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
  const EstadoPartida({super.key, required this.partida, required this.isLandscape});

  final Partida partida;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (partida.isSinIniciar) {
      return _EstadoChip(icon: Icons.play_arrow_rounded, label: l10n.starting, color: Colors.blue, isLandscape: isLandscape);
    } else if (partida.isEmpate) {
      return _EstadoChip(icon: Icons.swap_horiz_rounded, label: l10n.tie, color: Colors.amber[700]!, isLandscape: isLandscape);
    } else {
      return _GanadorPerdedor(partida: partida, isLandscape: isLandscape);
    }
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.icon, required this.label, required this.color, required this.isLandscape});
  final IconData icon;
  final String label;
  final Color color;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveApp.symmetric(horizontal: isLandscape ? 4 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: ResponsiveApp.borderRadius(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLandscape ? ResponsiveApp.scaleWidth(8) : ResponsiveApp.scaleWidth(14), color: color),
          SizedBox(width: isLandscape ? ResponsiveApp.scaleWidth(3) : ResponsiveApp.scaleWidth(5)),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isLandscape ? ResponsiveApp.scaleText(16) : ResponsiveApp.scaleText(12),
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
  const _GanadorPerdedor({super.key, required this.partida, required this.isLandscape});
  final Partida partida;
  final bool isLandscape;

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
        Flexible(
          child: _PlayerStatus(
            icon: Icons.trending_up_rounded,
            name: _getTranslatedName(context, ganador['nombre']),
            puntuacion: ganador['puntuacion'],
            color: Colors.green,
            isLandscape: isLandscape,
          ),
        ),
        SizedBox(width: ResponsiveApp.scaleWidth(8)),
        Flexible(
          child: _PlayerStatus(
            icon: Icons.trending_down_rounded,
            name: _getTranslatedName(context, perdedor['nombre']),
            puntuacion: perdedor['puntuacion'],
            color: Colors.red[400]!,
            isLandscape: isLandscape,
          ),
        ),
      ],
    );
  }
}

class _PlayerStatus extends StatelessWidget {
  const _PlayerStatus({required this.icon, required this.name, required this.puntuacion, required this.color, required this.isLandscape});
  final IconData icon;
  final String name;
  final num puntuacion;
  final Color color;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveApp.symmetric(horizontal: isLandscape ? 4 : 8, vertical: isLandscape ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: ResponsiveApp.borderRadius(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLandscape ? ResponsiveApp.scaleWidth(7) : ResponsiveApp.scaleWidth(12), color: color),
          SizedBox(width: isLandscape ? ResponsiveApp.scaleWidth(2) : ResponsiveApp.scaleWidth(4)),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: isLandscape ? ResponsiveApp.scaleText(16) : ResponsiveApp.scaleText(11),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: isLandscape ? ResponsiveApp.scaleWidth(3) : ResponsiveApp.scaleWidth(5)),
          Text(
            puntuacion.toString(),
            style: TextStyle(fontFamily: 'Poppins', fontSize: ResponsiveApp.scaleText(11), fontWeight: FontWeight.w900, color: color),
          )
        ],
      ),
    );
  }
}
