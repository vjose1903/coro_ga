import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class EditarEntidad extends StatelessWidget {
  const EditarEntidad({Key? key, this.pageController, this.panelController}) : super(key: key);

  final PageController? pageController;
  final SlidingUpPanelController? panelController;
  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();

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

    final Color titleColor = Preferences.isDarkMode ? Colors.grey.withOpacity(0.9) : AppThemes.colorQuinto.withOpacity(0.7);
    final Color subTitleColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.8) : AppThemes.colorQuinto.withOpacity(0.9);

    FormGroup form = tipo == "Partida" ? formPartidaProvider.formPartida : jugadorProvider.formJugador;

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text("Editar $tipo:", style: TextStyle(fontFamily: "Poppins", fontSize: 16, color: titleColor)),
              const SizedBox(width: 7),
              Text(entidad?.nombre ?? "", style: TextStyle(fontFamily: "Poppins", fontSize: 15, color: subTitleColor, fontWeight: FontWeight.bold)),
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
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (panelController != null) slideUpProvider.closeSlideUp(controller: panelController!);
                    if (pageController != null) previusPage(pageController);
                    resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
                    await Future.delayed(const Duration(milliseconds: 200));
                    form.reset();
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
                        panelController: panelController);
                  }),
            ],
          ),
          const SizedBox(height: 10),
          // ANUNCIOS ==========================================
           GoogleAds(tipo: AdType.banner,location: AdLocation.editarEntidad)
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
    final screenSize = MediaQuery.of(context).size;

    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
        final dynamic tipoPartida = formPartidaProvider.formPartida.control('tipo').value;
        return Expanded(
            child: ReactiveForm(
          formGroup: form,
          child: Column(children: <Widget>[
            const CustomReactiveInput(formControlName: 'nombre', labelText: "nombre", textCapitalization: TextCapitalization.words),
            SizedBox(height: tipoPartida == '' ? 25 : 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.none,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      // height: 45,
                      width: tipoPartida == '' ? screenSize.width - 20 : screenSize.width * 0.46,
                      child: CustomReactiveDropDown(
                        formControlName: 'tipo',
                        labelText: "Tipo",
                        items: const [
                          DropdownMenuItem(value: "Rondas", child: Text("Rondas")),
                          DropdownMenuItem(value: "Puntuación", child: Text("Puntuación"))
                        ],
                        onChanged: (value) => formPartidaProvider.changeTipo(value),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: tipoPartida == '' ? 0.01 : screenSize.width * 0.46,
                      child: CustomReactiveInput(
                          formControlName: 'maxPuntuacion',
                          labelText: tipoPartida == "Rondas" ? "Cant. rondas" : "Puntuación Máxima",
                          inputType: TextInputType.number)),
                ),
              ],
            ),
          ]),
        ));
      },
    );
  }
}

aceptarFunction(BuildContext context, dynamic entidad,
    {required FormGroup form,
    required String tipo,
    required JugadorProvider jugadorProvider,
    required PartidaProvider partidaProvider,
    required Function previusPage,
    required Function resetEntidadesEditar,
    SlidingUpPanelController? panelController,
    PageController? pageController}) {
  if (tipo == "Partida") {
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
    if (form.valid) {
      FocusManager.instance.primaryFocus?.unfocus();
      partidaProvider.editPartida(context, partida: entidad, newNombrePartida: form.value["nombre"].toString()).then((value) async {
        entidad.nombre = form.value["nombre"].toString();
        partidaProvider.refresh();
        form.reset();
        resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);

        if (panelController != null) slideUpProvider.closeSlideUp(controller: panelController);
      });
    } else {
      Fun.toast(type: ToasType.error, context: context, message: "El nombre de la partida no puede estar vacio.");
    }
  } else {
    if (form.valid) {
      FocusManager.instance.primaryFocus?.unfocus();
      jugadorProvider.editJugador(context, jugador: entidad, newNombreJugador: form.value["nombre"].toString()).then((value) {
        entidad.nombre = form.value["nombre"].toString();
        partidaProvider.refresh();

        form.reset();
        previusPage(pageController);
        resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
      });
    } else {
      Fun.toast(type: ToasType.error, context: context, message: "El nombre del jugador no puede estar vacio.");
    }
  }
}
