import 'package:auto_size_text/auto_size_text.dart';
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
    PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    formPartidaPredefinidaProvider.getPartidasPredefinidas();

    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Partidas predefinidas",
                  style: TextStyle(
                      color: Preferences.isDarkMode ? Colors.white : AppThemes.colorCuarto,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 2)),

              const SizedBox(height: 15),
              //

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(color: AppThemes.themeColor_4.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomIconButtom(
                      onTap: () {
                        PartidaPredefinidaProvider partidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
                        PremiumProvider premiumProvider = context.read<PremiumProvider>();

                        if (!premiumProvider.canCreatePredefinedGame(partidaPredefinidaProvider.partidasPredefinidas.length)) {
                          Toast.show(
                              type: ToastType.info,
                              context: context,
                              message:
                                  "La versión gratis solo permite ${PremiumProvider.freeMaxPredefinedGames} partidas predefinidas. ¡Desbloquea PRO para más!");
                          return;
                        }

                        _showFormPartidaDialog(context);
                      },
                      icon: Icons.add,
                      size: IconSize.min,
                      iconSize: 20,
                      backgroundColor: const Color(0xFF4CAF50),
                      splashColor: const Color(0xFF2E7A31),
                    ),
                    Consumer(
                      builder: (BuildContext context, value, Widget? child) {
                        ReorderableProvider reorderableProvider = context.watch<ReorderableProvider>();
                        return Visibility(
                          visible: reorderableProvider.isReording,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Material(
                                    color: Preferences.isDarkMode ? Colors.grey.withValues(alpha: 0.8) : Colors.grey[350],
                                    child: InkWell(
                                        onTap: () => reorderableProvider.isReording = false,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                          child: Text("Listo",
                                              style: TextStyle(
                                                  color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.7) : AppThemes.colorSexto,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 2)),
                                        )))),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              //
              const SizedBox(height: 20),

              Flexible(
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: AppThemes.themeColor_1),
                  child: const PartidasScrollView(),
                ),
              ),
              //
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.red[400]),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                    ),
                    onPressed: () {
                      ReorderableProvider reorderableProvider = context.read<ReorderableProvider>();

                      Navigator.pop(context);
                      reorderableProvider.isReording = false;
                    },
                    child: const Text('Cerrar', style: TextStyle(fontFamily: "Poppins", color: Colors.white))),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFormPartidaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const FormPartidaPredefinida(),
      ),
    );
  }
}

class PartidasScrollView extends StatelessWidget {
  const PartidasScrollView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.watch<PartidaPredefinidaProvider>();

    return FutureBuilder(
      future: getPartidas(context, formPartidaPredefinidaProvider),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        reordenarDataBase() async {
          for (var index = 0; index < snapshot.data.length; index++) {
            PartidaPredefinida partidaPredefinida = snapshot.data[index].partidaPredefinida;
            partidaPredefinida.orden = index + 1;
            final partidaEdit = partidaPredefinida.toMap();
            await PartidaPredefinida.edit(id: partidaPredefinida.id!, partidaEdit: partidaEdit);
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppThemes.colorTercero));
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.gamepad, size: 40, color: Colors.grey.withValues(alpha: 0.7)),
              Text('No hay partidas predefinidas', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Colors.grey[500]))
            ],
          ));
        } else {
          return Consumer(builder: (BuildContext context, value, Widget? child) {
            ReorderableProvider reorderableProvider = context.watch<ReorderableProvider>();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(10),
              child: ReorderableWrap(
                  enableReorder: reorderableProvider.isReording,
                  needsLongPressDraggable: false,
                  runSpacing: 15,
                  spacing: 8,
                  maxMainAxisCount: 3,
                  scrollPhysics: const BouncingScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    reorderableProvider.onReorder(oldIndex: oldIndex, newIndex: newIndex, reordenableList: snapshot.data);
                    reordenarDataBase();
                  },
                  onNoReorder: (index) => reordenarDataBase(),
                  children: snapshot.data),
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
  const ReordenableItem({Key? key, required this.partidaPredefinida}) : super(key: key);
  final PartidaPredefinida partidaPredefinida;

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
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Material(
                color: AppThemes.colorSegundo,
                child: InkWell(
                  onTap: () => !reorderableProvider.isReording
                      ? selectPartidaPredefinida(context: context)
                      : patchFormPartida(context: context, partida: partidaPredefinida),
                  onLongPress: () => reorderableProvider.isReording = true,
                  child: SizedBox(
                    width: ResponsiveApp.size.width * 0.25,
                    height: 90,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: AutoSizeText(partidaPredefinida.nombre!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: reorderableProvider.isReording,
              child: Positioned(
                top: -8,
                left: -8,
                child: CustomIconButtom(
                    onTap: () => deletePartidaPredefinida(context, partidaPredefinida),
                    icon: Icons.remove,
                    size: IconSize.min,
                    iconSize: 25,
                    iconColor: Colors.white,
                    backgroundColor: const Color(0xFFAF4C4C),
                    splashColor: const Color(0xFF7A2E2E)),
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

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const FormPartidaPredefinida(),
      ),
    );
  }
}
