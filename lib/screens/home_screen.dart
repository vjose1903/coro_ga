import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:we_slide/we_slide.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    partidaProvider.getPartidas(context, isLoading: true);
    return const MainHome();
  }
}

class MainHome extends StatelessWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WeSlideController weSlideController = WeSlideController();

    openMenuWeSlide() {
      final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();
      weSlideProvider.openWeSlide(controller: weSlideController, body: const _Menu());
    }

    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final WeSlideProvider weSlideProvider = context.watch<WeSlideProvider>();

        return Scaffold(
          body: Layout(
            appBarTitle: 'Mis Partidas',
            appBarTrailing: CustomIconButtom(
              iconSize: 25,
              iconColor: Colors.white,
              icon: Icons.menu,
              onTap: () => openMenuWeSlide(),
            ),
            bodyContent: _Body(weSlideController: weSlideController),
            weSlideController: weSlideController,
          ),
          floatingActionButton: Visibility(
            visible: !weSlideController.isOpened,
            child: FloatingActionButton(
                onPressed: () {
                  FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
                  formPartidaProvider.resetForm();

                  Navigator.pushNamed(context, 'formulario');
                },
                child: const Icon(Icons.add, size: 30)),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.weSlideController}) : super(key: key);
  final WeSlideController weSlideController;

  @override
  Widget build(BuildContext context) {
    // final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    return ListPartidas(weSlideController: weSlideController);
    // return FutureBuilder(
    //   future: partidaProvider.getPartidas(context, isLoading: true),
    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
    //     if (!snapshot.hasData) {
    //       return const Center(
    //         child: CircularProgressIndicator(color: AppThemes.colorSegundo),
    //       );
    //     } else {
    //       return ListPartidas(weSlideController: weSlideController);
    //     }
    //   },
    // );
  }
}

class ListPartidas extends StatelessWidget {
  const ListPartidas({Key? key, required this.weSlideController}) : super(key: key);
  final WeSlideController weSlideController;
  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();

    final List<Partida> partidas = partidaProvider.partidas;

    if (partidas.isEmpty) {
      if (partidaProvider.firstSearch) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.gamepad, size: 40, color: Colors.grey.withOpacity(0.7)),
            Text('No hay partidas iniciadas', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Colors.grey[500]))
          ],
        ));
      } else {
        return Center(
          child: CircularProgressIndicator(color: AppThemes.colorTercero),
        );
      }
    } else {
      return ListView.separated(
          itemCount: partidas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 30),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_, index) {
            return BounceInLeft(
              delay: Duration(milliseconds: 100 * index),
              child: PartidaCard(
                partida: partidas[index],
                onTap: () => partidaProvider.navigateToPartida(context: context, partida: partidas[index]),

                functionBorrar: (handler) async {
                  CustomAlertDialog.show(context,
                      menssage: "Seguro que desea eliminar la partida: ${partidas[index].nombre}",
                      title: "Confirmar",
                      dialogType: DialogType.error,
                      buttonsList: [
                        CustomActionsButtons.cancelButton({"onTap": () => Navigator.pop(context)}),
                        CustomActionsButtons.aceptarButton({"onTap": () => removePartida(context, handler, partidas, index)})
                      ]);
                },
                // functionEditar: () async => partidaProvider.newPartida(partidas[index], context),
                functionEditar: () {
                  FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
                  formPartidaProvider.formPartida.patchValue(partidas[index].toMap());
                  partidaProvider.partidaEditar = partidas[index];
                  weSlideProvider.openWeSlide(controller: weSlideController, body: EditarEntidad(weSlideController: weSlideController));
                },

                index: index,
              ),
            );
          });
    }
  }

  Future removePartida(BuildContext context, CompletionHandler handler, List<Partida> partidas, int index) async {
    Navigator.pop(context);
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final responseFuture = partidaProvider.deletePartida(context, partida: partidas[index], handler: handler);

    return responseFuture;
  }
}

class _Menu extends StatefulWidget {
  const _Menu({Key? key}) : super(key: key);

  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = context.read<ThemeProvider>();

    return Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(top: 10, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Coro Games",
                style: TextStyle(
                    color: Preferences.isDarkMode ? Colors.white : AppThemes.colorCuarto,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2)),
            const SizedBox(height: 30),
            //
            _ConfigGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tema",
                      style: TextStyle(
                          color: Preferences.isDarkMode ? AppThemes.colorPrimero : AppThemes.colorTercero,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  const SizedBox(height: 5),
                  // Container(
                  //   alignment: Alignment.centerRight,
                  //   child: SwitchListTile.adaptive(
                  //       contentPadding: EdgeInsets.zero,
                  //       activeColor: AppThemes.colorTercero,
                  //       title: Text('Tema del sistema',
                  //           style: TextStyle(
                  //             color: Preferences.isDarkMode ? Colors.grey.withOpacity(0.9) : Colors.grey[800]!.withOpacity(0.9),
                  //             fontFamily: 'Poppins',
                  //           )),
                  //       value: Preferences.isSystemMode,
                  //       onChanged: (value) {
                  //         Preferences.isSystemMode = value;
                  //         setState(() {});
                  //       }),
                  // ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Cambiar tema a:",
                            style: TextStyle(
                                color: Preferences.isDarkMode ? Colors.grey.withOpacity(0.9) : Colors.grey[800]!.withOpacity(0.9),
                                fontFamily: 'Poppins',
                                fontSize: 15)),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      onTap: () {
                                        Preferences.isDarkMode = !Preferences.isDarkMode;
                                        themeProvider.changeCurrentTheme();
                                        setState(() {});
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(Preferences.isDarkMode ? "Claro" : "Oscuro",
                                                style: TextStyle(
                                                    color: Preferences.isDarkMode ? Colors.grey.withOpacity(0.7) : Colors.grey,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 15)),
                                            const SizedBox(width: 5),
                                            Icon(Preferences.isDarkMode ? Icons.wb_sunny_outlined : Icons.nights_stay,
                                                color: Preferences.isDarkMode ? Colors.grey.withOpacity(0.7) : Colors.grey.withOpacity(0.9))
                                          ],
                                        ),
                                      )))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class _ConfigGroup extends StatelessWidget {
  const _ConfigGroup({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppThemes.themeColor_1.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}
