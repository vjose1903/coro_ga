import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/force_update_modal.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ResponsiveApp.setMq(context);

    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    if (partidaProvider.isFirstSearch) partidaProvider.getPartidas();
    return const MainHome();
  }
}

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  late final PanelController panelController;

  @override
  void initState() {
    super.initState();
    panelController = PanelController();
    
    // Verificar actualización al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForceUpdateModal.showIfNeeded(context);
    });
  }

  void openMenuSlideUp() {
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
    slideUpProvider.openSlideUp(
        controller: panelController,
        bodyContent: _Menu(panelController: panelController));
  }

  void navigateToForm() {
    FormPartidaProvider formPartidaProvider =
        context.read<FormPartidaProvider>();
    formPartidaProvider.resetForm();
    Navigator.pushNamed(context, 'formulario');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        // Watch para que se reconstruya cuando cambie el estado del SlideUp o el tema
        context.watch<SlideUpProvider>();
        context.watch<ThemeProvider>();

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Layout(
            appBarTitle: 'Mis Partidas',
            appBarTrailing: CustomIconButtom(
              iconSize: 25,
              iconColor: Colors.white,
              icon: Icons.menu,
              onTap: () => openMenuSlideUp(),
            ),
            bodyContent: _Body(panelController: panelController),
            panelController: panelController,
          ),
          floatingActionButton: Visibility(
            visible: !panelController.isAttached || panelController.isPanelClosed,
            child: FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () {
                  final PartidaProvider partidaProvider =
                      context.read<PartidaProvider>();
                  final PremiumProvider premiumProvider =
                      context.read<PremiumProvider>();

                  if (premiumProvider.canCreateGame(partidaProvider.partidas.length)) {
                    navigateToForm();
                  } else {
                    Toast.show(
                        type: ToastType.info,
                        context: context,
                        message: "La versión gratis solo permite ${PremiumProvider.freeMaxGames} partidas simultáneas.",
                        actionLabel: "Obtener PRO",
                        onAction: () => Navigator.pushNamed(context, 'premium'));
                  }
                },
                child: const Icon(Icons.add, size: 30, color: Colors.white)),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.panelController}) : super(key: key);
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: ListPartidas(panelController: panelController)),
        // Banner de anuncios en la parte inferior
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GoogleBannerAd(location: AdLocation.home),
        ),
      ],
    );
  }
}

class ListPartidas extends StatelessWidget {
  const ListPartidas({Key? key, required this.panelController})
      : super(key: key);
  final PanelController panelController;
  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final List<Partida> partidas = partidaProvider.partidas;

    if (partidas.isEmpty) {
      if (!partidaProvider.isFirstSearch) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.gamepad,
                size: 40, color: Colors.grey.withValues(alpha: 0.7)),
            Text('No hay partidas iniciadas',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Colors.grey[500]))
          ],
        ));
      } else {
        return Center(
          child: CircularProgressIndicator(color: AppThemes.colorTercero),
        );
      }
    } else {
      return ListView.builder(
          itemCount: partidas.length,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          physics: const BouncingScrollPhysics(),
          // Optimización: cachear items para evitar rebuilds
          addAutomaticKeepAlives: true,
          cacheExtent: 300,
          itemBuilder: (_, index) {
            final partida = partidas[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index < partidas.length - 1 ? 30 : 0),
              child: BounceInLeft(
                delay: Duration(milliseconds: 40 * (index < 5 ? index : 5)), // Limitar animación a primeros 5 items
                child: PartidaCard(
                  partida: partida,
                  onTap: () {
                    partidaProvider.changePartidaEnTurno(partida);
                    Navigator.pushNamed(context, 'partida');
                  },

                  functionBorrar: (handler) async {
                    CustomAlertDialog.show(context,
                        menssage:
                            "Seguro que desea eliminar la partida: ${partida.nombre}",
                        title: "Confirmar",
                        dialogType: DialogType.error,
                        buttonsList: [
                          CustomActionsButtons.cancelButton({
                            "onTap": () {
                              Navigator.pop(context);
                              handler(false);
                            }
                          }),
                          CustomActionsButtons.aceptarButton({
                            "onTap": () =>
                                removePartida(context, handler, partidas, index)
                          })
                        ]);
                  },
                  functionEditar: () {
                    FormPartidaProvider formPartidaProvider =
                        context.read<FormPartidaProvider>();
                    SlideUpProvider slideUp = context.read<SlideUpProvider>();
                    formPartidaProvider.form.patchValue(partida.toMap());
                    partidaProvider.partidaEditar = partida;
                    slideUp.openSlideUp(
                        controller: panelController,
                        maxHeightFraction: 0.5,
                        bodyContent:
                            EditarEntidad(panelController: panelController)
                    );
                  },

                  index: index,
                ),
              ),
            );
          });
    }
  }

  Future removePartida(BuildContext context, CompletionHandler handler,
      List<Partida> partidas, int index) async {
    Navigator.pop(context);
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final responseFuture = partidaProvider.deletePartida(context,
        partida: partidas[index], handler: handler);

    return responseFuture;
  }
}

