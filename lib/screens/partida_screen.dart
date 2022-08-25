import 'package:animate_do/animate_do.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PartidaScreen extends StatelessWidget {
  const PartidaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SlidingUpPanelController panelController = SlidingUpPanelController();
    GoogleBannerAd anuncio = GoogleBannerAd(location: AdLocation.partida);

    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final SlideUpProvider slideUpProvider = context.watch<SlideUpProvider>();

        return Scaffold(
          body: _Body(panelController: panelController, anuncio: anuncio),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: Visibility(
            visible: panelController.status == SlidingUpPanelStatus.collapsed,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'formulario');
              },
              child: const Icon(Icons.add, size: 30),
            ),
          ),
          bottomNavigationBar: BottomBar(panelController: panelController, child: const NavigationBar()),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.panelController, required this.anuncio}) : super(key: key);

  final SlidingUpPanelController panelController;
  final GoogleBannerAd anuncio;
  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    Partida partida = partidaProvider.partidaEnTurno!;
    return Layout(
        panelController: panelController,
        hasFooter: true,
        appBarTitle: partida.nombre,
        appBarLeading: CustomIconButtom(
          iconSize: 25,
          iconColor: Colors.white,
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),
        bodyContent: Container(
            margin: const EdgeInsets.only(top: 40, bottom: 40),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(children: [
              const CustomEstadoPartida(),
              const SizedBox(height: 20),
              JugadoresCard(panelController: panelController),
              const SizedBox(height: 20),
              if (!AppEnvironment.isPro) anuncio
            ])));
  }
}

class JugadoresCard extends StatelessWidget {
  const JugadoresCard({Key? key, required this.panelController}) : super(key: key);
  final SlidingUpPanelController panelController;

  @override
  Widget build(BuildContext context) {
    openSlideUp() {
      final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
      final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
      jugadorProvider.formJugador.reset();
      slideUpProvider.openSlideUp(controller: panelController, bodyContent: const AddJugadorPartida());
    }

    return Expanded(
        child: Material(
      color: AppThemes.themeColor_2,
      borderRadius: BorderRadius.circular(12),
      shadowColor: AppThemes.colorQuinto.withOpacity(0.3),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Align(
                alignment: Alignment.topRight,
                child: CustomIconButtom(
                    onTap: () {
                      final PartidaProvider partidaProvider = context.read<PartidaProvider>();
                      bool continuar = true;

                      if (!AppEnvironment.isPro && partidaProvider.partidaEnTurno!.jugadores!.length > 3) {
                        continuar = false;
                        Fun.toast(
                            type: ToasType.info,
                            context: context,
                            message: "La version gratis de Coro Games, solo permite 4 jugadores, para agregar más comprar la versión Pro.");
                      }

                      if (continuar) openSlideUp();
                    },
                    icon: Icons.add,
                    iconSize: 25,
                    size: IconSize.min)),
            Expanded(
                child: Container(
              decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
              child: JugadoresList(panelController: panelController),
            ))
          ],
        ),
      ),
    ));
  }
}

class JugadoresList extends StatelessWidget {
  const JugadoresList({Key? key, required this.panelController}) : super(key: key);
  final SlidingUpPanelController panelController;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final partida = partidaProvider.partidaEnTurno!;

    return SizedBox(
      width: double.infinity,
      child: FutureBuilder(
        future: getJugadores(partida.jugadores!, panelController, partidaProvider),
        initialData: List<Widget>.from([]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppThemes.colorTercero));
          } else {
            return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 15,
                  spacing: 0,
                  children: snapshot.data,
                ));
          }
        },
      ),
    );
  }

  Future<List<Widget>> getJugadores(List<Jugador> jugadores, SlidingUpPanelController panelController, PartidaProvider partidaProvider) async {
    await Future.delayed(const Duration(milliseconds: 10));

    jugadores.sort((a, b) => a.id!.compareTo(b.id!));
    return jugadores.asMap().entries.map((entry) {
      int index = entry.key;
      Jugador jugador = entry.value;

      return ConditionalBuilder(
        condition: partidaProvider.isChangePartida,
        builder: (context) {
          return ElasticIn(delay: Duration(milliseconds: 100 * index), child: JugadorInfo(jugador: jugador, panelController: panelController));
        },
        fallback: (context) {
          return JugadorInfo(jugador: jugador, panelController: panelController);
        },
      );
    }).toList();
  }
}

