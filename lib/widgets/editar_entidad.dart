import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:we_slide/we_slide.dart';

class EditarEntidad extends StatelessWidget {
  const EditarEntidad({Key? key, this.pageController, this.weSlideController}) : super(key: key);

  final PageController? pageController;
  final WeSlideController? weSlideController;
  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();

    Jugador? jugador = jugadorProvider.jugadorEditar;
    Partida? partida = partidaProvider.partidaEditar;

    late String tipo;
    dynamic entidad;

    if (partida != null) {
      tipo = "Partida";
      entidad = partida;
    } else {
      tipo = "Jugador";
      entidad = jugador;
    }

    final Color titleColor = AppThemes.currentTheme == "dark" ? Colors.grey.withOpacity(0.9) : AppThemes.colorCuarto.withOpacity(0.7);
    final Color subTitleColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.8) : AppThemes.colorCuarto.withOpacity(0.9);

    FormGroup form = tipo == "Partida" ? partidaProvider.formPartida : jugadorProvider.formJugador;

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          Row(
            children: [
              Text("Editar $tipo:", style: TextStyle(fontFamily: "Poppins", fontSize: 18, color: titleColor)),
              const SizedBox(width: 7),
              Text(entidad?.nombre ?? "", style: TextStyle(fontFamily: "Poppins", fontSize: 17, color: subTitleColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          if (tipo == "Partida") EditPartida(form: form) else EditJugador(form: form),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // CANCELAR ==========================================
              ExpandedButtom(
                  backgroundColor: Colors.red[400],
                  label: "Cancelar",
                  textColor: Colors.white,
                  onTap: () async {
                    if (weSlideController != null) weSlideProvider.closeWeSlide(controller: weSlideController!);
                    if (pageController != null) previusPage(pageController);
                    resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
                  }),

              const SizedBox(width: 10),
              // ACEPTAR ==========================================
              ExpandedButtom(
                  backgroundColor: Colors.green[400],
                  label: "Aceptar",
                  textColor: Colors.white,
                  onTap: () {
                    aceptarFunction(context, entidad,
                        form: form,
                        jugadorProvider: jugadorProvider,
                        partidaProvider: partidaProvider,
                        previusPage: previusPage,
                        resetEntidadesEditar: resetEntidadesEditar,
                        tipo: tipo,
                        pageController: pageController,
                        weSlideController: weSlideController);
                  }),
            ],
          ),
        ],
      ),
    );
  }

  previusPage(pageController) async {
    pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }

  resetEntidadesEditar({required JugadorProvider jugadorProvider, required PartidaProvider partidaProvider}) async {
    await Future.delayed(const Duration(seconds: 1));
    jugadorProvider.jugadorEditar = null;
    partidaProvider.partidaEditar = null;
  }
}

class EditJugador extends StatelessWidget {
  const EditJugador({Key? key, required this.form}) : super(key: key);

  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ReactiveForm(
      formGroup: form,
      child: Column(children: const <Widget>[
        CustomReactiveInput(formControlName: 'nombre', labelText: "nombre", textCapitalization: TextCapitalization.words)
      ]),
    ));
  }
}

class EditPartida extends StatelessWidget {
  const EditPartida({Key? key, required this.form}) : super(key: key);

  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ReactiveForm(
      formGroup: form,
      child: Column(children: const <Widget>[
        CustomReactiveInput(formControlName: 'nombre', labelText: "nombre", textCapitalization: TextCapitalization.words)
      ]),
    ));
  }
}

aceptarFunction(BuildContext context, dynamic entidad,
    {required FormGroup form,
    required String tipo,
    required JugadorProvider jugadorProvider,
    required PartidaProvider partidaProvider,
    required Function previusPage,
    required Function resetEntidadesEditar,
    WeSlideController? weSlideController,
    PageController? pageController}) {
  if (tipo == "Partida") {
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();
    if (form.valid) {
      partidaProvider.editPartida(context, partida: entidad, newNombrePartida: form.value["nombre"].toString()).then((value) async {
        entidad.nombre = form.value["nombre"].toString();
        partidaProvider.refresh();
        form.reset();
        resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);

        if (weSlideController != null) weSlideProvider.closeWeSlide(controller: weSlideController);
      });
    } else {
      Fun.toast(type: ToasType.error, context: context, message: "El nombre de la partida no puede estar vacio.");
    }
  } else {
    Fun.logColor(color: Colores.magenta, body: "EDITANDO JUGADOR");
    if (form.valid) {
      jugadorProvider.editJugador(context, jugador: entidad, newNombreJugador: form.value["nombre"].toString()).then((value) {
        entidad.nombre = form.value["nombre"].toString();
        partidaProvider.refresh();
        form.reset();
        print(previusPage);
        previusPage(pageController);
        resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
      });
    } else {
      Fun.toast(type: ToasType.error, context: context, message: "El nombre del jugador no puede estar vacio.");
    }
  }
}
