import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:scroll_shadow_container/scroll_shadow_container.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:we_slide/we_slide.dart';

class PartidaScreen extends StatelessWidget {
  const PartidaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WeSlideController weSlideController = WeSlideController();

    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final WeSlideProvider weSlideProvider = context.watch<WeSlideProvider>();

        return Scaffold(
            body: _Body(weSlideController: weSlideController),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Visibility(
              visible: !weSlideController.isOpened,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'formulario', arguments: {"tipo": "crear"});
                },
                child: const Icon(Icons.add, size: 30),
              ),
            ));
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.weSlideController}) : super(key: key);

  final WeSlideController weSlideController;
  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    Partida partida = partidaProvider.partidaEnTurno!;
    return Layout(
        weSlideController: weSlideController,
        hasFooter: true,
        initialWeSlideWidgets: const {"footer": NavigationBar()},
        appBarTitle: partida.nombre,
        appBarLeading: CustomIconButtom(
          iconSize: 25,
          iconColor: Colors.white,
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),
        bodyContent: Container(
            margin: const EdgeInsets.only(top: 40, bottom: 70),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(children: [
              const CustomEstadoPartida(),
              const SizedBox(height: 20),
              JugadoresCard(weSlideController: weSlideController),
            ])));
  }
}

class JugadoresCard extends StatelessWidget {
  const JugadoresCard({Key? key, required this.weSlideController}) : super(key: key);
  final WeSlideController weSlideController;

  @override
  Widget build(BuildContext context) {
    openWeSlide() {
      final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();
      weSlideProvider.openWeSlide(controller: weSlideController, body: const AddJugadorPartida());
    }

    return Expanded(
        child: Material(
      color: AppThemes.themeColor_2,
      borderRadius: BorderRadius.circular(12),
      shadowColor: AppThemes.colorCuarto.withOpacity(0.3),
      elevation: 7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
                alignment: Alignment.topRight,
                child: CustomIconButtom(onTap: () => openWeSlide(), icon: Icons.add, iconSize: 25, size: IconSize.min)),
          ),
          Expanded(
              child: Container(
            decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
            child: JugadoresList(weSlideController: weSlideController),
          ))
        ],
      ),
    ));
  }
}

class JugadoresList extends StatelessWidget {
  const JugadoresList({Key? key, required this.weSlideController}) : super(key: key);
  final WeSlideController weSlideController;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final partida = partidaProvider.partidaEnTurno!;
    Color shadowColor = AppThemes.currentTheme == "dark" ? const Color(0x7B050924) : const Color(0x67325796);
    Fun.logColor(color: Colores.yellow, body: "BUILD LIST");
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ScrollShadowContainer.custom(
            boxShadow: BoxShadow(blurRadius: 15, spreadRadius: 10, color: shadowColor),
            child: FutureBuilder(
              future: getJugadores(partida.jugadores!, weSlideController),
              initialData: List<Widget>.from([]),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppThemes.colorSegundo));
                } else {
                  return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(), child: Wrap(runSpacing: 8, spacing: 8, children: snapshot.data));
                }
              },
            ),
          )),
    );
  }

  Future<List<Widget>> getJugadores(List<Jugador> jugadores, WeSlideController weSlideController) async {
    await Future.delayed(const Duration(milliseconds: 10));

    jugadores.sort((a, b) => a.id!.compareTo(b.id!));
    return jugadores.asMap().entries.map((entry) {
      int index = entry.key;
      Jugador jugador = entry.value;

      return ElasticIn(delay: Duration(milliseconds: 100 * index), child: JugadorInfo(jugador: jugador, weSlideController: weSlideController));
    }).toList();
  }
}

class JugadorInfo extends StatelessWidget {
  const JugadorInfo({Key? key, required this.jugador, required this.weSlideController}) : super(key: key);
  final Jugador jugador;
  final WeSlideController weSlideController;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    Color fontNombreColor = AppThemes.currentTheme == "dark" ? const Color(0xD26776E6) : const Color(0xE30B4DBF);
    Color? fontPuntuacionColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.8) : const Color(0xDF062864);
    Color? iconEstadoColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.2) : AppThemes.colorTercero.withOpacity(0.3);

    Map iconEstado = {
      Estado.ganador: Icons.arrow_upward,
      Estado.perdedor: Icons.arrow_downward,
      Estado.empate: Icons.swap_horiz_outlined,
      Estado.not: Icons.compare_arrows_rounded
    };

    return _CardBackGround(
        function: () {
          final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
          final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();
          jugadorProvider.changeJugadorEnTurno(jugador);
          weSlideProvider.openWeSlide(
              controller: weSlideController, body: PuntuacionForm(weSlideController: weSlideController), footer: const NavigationBar());
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
  final boxDecoration = BoxDecoration(
      color: AppThemes.currentTheme == "dark" ? const Color(0x7921233C) : const Color(0x7BA1A6DE), borderRadius: BorderRadius.circular(15));
  final Widget child;
  final Function? function;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => function != null ? function!() : null,
            child: Container(
              height: 130,
              width: screenSize.width * 0.4,
              decoration: boxDecoration,
              child: child,
            ),
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
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  late List<int> visibleIndeces = [];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollToGame(context);
    });

    itemPositionsListener.itemPositions.addListener(() {
      visibleIndeces = itemPositionsListener.itemPositions.value.map((item) => item.index).toList();
    });
  }

  void scrollToGame(BuildContext context) async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    final int selectedIndex = partidaProvider.partidas.indexWhere((partida) => partida.id == partidaProvider.partidaEnTurno!.id);
    await Future.delayed(const Duration(milliseconds: 200));
    if (partidaProvider.partidas.length > 3 && (selectedIndex <= visibleIndeces.first) || (selectedIndex >= visibleIndeces.last)) {
      itemScrollController.scrollTo(index: selectedIndex, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic, alignment: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    List<Partida> partidas = partidaProvider.partidas;

    return Container(
      child: ScrollablePositionedList.separated(
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: partidas.length,
          padding: const EdgeInsets.only(left: 20, right: 150),
          itemBuilder: (context, index) => _Chip(index: index, scrollToGame: scrollToGame)),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({Key? key, required this.index, required this.scrollToGame}) : super(key: key);
  final int index;
  final Function scrollToGame;
  Color getChipColor(Partida partida, PartidaProvider partidaProvider) {
    Color colorChipSelected = AppThemes.currentTheme == "dark" ? AppThemes.colorTercero : AppThemes.colorSegundo;
    Color colorChip = AppThemes.currentTheme == "dark" ? const Color(0xE1494949) : const Color(0xDF787A84);

    Color color = colorChipSelected;
    if (partida.id != partidaProvider.partidaEnTurno!.id) color = colorChip;

    return color;
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    List<Partida> partidas = partidaProvider.partidas;
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: getChipColor(partidas[index], partidaProvider),
        elevation: 5,
        child: ClipRRect(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              partidaProvider.changePartidaEnTurno(partidas[index]);
              scrollToGame(context);
            },
            child: SizedBox(
              height: 35,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(child: Text(partidas[index].nombre!, style: const TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 15))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
