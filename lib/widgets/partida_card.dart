import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';

class PartidaCard extends StatefulWidget {
  const PartidaCard({
    Key? key,
    required this.partida,
    required this.functionBorrar,
    required this.functionEditar,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final Partida partida;
  final Function functionBorrar;
  final Function functionEditar;
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
    return Container(
      decoration: BoxDecoration(
        color: AppThemes.themeColor_2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Preferences.isDarkMode 
              ? Colors.white.withValues(alpha: 0.08) 
              : Colors.grey.withValues(alpha: 0.15),
          width: 1,
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
        borderRadius: BorderRadius.circular(16),
        child: SwipeActionCell(
          backgroundColor: Colors.transparent,
          key: ValueKey(widget.partida.id),
          controller: _swipeController,
          index: widget.index,
          trailingActions: <SwipeAction>[
            SwipeAction(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
                title: "Borrar",
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                onTap: (CompletionHandler handler) async => widget.functionBorrar(handler),
                color: Colors.red[400]!),
            SwipeAction(
                icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                title: "Editar",
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
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
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                                    fontSize: 16,
                                    color: Preferences.isDarkMode ? Colors.white : AppThemes.colorCuarto,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppThemes.colorPrimero.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.partida.tipo!,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                    color: AppThemes.colorPrimero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _InfoChip(
                                icon: FontAwesomeIcons.users,
                                label: widget.partida.cantJugadores.toString(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: EstadoPartida(partida: widget.partida)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Flecha
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Preferences.isDarkMode 
                            ? Colors.white.withValues(alpha: 0.05) 
                            : Colors.grey.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[400],
                        size: 14,
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
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Preferences.isDarkMode 
            ? Colors.white.withValues(alpha: 0.08) 
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
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
  const EstadoPartida({Key? key, required this.partida}) : super(key: key);

  final Partida partida;

  @override
  Widget build(BuildContext context) {
    if (partida.isSinIniciar) {
      return _EstadoChip(
        icon: Icons.play_arrow_rounded,
        label: "Iniciando",
        color: Colors.blue,
      );
    } else if (partida.isEmpate) {
      return _EstadoChip(
        icon: Icons.swap_horiz_rounded,
        label: "Empate",
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
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
  const _GanadorPerdedor({Key? key, required this.partida}) : super(key: key);
  final Partida partida;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: _PlayerStatus(
            icon: Icons.trending_up_rounded,
            name: partida.getGandorOrPerdedor(tipo: Estado.ganador),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _PlayerStatus(
            icon: Icons.trending_down_rounded,
            name: partida.getGandorOrPerdedor(tipo: Estado.perdedor),
            color: Colors.red[400]!,
          ),
        ),
      ],
    );
  }
}

class _PlayerStatus extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;

  const _PlayerStatus({required this.icon, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
