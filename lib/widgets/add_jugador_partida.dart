import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
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

    return PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return index == 0 ? AddJugador(pageController: pageController) : EditarEntidad(pageController: pageController);
        });
  }
}

class AddJugador extends StatelessWidget {
  const AddJugador({Key? key, required this.pageController}) : super(key: key);
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
    FormGroup form = jugadorProvider.formJugador;
    final Color titleColor = AppThemes.currentTheme == "dark" ? Colors.grey.withOpacity(0.9) : AppThemes.colorCuarto.withOpacity(0.7);
    return Container(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          // Titulo
          Align(alignment: Alignment.topLeft, child: Text("Nuevo jugador", style: TextStyle(fontFamily: "Poppins", fontSize: 18, color: titleColor))),
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
              child: Text("Jugadores actuales", style: TextStyle(fontFamily: "Poppins", fontSize: 15, color: titleColor))),
          const SizedBox(height: 5),
          // Jugadores Actuales
          //
          JugadoresActuales(pageController: pageController),
          const SizedBox(height: 20),
          // Boton
          //
          ElevatedButton(
            onPressed: () async {
              if (form.valid) {
                final PartidaProvider partidaProvider = context.read<PartidaProvider>();

                Jugador nuevoJugador = Jugador.fromMap(form.value);

                partidaProvider.addJugadorToPartida(context, jugador: nuevoJugador, partida: partidaProvider.partidaEnTurno!).then((value) {
                  partidaProvider.changePartidaEnTurno(value);
                  form.reset();
                });
              } else {
                Fun.toast(type: ToasType.error, context: context, message: "Debe de introducir el nombre del nuevo jugador");
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Agregar", style: TextStyle(fontSize: 20, fontFamily: 'Poppins')),
            ),
          ),
        ],
      ),
    );
  }
}

class JugadoresActuales extends StatelessWidget {
  const JugadoresActuales({Key? key, required this.pageController}) : super(key: key);
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        shadowColor: AppThemes.colorCuarto.withOpacity(0.3),
        elevation: 7,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(color: AppThemes.themeColor_1, child: ListJugadores(pageController: pageController)),
        ),
      ),
    );
  }
}

class ListJugadores extends StatelessWidget {
  const ListJugadores({Key? key, required this.pageController}) : super(key: key);
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
    List<Jugador> jugadores = partidaProvider.partidaEnTurno!.jugadores!;
    jugadores.sort((a, b) => a.id!.compareTo(b.id!));

    Color nombreColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.8) : AppThemes.colorCuarto.withOpacity(0.7);
    Color puntuacionColor = AppThemes.currentTheme == "dark" ? AppThemes.colorPrimero : AppThemes.colorCuarto.withOpacity(0.7);
    final Color iconsColor = AppThemes.currentTheme == "dark" ? Colors.grey.withOpacity(0.9) : AppThemes.colorCuarto.withOpacity(0.7);

    return ListView.separated(
        controller: ScrollController(),
        padding: const EdgeInsets.all(5),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: jugadores.length,
        itemBuilder: (context, index) {
          Jugador jugador = jugadores[index];

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 5),
                  CustomIconButtom(
                    onTap: () {
                      jugadorProvider.jugadorEditar = jugador;
                      nextPage();
                    },
                    icon: Icons.edit_outlined,
                    size: IconSize.min,
                    iconSize: 20,
                    iconColor: iconsColor,
                    splashColor: AppThemes.colorTercero,
                  ),
                  const SizedBox(width: 10),
                  Text(jugador.puntuacion.toString(), style: TextStyle(color: puntuacionColor, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Text(jugador.nombre!, style: TextStyle(color: nombreColor)),
                ],
              ),
              CustomIconButtom(
                  onTap: () => jugadorProvider.deleteJugador(context, jugador: jugador),
                  icon: Icons.delete_forever,
                  size: IconSize.min,
                  iconSize: 20,
                  iconColor: iconsColor,
                  splashColor: Colors.red[900])
            ],
          );
        });
  }

  nextPage() {
    pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }
}
