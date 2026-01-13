import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AddJugadorPartida extends StatelessWidget {
  const AddJugadorPartida({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    GoogleBannerAd anuncio = GoogleBannerAd(location: AdLocation.agregarJugador);
    return PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return index == 0 ? AddJugador(pageController: pageController, anuncio: anuncio) : EditarEntidad(pageController: pageController);
        });
  }
}

class AddJugador extends StatefulWidget {
  AddJugador({Key? key, required this.pageController, required this.anuncio}) : super(key: key);

  final PageController pageController;
  final GoogleBannerAd anuncio;

  @override
  State<AddJugador> createState() => _AddJugadorState();
}

class _AddJugadorState extends State<AddJugador> {
  final ScrollController jugadoresController = ScrollController();

  rebuildWidget() {
    Fun.logColor(color: Colores.magenta, body: "mounted: $mounted");
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
    FormGroup form = jugadorProvider.formJugador;

    final Color titleColor = Preferences.isDarkMode ? Colors.grey.withValues(alpha: 0.9) : AppThemes.colorQuinto.withValues(alpha: 0.7);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      controller: ScrollController(),
      child: SizedBox(
        height: (ResponsiveApp.size.height - (ResponsiveApp.size.height * 0.22)),
        child: Column(
          children: [
            // Titulo
            Align(
                alignment: Alignment.topLeft, child: Text("Nuevo jugador", style: TextStyle(fontFamily: "Poppins", fontSize: 16, color: titleColor))),
            const SizedBox(height: 5),
            //
            // Input Nombre
            ReactiveForm(
              formGroup: form,
              child: Column(children: const <Widget>[
                CustomReactiveInput(formControlName: 'nombre', labelText: "nombre", textCapitalization: TextCapitalization.words)
              ]),
            ),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.topLeft,
                child: Text("Jugadores actuales", style: TextStyle(fontFamily: "Poppins", fontSize: 12, color: titleColor))),
            const SizedBox(height: 5),
            // Jugadores Actuales
            //
            JugadoresActuales(pageController: widget.pageController, jugadoresController: jugadoresController, rebuildWidget: rebuildWidget),
            const SizedBox(height: 20),
            // Boton
            //
            ElevatedButton(
              onPressed: () async {
                final PartidaProvider partidaProvider = context.read<PartidaProvider>();
                final PremiumProvider premiumProvider = context.read<PremiumProvider>();
                
                if (!premiumProvider.canAddPlayer(partidaProvider.partidaEnTurno!.jugadores!.length)) {
                  Toast.show(
                      type: ToastType.info,
                      context: context,
                      message: "La versión gratis solo permite ${PremiumProvider.freeMaxPlayers} jugadores. ¡Desbloquea Premium para más!");
                  return;
                }
                
                if (form.valid) {
                  final PartidaProvider partidaProvider = context.read<PartidaProvider>();

                  Jugador nuevoJugador = Jugador.fromMap(form.value);

                  partidaProvider.addJugadorToPartida(context, jugador: nuevoJugador, partida: partidaProvider.partidaEnTurno!).then((value) async {
                    form.reset();
                    rebuildWidget();

                    await Future.delayed(const Duration(milliseconds: 50));

                    jugadoresController.animateTo(jugadoresController.position.maxScrollExtent,
                        duration: const Duration(seconds: 1), curve: Curves.easeOutCubic);
                  });
                } else {
                  Toast.show(type: ToastType.error, context: context, message: "Debe de introducir el nombre del nuevo jugador");
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Agregar", style: TextStyle(fontSize: 15, fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(height: 10),
            // ANUNCIOS ==========================================
            widget.anuncio
          ],
        ),
      ),
    );
  }
}