class JugadorInfo extends StatelessWidget {
  const JugadorInfo({Key? key, required this.jugador, required this.panelController}) : super(key: key);
  final Jugador jugador;
  final SlidingUpPanelController panelController;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    Color fontNombreColor = Preferences.isDarkMode ? const Color(0xD26776E6) : const Color(0xE30B4DBF);
    Color? fontPuntuacionColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.8) : const Color(0xDF062864);
    Color? iconEstadoColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.2) : AppThemes.colorCuarto.withOpacity(0.3);

    Map iconEstado = {
      Estado.ganador: Icons.arrow_upward,
      Estado.perdedor: Icons.arrow_downward,
      Estado.empate: Icons.swap_horiz_outlined,
      Estado.not: Icons.compare_arrows_rounded
    };

    return _CardBackGround(
        function: () {
          final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
          final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
          jugadorProvider.changeJugadorEnTurno(jugador);
          slideUpProvider.openSlideUp(controller: panelController, bodyContent: PuntuacionForm(panelController: panelController));
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jugador.nombre!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(fontFamily: "Poppins", fontSize: 15, color: fontNombreColor),
              ),
              Expanded(
                  child: Center(
                      child: Text(
                jugador.puntuacion.toString(),
                textAlign: TextAlign.start,
                style: TextStyle(fontFamily: "Poppins", fontSize: 40, color: fontPuntuacionColor, fontWeight: FontWeight.bold),
              ))),
              Align(
                  alignment: Alignment.centerRight,
                  child: Icon(iconEstado[partidaProvider.partidaEnTurno!.getJugadorEstatus(jugador)], color: iconEstadoColor, size: 18))
            ],
          ),
        ));
  }
}

class _CardBackGround extends StatelessWidget {
  _CardBackGround({Key? key, required this.child, this.function}) : super(key: key);
  final boxDecoration =
      BoxDecoration(color: Preferences.isDarkMode ? const Color(0x7921233C) : const Color(0x7BA1A6DE), borderRadius: BorderRadius.circular(15));
  final Widget child;
  final Function? function;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => function != null ? function!() : null,
          child: Container(
            height: 130,
            width: ResponsiveApp.size.width * 0.4,
            decoration: boxDecoration,
            child: child,
          ),
        ),
      ),
    );
  }
}

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;
  late List<int> visibleIndeces = [];

  @override
  void initState() {
    super.initState();

    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();

    SchedulerBinding.instance.addPostFrameCallback((_) => scrollToGame(context));

    itemPositionsListener.itemPositions.addListener(() {
      visibleIndeces = itemPositionsListener.itemPositions.value.map((item) => item.index).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void scrollToGame(BuildContext context) async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    final int selectedIndex = partidaProvider.partidas.indexWhere((partida) => partida.id == partidaProvider.partidaEnTurno!.id);
    await Future.delayed(const Duration(milliseconds: 200));

    if (partidaProvider.partidas.length > 3 && ((selectedIndex <= visibleIndeces.first) || (selectedIndex >= visibleIndeces.last))) {
      itemScrollController.scrollTo(index: selectedIndex, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic, alignment: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    List<Partida> partidas = partidaProvider.partidas;

    if (partidas.isNotEmpty) {
      return ScrollablePositionedList.separated(
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: partidas.length,
          padding: const EdgeInsets.only(left: 20, right: 150),
          itemBuilder: (context, index) => _Chip(partida: partidas[index], scrollToGame: scrollToGame));
    } else {
      return Container();
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({Key? key, required this.partida, required this.scrollToGame}) : super(key: key);
  final Partida? partida;
  final Function scrollToGame;
  Color getChipColor(Partida partida, PartidaProvider partidaProvider) {
    Color colorChipSelected = Preferences.isDarkMode ? AppThemes.colorCuarto : AppThemes.colorTercero;
    Color colorChip = Preferences.isDarkMode ? const Color(0xE1494949) : const Color(0xDF787A84);

    Color color = colorChipSelected;
    if (partida.id != partidaProvider.partidaEnTurno!.id) color = colorChip;

    return color;
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: getChipColor(partida!, partidaProvider),
        elevation: 5,
        child: ClipRRect(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (partidaProvider.partidaEnTurno?.id != partida!.id) {
                partidaProvider.changePartidaEnTurno(partida!);
                scrollToGame(context);
              }
            },
            child: SizedBox(
              height: 35,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(child: Text(partida!.nombre!, style: const TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 15))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
