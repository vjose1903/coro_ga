import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class PartidasDefaultAlert extends StatelessWidget {
  const PartidasDefaultAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    formPartidaPredefinidaProvider.getPartidasPredefinidas();

    return Consumer<ReorderableProvider>(
      builder: (BuildContext context, reorderableProvider, Widget? child) {
        return PopScope(
          canPop: !reorderableProvider.isReording,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _PredefinidaHeader(
                  onAdd: () => _addPartidaPredefinida(context),
                  isReordering: reorderableProvider.isReording,
                  onDone: () => reorderableProvider.isReording = false,
                ),
                const SizedBox(height: 16),

                // Lista de partidas
                Flexible(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppThemes.themeColor_1,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const PartidasScrollView(),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón cerrar
                Consumer<ReorderableProvider>(
                  builder: (context, reorderableProvider, child) {
                    return Visibility(
                      visible: !reorderableProvider.isReording,
                      child: _CloseButton(
                        onTap: () {
                          Navigator.pop(context);
                          reorderableProvider.isReording = false;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addPartidaPredefinida(BuildContext context) {
    PartidaPredefinidaProvider partidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    PremiumProvider premiumProvider = context.read<PremiumProvider>();

    if (!premiumProvider.canCreatePredefinedGame(partidaPredefinidaProvider.partidasPredefinidas.length)) {
      Toast.show(
          type: ToastType.info,
          context: context,
          message: "La versión gratis solo permite ${PremiumProvider.freeMaxPredefinedGames} partidas predefinidas.",
          actionLabel: "Obtener PRO",
          onAction: () => Navigator.pushNamed(context, 'premium'));
      return;
    }

    DialogNavigator.of(context).push(FluidDialogPage(
      builder: (context) => const FormPartidaPredefinida(),
    ));
  }
}

class _PredefinidaHeader extends StatelessWidget {
  const _PredefinidaHeader({
    required this.onAdd,
    required this.isReordering,
    required this.onDone,
  });

  final VoidCallback onAdd;
  final bool isReordering;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)]
              : [AppThemes.colorPrimero.withValues(alpha: 0.08), AppThemes.colorPrimero.withValues(alpha: 0.03)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppThemes.colorPrimero.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.colorPrimero.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.layerGroup, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Partidas Predefinidas",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppThemes.colorQuinto,
                  ),
                ),
                Text(
                  isReordering ? "Arrastra para reordenar" : "Toca para seleccionar",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Botones
          if (isReordering)
            _DoneButton(onTap: onDone)
          else
            _AddButton(onTap: onAdd),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF43A047)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppThemes.colorPrimero.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            "Listo",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF5350), Color(0xFFE53935)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 14),
                SizedBox(width: 8),
                Text(
                  "Cerrar",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PartidasScrollView extends StatelessWidget {
  const PartidasScrollView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.watch<PartidaPredefinidaProvider>();

    return FutureBuilder<List<Widget>>(
      future: getPartidas(context, formPartidaPredefinidaProvider),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        reordenarDataBase() async {
          for (var index = 0; index < snapshot.data!.length; index++) {
            PartidaPredefinida partidaPredefinida = (snapshot.data![index] as ReordenableItem).partidaPredefinida;
            partidaPredefinida.orden = index + 1;
            final partidaEdit = partidaPredefinida.toMap();
            await PartidaPredefinida.edit(id: partidaPredefinida.id!, partidaEdit: partidaEdit);
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppThemes.colorPrimero));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppThemes.colorPrimero.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.layerGroup,
                    size: 32,
                    color: AppThemes.colorPrimero.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sin partidas predefinidas',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toca + para crear una',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Consumer(builder: (BuildContext context, value, Widget? child) {
            ReorderableProvider reorderableProvider = context.watch<ReorderableProvider>();

            return LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 8;
                const double padding = 10;
                final double itemWidth = (constraints.maxWidth - (padding * 2) - (spacing * 2)) / 3;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(padding),
                  child: ReorderableWrap(
                      enableReorder: reorderableProvider.isReording,
                      needsLongPressDraggable: false,
                      runSpacing: 15,
                      spacing: spacing,
                      maxMainAxisCount: 3,
                      scrollPhysics: const BouncingScrollPhysics(),
                      onReorder: (oldIndex, newIndex) {
                        reorderableProvider.onReorder(oldIndex: oldIndex, newIndex: newIndex, reordenableList: snapshot.data);
                        reordenarDataBase();
                      },
                      onNoReorder: (index) => reordenarDataBase(),
                      children: snapshot.data!.map<Widget>((widget) {
                        if (widget is ReordenableItem) {
                          return ReordenableItem(
                            partidaPredefinida: widget.partidaPredefinida,
                            itemWidth: itemWidth,
                          );
                        }
                        return widget;
                      }).toList()),
                );
              },
            );
          });
        }
      },
    );
  }
}

