import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scroll_shadow_container/scroll_shadow_container.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:we_slide/we_slide.dart';

class PartidaScreen extends StatelessWidget {
  const PartidaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('------ PartidaScreen ------');
    final PartidasProvider partidaProvider = context.read<PartidasProvider>();
    final WeSlideProvider weSlideProvider = context.watch<WeSlideProvider>();
    final Partida partida = partidaProvider.partidaEnTurno!;

    // MyWeSlide.controller = WeSlideController();

    weSlideProvider.initController(WeSlideController());
    partidaProvider.getPartidas(context, isLoading: false);

    const double panelMinSize = 0;
    final double panelMaxSize = MediaQuery.of(context).size.height * 0.75;

    return Scaffold(
        body: WeSlide(
          controller: weSlideProvider.controller,
          panelMinSize: panelMinSize,
          panelMaxSize: panelMaxSize,
          isDismissible: false,
          overlay: true,
          overlayOpacity: 0.5,
          footerHeight: 75,
          body: _Body(partida: partida),
          panel: const WeSlideContent(),
          footer: const NavigationBar(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Visibility(
          visible: !weSlideProvider.controller!.isOpened,
          child: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, 'formulario', arguments: {"tipo": "crear"}),
            child: const Icon(Icons.add, size: 30),
          ),
        ));
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.partida}) : super(key: key);
  final Partida partida;

  @override
  Widget build(BuildContext context) {
    return Layout(
        appBarTitle: partida.nombre,
        appBarLeading: CustomIconButtom(
          iconSize: 25,
          iconColor: Colors.white,
          icon: Icons.arrow_back_ios_new,
          onTap: () {
            print('VOLVIENDO');
            Navigator.pop(context);
          },
        ),
        bodyContent: Container(
            margin: const EdgeInsets.only(top: 40, bottom: 70),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(children: [
              CustomEstadoPartida(),
              const SizedBox(height: 20),
              const JugadoresCard(),
            ])));
  }
}

class JugadoresCard extends StatelessWidget {
  const JugadoresCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Material(
      color: AppThemes.themeColor_2,
      borderRadius: BorderRadius.circular(12),
      shadowColor: AppThemes.colorTercero.withOpacity(0.3),
      elevation: 7,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.topRight,
              child: CustomIconButtom(icon: Icons.add, iconSize: 25, size: IconSize.min),
            ),
          ),
          Expanded(
              child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              // color: Colors.green,
            ),
            child: const JugadoresList(),
          ))
        ],
      ),
    ));
  }
}

class JugadoresList extends StatelessWidget {
  const JugadoresList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PartidasProvider partidaProvider = context.watch<PartidasProvider>();
    final partida = partidaProvider.partidaEnTurno!;
    Color shadowColor = AppThemes.currentTheme == "dark" ? const Color(0x7B050924) : const Color(0x67325796);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ScrollShadowContainer.custom(
              boxShadow: BoxShadow(blurRadius: 15, spreadRadius: 10, color: shadowColor),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(runSpacing: 20, spacing: 20, children: getJugadores(partida.jugadores!)),
              ))),
    );
  }

  List<Widget> getJugadores(List<Jugador> jugadores) {
    return jugadores.map((jugador) => JugadorInfo(jugador: jugador)).toList();
  }
}

class JugadorInfo extends StatelessWidget {
  const JugadorInfo({Key? key, required this.jugador}) : super(key: key);
  final Jugador jugador;

