import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import 'widgets.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class PartidasDefaultAlert extends StatelessWidget {
  const PartidasDefaultAlert({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    formPartidaPredefinidaProvider.getPartidasPredefinidas();

    return Consumer<ReorderableProvider>(
      builder: (BuildContext context, reorderableProvider, Widget? child) {
        return ResponsiveLayoutBuilder(
          useMediaQuery: true,
          builder: (context, constraints, info) {
            final useLandscapeLayout = info.useLandscapeLayout;

            return PopScope(
              canPop: !reorderableProvider.isReording,
              child: Padding(
                padding: EdgeInsets.all(useLandscapeLayout ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _PredefinidaHeader(
                      onAdd: () => _addPartidaPredefinida(context),
                      isReordering: reorderableProvider.isReording,
                      onDone: () => reorderableProvider.isReording = false,
                      useLandscapeLayout: useLandscapeLayout,
                    ),
                    SizedBox(height: useLandscapeLayout ? 12 : 16),

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
                    SizedBox(height: useLandscapeLayout ? 10 : 14),

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
      },
    );
  }

  void _addPartidaPredefinida(BuildContext context) {
    final PartidaPredefinidaProvider partidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    final PremiumProvider premiumProvider = context.read<PremiumProvider>();

    if (!premiumProvider.canCreatePredefinedGame(partidaPredefinidaProvider.partidasPredefinidas.length)) {
      Toast.show(type: ToastType.info, context: context, message: AppLocalizations.of(context)!.freeVersionLimitPredefined(PremiumProvider.freeMaxPredefinedGames), actionLabel: AppLocalizations.of(context)!.getPro, onAction: () => Navigator.pushNamed(context, 'premium'));
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
    required this.useLandscapeLayout,
  });

  final VoidCallback onAdd;
  final bool isReordering;
  final VoidCallback onDone;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    final avatarSize = (useLandscapeLayout ? ResponsiveApp.scaleWidth(17) : ResponsiveApp.scaleWidth(42)).clamp(28.0, 52.0);
    final iconSize = (useLandscapeLayout ? ResponsiveApp.scaleWidth(5) : ResponsiveApp.scaleWidth(10)).clamp(12.0, 22.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)] : [AppThemes.colorPrimero.withValues(alpha: 0.08), AppThemes.colorPrimero.withValues(alpha: 0.03)],
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
            width: avatarSize,
            height: avatarSize,
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
            child: Center(
              child: IconScale(FontAwesomeIcons.layerGroup, color: Colors.white, size: iconSize),
            ),
          ),
          const SizedBox(width: 12),

          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextScale(
                  AppLocalizations.of(context)!.predefinedGames,
                  size: 16,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppThemes.colorQuinto,
                  ),
                ),
                TextScale(
                  isReordering ? AppLocalizations.of(context)!.dragToReorder : AppLocalizations.of(context)!.tapToSelect,
                  size: 11,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Botones
          if (isReordering) _DoneButton(onTap: onDone) else _AddButton(onTap: onAdd),
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
          child: const IconScale(FontAwesomeIcons.plus, color: Colors.white, size: 16),
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
          child: TextScale(
            AppLocalizations.of(context)!.done,
            size: 13,
            style: TextStyle(
              fontFamily: 'Poppins',
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconScale(FontAwesomeIcons.xmark, color: Colors.white, size: 14),
                const SizedBox(width: 8),
                TextScale(
                  AppLocalizations.of(context)!.close,
                  size: 14,
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
  const PartidasScrollView({super.key});

  @override
  Widget build(BuildContext context) {
    final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.watch<PartidaPredefinidaProvider>();
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<Widget>>(
      future: getPartidas(context, formPartidaPredefinidaProvider),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        reordenarDataBase() async {
          for (var index = 0; index < snapshot.data!.length; index++) {
            final PartidaPredefinida partidaPredefinida = (snapshot.data![index] as ReordenableItem).partidaPredefinida;
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
                  child: IconScale(
                    FontAwesomeIcons.layerGroup,
                    size: 32,
                    color: AppThemes.colorPrimero.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                TextScale(
                  AppLocalizations.of(context)!.noPredefinedGames,
                  size: 14,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                TextScale(
                  AppLocalizations.of(context)!.tapPlusToCreate,
                  size: 12,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Consumer(builder: (BuildContext context, value, Widget? child) {
            final ReorderableProvider reorderableProvider = context.watch<ReorderableProvider>();

            return LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 8;
                const double padding = 10;
                final useLandscapeLayout =
                    ResponsiveLayoutBuilder.maybeOf(context)?.useLandscapeLayout ??
                    (constraints.maxWidth > constraints.maxHeight);
                final itemsPerRow = useLandscapeLayout ? 4 : 3;
                final totalSpacing = spacing * (itemsPerRow - 1);
                final double itemWidth = (constraints.maxWidth - (padding * 2) - totalSpacing) / itemsPerRow;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const IconScale(
                          FontAwesomeIcons.circleInfo,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: TextScale(
                            l10n.predefinedEditHint,
                            size: 12,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.all(padding),
                        child: ReorderableWrap(
                            enableReorder: reorderableProvider.isReording,
                            needsLongPressDraggable: false,
                            runSpacing: 15,
                            spacing: spacing,
                            maxMainAxisCount: itemsPerRow,
                            scrollPhysics: const ClampingScrollPhysics(),
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
                      ),
                    ),
                  ],
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
  const ReordenableItem({super.key, required this.partidaPredefinida, this.itemWidth});
  final PartidaPredefinida partidaPredefinida;
  final double? itemWidth;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, value, Widget? child) {
      final ReorderableProvider reorderableProvider = context.watch<ReorderableProvider>();
      final l10n = AppLocalizations.of(context)!;

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
                  onTap: () => !reorderableProvider.isReording ? selectPartidaPredefinida(context: context) : patchFormPartida(context: context, partida: partidaPredefinida),
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
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: ResponsiveApp.scaleText(13),
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
                            IconScale(
                              FontAwesomeIcons.user,
                              size: 8,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 3),
                            TextScale(
                              '${partidaPredefinida.cantidadJugadores ?? 0}',
                              size: 9,
                              style: TextStyle(
                                fontFamily: 'Poppins',
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
                        child: TextScale(
                          L10n.getGameType(context, partidaPredefinida.tipo),
                          size: 8,
                          style: TextStyle(
                            fontFamily: 'Poppins',
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
            if (reorderableProvider.isReording)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                      ),
                      Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => patchFormPartida(context: context, partida: partidaPredefinida),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const IconScale(FontAwesomeIcons.penToSquare, size: 12, color: Colors.white),
                                  const SizedBox(width: 6),
                                  TextScale(
                                    l10n.edit,
                                    size: 12,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        child: IconScale(FontAwesomeIcons.minus, color: Colors.white, size: 12),
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
    final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    final l10n = AppLocalizations.of(context)!;

    CustomAlertDialog.show(context, menssage: l10n.confirmDeletePredefined(partida.nombre!), title: l10n.confirm, dialogType: DialogType.error, buttonsList: [
      CustomActionsButtons.cancelButton({'label': l10n.cancel, 'onTap': () => Navigator.pop(context)}),
      CustomActionsButtons.aceptarButton({
        'label': l10n.accept,
        'onTap': () {
          Navigator.pop(context);
          formPartidaPredefinidaProvider.deletePartidaPredefinida(context, partida: partida);
        }
      })
    ]);
  }

  selectPartidaPredefinida({required BuildContext context}) {
    final FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
    formPartidaProvider.rellenarFormulario(partidaPredefinida, context: context);
    Navigator.pop(context);
  }

  patchFormPartida({required BuildContext context, required PartidaPredefinida partida}) {
    final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    formPartidaPredefinidaProvider.rellenarFormulario(partida);

    DialogNavigator.of(context).push(FluidDialogPage(
      builder: (context) => const FormPartidaPredefinida(),
    ));
  }
}