Future<List<Widget>> getPartidas(BuildContext context, PartidaPredefinidaProvider formPartidaPredefinidaProvider) async {
  formPartidaPredefinidaProvider.partidasPredefinidas.sort((a, b) => a.orden!.compareTo(b.orden!));

  return formPartidaPredefinidaProvider.partidasPredefinidas.map((partida) {
    return ReordenableItem(partidaPredefinida: partida);
  }).toList();
}

class ReordenableItem extends StatelessWidget {
  const ReordenableItem({Key? key, required this.partidaPredefinida, this.itemWidth}) : super(key: key);
  final PartidaPredefinida partidaPredefinida;
  final double? itemWidth;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, value, Widget? child) {
      ReorderableProvider reorderableProvider = context.watch<ReorderableProvider>();

      return ShakeWidget(
        shakeConstant: ShakeRotateConstant1(),
        autoPlay: reorderableProvider.isReording,
        duration: const Duration(seconds: 11),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: itemWidth ?? ResponsiveApp.size.width * 0.25,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => !reorderableProvider.isReording
                      ? selectPartidaPredefinida(context: context)
                      : patchFormPartida(context: context, partida: partidaPredefinida),
                  onLongPress: () => reorderableProvider.isReording = true,
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Nombre
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 18),
                          child: AutoSizeText(
                            partidaPredefinida.nombre!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      // Cantidad de jugadores
                      Positioned(
                        top: 4,
                        left: 6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.user,
                              size: 8,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${partidaPredefinida.cantidadJugadores ?? 0}',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 9,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tipo de partida
                      Positioned(
                        bottom: 4,
                        right: 6,
                        child: Text(
                          partidaPredefinida.tipo ?? '',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 8,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Botón eliminar
            if (reorderableProvider.isReording)
              Positioned(
                top: -6,
                left: -6,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => deletePartidaPredefinida(context, partidaPredefinida),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.minus, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  deletePartidaPredefinida(BuildContext context, PartidaPredefinida partida) {
    PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();

    CustomAlertDialog.show(context,
        menssage: "Seguro que desea eliminar la partida predefinida: ${partida.nombre}",
        title: "Confirmar",
        dialogType: DialogType.error,
        buttonsList: [
          CustomActionsButtons.cancelButton({"onTap": () => Navigator.pop(context)}),
          CustomActionsButtons.aceptarButton({
            "onTap": () {
              Navigator.pop(context);
              formPartidaPredefinidaProvider.deletePartidaPredefinida(context, partida: partida);
            }
          })
        ]);
  }

  selectPartidaPredefinida({required BuildContext context}) {
    FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
    formPartidaProvider.rellenarFormulario(partidaPredefinida);
    Navigator.pop(context);
  }

  patchFormPartida({required BuildContext context, required PartidaPredefinida partida}) {
    PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    formPartidaPredefinidaProvider.rellenarFormulario(partida);

    DialogNavigator.of(context).push(FluidDialogPage(
      builder: (context) => const FormPartidaPredefinida(),
    ));
  }
}