  @override
  Widget build(BuildContext context) {
    final PartidasProvider partidaProvider = context.read<PartidasProvider>();
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();

    Color fontNombreColor = AppThemes.currentTheme == "dark" ? const Color(0xD26776E6) : const Color(0xE30B4DBF);
    Color? fontPuntuacionColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.8) : const Color(0xDF062864);
    Color? iconEstadoColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.2) : AppThemes.colorSegundo.withOpacity(0.3);

    Map iconEstado = {
      Estado.ganador: Icons.arrow_upward,
      Estado.perdedor: Icons.arrow_downward,
      Estado.empate: Icons.swap_horiz_outlined,
      Estado.not: Icons.remove
    };

    return _CardBackGround(
        // function: () => MyWeSlide.controller!.show(),
        function: () {
          final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
          jugadorProvider.changeJugadorEnTurno(jugador);

          weSlideProvider.openWeSlide();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jugador.nombre!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(fontFamily: "Poppins", fontSize: 17, color: fontNombreColor),
              ),
              Expanded(
                  child: Center(
                      child: Text(
                jugador.puntucacion.toString(),
                textAlign: TextAlign.start,
                style: TextStyle(fontFamily: "Poppins", fontSize: 50, color: fontPuntuacionColor, fontWeight: FontWeight.bold),
              ))),
              Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    iconEstado[partidaProvider.partidaEnTurno!.getJugadorEstatus(jugador)],
                    color: iconEstadoColor,
                  ))
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
              width: screenSize.width * 0.393,
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
    final PartidasProvider partidaProvider = context.read<PartidasProvider>();

    final int selectedIndex = partidaProvider.partidas.indexWhere((partida) => partida.id == partidaProvider.partidaEnTurno!.id);
    await Future.delayed(const Duration(milliseconds: 200));
    if ((selectedIndex <= visibleIndeces.first) || (selectedIndex >= visibleIndeces.last)) {
      itemScrollController.scrollTo(index: selectedIndex, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic, alignment: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppThemes.currentTheme == "dark" ? const Color(0xEB333333) : const Color(0xFFC4D0E5);
    final PartidasProvider partidaProvider = context.watch<PartidasProvider>();
    List<Partida> partidas = partidaProvider.partidas;

    return Container(
      color: backgroundColor,
      child: ScrollablePositionedList.separated(
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: partidas.length,
          padding: const EdgeInsets.only(left: 20),
          itemBuilder: (context, index) {
            return _Chip(index: index, scrollToGame: scrollToGame);
          }),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({Key? key, required this.index, required this.scrollToGame}) : super(key: key);
  final int index;
  final Function scrollToGame;
  Color getChipColor(Partida partida, PartidasProvider partidaProvider) {
    Color colorChipSelected = AppThemes.currentTheme == "dark" ? AppThemes.colorSegundo : AppThemes.colorPrimero;
    Color colorChip = AppThemes.currentTheme == "dark" ? const Color(0xE1494949) : const Color(0xDF787A84);

    Color color = colorChipSelected;
    if (partida.id != partidaProvider.partidaEnTurno!.id) {
      color = colorChip;
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    final PartidasProvider partidaProvider = context.watch<PartidasProvider>();
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
                child: Center(child: Text(partidas[index].nombre!, style: const TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 17))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeSlideContent extends StatelessWidget {
  const WeSlideContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? puntuacion;
    TextEditingController puntuacionController = TextEditingController();
    // final PartidasProvider partidaProvider = context.watch<PartidasProvider>();
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();

    final Color titleColor = AppThemes.currentTheme == "dark" ? Colors.grey.withOpacity(0.9) : AppThemes.colorTercero.withOpacity(0.7);
    final Color subTitleColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.8) : AppThemes.colorTercero.withOpacity(0.9);

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: AppThemes.themeColor_2,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: CustomIconButtom(onTap: () => weSlideProvider.closeWeSlide(), icon: Icons.close, size: IconSize.min, iconSize: 25),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Jugador:", style: TextStyle(fontSize: 18, color: titleColor)),
                  const SizedBox(width: 5),
                  Text(jugadorProvider.nombreJugador, style: TextStyle(fontSize: 17, color: subTitleColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              CustomInputField(
                key: UniqueKey(),
                enabled: false,
                controller: puntuacionController,
                initialValueFn: () => puntuacion,
                onChanged: (value) => puntuacion = value,
                inputType: TextInputType.number,
                labelText: 'Puntuación',
              ),
              const SizedBox(height: 5),
              Expanded(flex: 2, child: Container(decoration: BoxDecoration(color: AppThemes.themeColor_1, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 5),
              _Keyboard(puntuacionController: puntuacionController),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // AUMENTAR ==========================================
                  ExpandedButtom(backgroundColor: Colors.green[400], label: "Aumentar", textColor: Colors.white, onTap: () {}),

                  const SizedBox(width: 10),
                  // REDUCIR ==========================================
                  ExpandedButtom(backgroundColor: Colors.red[400], label: "Reducir", textColor: Colors.white, onTap: () {}),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ));
  }
}

class _Keyboard extends StatelessWidget {
  const _Keyboard({Key? key, required this.puntuacionController}) : super(key: key);

  final TextEditingController puntuacionController;

  void changePuntuacionValue(String value) {
    if (value != "DEL") {
      if (puntuacionController.text == "0" && value == "0") return;
      if (puntuacionController.text == "0" && value != "0") {
        puntuacionController.text = value;
      } else {
        puntuacionController.text = puntuacionController.text += value;
      }
    } else {
      if (puntuacionController.text.isNotEmpty) {
        String texto = puntuacionController.text;
        texto = texto.substring(0, texto.length - 1);
        puntuacionController.text = texto;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppThemes.currentTheme == "dark" ? AppThemes.themeColor_4.withOpacity(0.2) : AppThemes.themeColor_4.withOpacity(0.9);
    return Container(
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(10)),
        child: CustomKeyboard(onChanged: (value) => changePuntuacionValue(value), tipo: KeyboardType.number));
  }
}
