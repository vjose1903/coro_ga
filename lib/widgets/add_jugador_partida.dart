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
  AddJugador({Key? key, required this.pageController}) : super(key: key);

  final PageController pageController;
  final ScrollController jugadoresController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
    FormGroup form = jugadorProvider.formJugador;
    final Color titleColor = AppThemes.currentTheme == Themes.dark ? Colors.grey.withOpacity(0.9) : AppThemes.colorQuinto.withOpacity(0.7);
    return Container(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          // Titulo
          Align(alignment: Alignment.topLeft, child: Text("Nuevo jugador", style: TextStyle(fontFamily: "Poppins", fontSize: 16, color: titleColor))),
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
          JugadoresActuales(pageController: pageController, jugadoresController: jugadoresController),
          const SizedBox(height: 20),
          // Boton
          //
          ElevatedButton(
            onPressed: () async {
              if (form.valid) {
                final PartidaProvider partidaProvider = context.read<PartidaProvider>();

                Jugador nuevoJugador = Jugador.fromMap(form.value);

                partidaProvider.addJugadorToPartida(context, jugador: nuevoJugador, partida: partidaProvider.partidaEnTurno!).then((value) async {
                  partidaProvider.changePartidaEnTurno(value);
                  form.reset();

                  await Future.delayed(const Duration(milliseconds: 20));
                  jugadoresController.animateTo(jugadoresController.position.maxScrollExtent,
                      duration: const Duration(seconds: 1, milliseconds: 500), curve: Curves.elasticOut);
                });
              } else {
                Fun.toast(type: ToasType.error, context: context, message: "Debe de introducir el nombre del nuevo jugador");
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Agregar", style: TextStyle(fontSize: 15, fontFamily: 'Poppins')),
            ),
          ),
        ],
      ),
    );
  }
}