class _Menu extends StatefulWidget {
  final PanelController panelController;

  const _Menu({Key? key, required this.panelController}) : super(key: key);

  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = context.watch<ThemeProvider>();

    return Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(top: 10, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Coro Games",
                style: TextStyle(
                    color: Preferences.isDarkMode
                        ? Colors.white
                        : AppThemes.colorCuarto,
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
                          color: Preferences.isDarkMode
                              ? AppThemes.colorPrimero
                              : AppThemes.colorTercero,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  const SizedBox(height: 5),
                  Container(
                    alignment: Alignment.centerRight,
                    child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeTrackColor: AppThemes.colorTercero,
                        title: Text('Tema del sistema',
                            style: TextStyle(
                              color: Preferences.isDarkMode
                                  ? Colors.grey.withValues(alpha: 0.9)
                                  : Colors.grey[800]!.withValues(alpha: 0.9),
                              fontFamily: 'Poppins',
                            )),
                        value: Preferences.isSystemMode,
                        onChanged: (value) {
                          Preferences.isSystemMode = value;
                          Preferences.isDarkMode = PlatformDispatcher
                                  .instance.platformBrightness ==
                              Brightness.dark;
                          themeProvider.changeCurrentTheme();
                          setState(() {});
                        }),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: Preferences.isSystemMode ? 0.01 : null,
                    curve: Curves.easeOut,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cambiar tema a:",
                              style: TextStyle(
                                  color: Preferences.isDarkMode
                                      ? Colors.grey.withValues(alpha: 0.9)
                                      : Colors.grey[800]!.withValues(alpha: 0.9),
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
                                          Preferences.isDarkMode =
                                              !Preferences.isDarkMode;
                                          themeProvider.changeCurrentTheme();
                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7, horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                  Preferences.isDarkMode
                                                      ? "Claro"
                                                      : "Oscuro",
                                                  style: TextStyle(
                                                      color: Preferences
                                                              .isDarkMode
                                                          ? Colors.grey
                                                              .withValues(alpha: 0.7)
                                                          : Colors.grey,
                                                      fontFamily: 'Poppins',
                                                      fontSize: 15)),
                                              const SizedBox(width: 5),
                                              Icon(
                                                  Preferences.isDarkMode
                                                      ? Icons.wb_sunny_outlined
                                                      : Icons.nights_stay,
                                                  color: Preferences.isDarkMode
                                                      ? Colors.grey
                                                          .withValues(alpha: 0.7)
                                                      : Colors.grey
                                                          .withValues(alpha: 0.9))
                                            ],
                                          ),
                                        )))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Premium
            Consumer<PremiumProvider>(
              builder: (context, premiumProvider, child) {
                return _ConfigGroup(
                  child: InkWell(
                    onTap: () {
                      final navigator = Navigator.of(context);
                      final slideUpProvider = context.read<SlideUpProvider>();
                      // Cerrar el SlideUp correctamente (limpia estado y backdrop)
                      slideUpProvider.closeSlideUp(controller: widget.panelController);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        navigator.pushNamed('premium');
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppThemes.colorTercero.withValues(alpha: Preferences.isDarkMode ? 0.3 : 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/img/corona-pro.png',
                              width: 36,
                              height: 36,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  premiumProvider.isPremium
                                      ? "Eres PRO"
                                      : "Obtener PRO",
                                  style: TextStyle(
                                    color: Preferences.isDarkMode
                                        ? Colors.white
                                        : AppThemes.colorCuarto,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  premiumProvider.isPremium
                                      ? "Todas las funciones desbloqueadas"
                                      : "Sin anuncios y funciones ilimitadas",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            premiumProvider.isPremium
                                ? Icons.check_circle
                                : Icons.arrow_forward_ios,
                            color: premiumProvider.isPremium
                                ? Colors.green
                                : Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
      decoration: BoxDecoration(
          color: AppThemes.themeColor_1.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}
