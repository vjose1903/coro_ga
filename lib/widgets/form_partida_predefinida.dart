import 'package:fluid_dialog/fluid_dialog.dart';
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

class FormPartidaPredefinida extends StatelessWidget {
  const FormPartidaPredefinida({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();
    final form = formPartidaPredefinidaProvider.form;
    googleAdsProvider.loadInterstitialAd();

    final Color titleColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.7) : AppThemes.colorQuinto.withOpacity(0.8);

    return Consumer(builder: (BuildContext context, value, Widget? child) {
      final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.watch<PartidaPredefinidaProvider>();
      final dynamic tipoPartida = form.control('tipo').value;

      return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Crear Partida predefinida",
                style: TextStyle(
                    color: Preferences.isDarkMode ? Colors.white : AppThemes.colorCuarto,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2)),
            const SizedBox(height: 35),
            ReactiveForm(
              formGroup: form,
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //
                    const CustomReactiveInput(formControlName: 'nombre', labelText: "Nombre Partida", textCapitalization: TextCapitalization.words),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          // width: tipoPartida == '' || tipoPartida == null ? screenSize.width - 55 : screenSize.width * 0.415,
                          width: tipoPartida == '' || tipoPartida == null ? ResponsiveApp.size.width - 55 : ResponsiveApp.size.width * 0.42,

                          child: CustomReactiveDropDown(
                            formControlName: 'tipo',
                            labelText: "Tipo",
                            items: const [
                              DropdownMenuItem(value: "Rondas", child: Text("Rondas")),
                              DropdownMenuItem(value: "Puntuación", child: Text("Puntuación"))
                            ],
                            onChanged: (value) => formPartidaPredefinidaProvider.changeTipo(value),
                          ),
                        ),
                        AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            width: tipoPartida == '' || tipoPartida == null ? 0.01 : ResponsiveApp.size.width * 0.42,
                            child: CustomReactiveInput(
                                formControlName: 'maxPuntuacion',
                                labelText: tipoPartida == "Rondas" ? "Cant. rondas" : "Puntuación Máxima",
                                inputType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("Cantidad de jugadores", style: TextStyle(fontFamily: "Poppins", fontSize: 15, color: titleColor)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          flex: 1,
                          child: CustomIconButtom(
                              tooltip: "Quitar jugador",
                              onTap: () => formPartidaPredefinidaProvider.changeCantidadJugadores(context: context, tipo: "-"),
                              icon: Icons.remove,
                              iconColor: Colors.white,
                              backgroundColor: const Color(0xFFAF4C4C),
                              splashColor: const Color(0xFF7A2E2E)),
                        ),
                        //
                        Flexible(
                          flex: 5,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            height: 45,
                            decoration: BoxDecoration(color: AppThemes.inputColor, borderRadius: BorderRadius.circular(15)),
                            child: Center(
                                child: Text(
                              formPartidaPredefinidaProvider.form.control("cantidadJugadores").value.toString(),
                              style: const TextStyle(fontFamily: "Poppins", fontSize: 20),
                            )),
                          ),
                        ),

                        Flexible(
                          flex: 1,
                          child: CustomIconButtom(
                              tooltip: "Agregar jugador",
                              onTap: () {
                                bool continuar = true;

                                if (!AppEnvironment.isPro && formPartidaPredefinidaProvider.cantidadJugadores > 3) {
                                  continuar = false;
                                  Fun.toast(
                                      type: ToasType.info,
                                      context: context,
                                      message: "La version gratis de Coro Games, solo permite 4 jugadores, para agregar más comprar la versión Pro.");
                                }

                                if (continuar) {
                                  formPartidaPredefinidaProvider.changeCantidadJugadores(context: context, tipo: "+");
                                }
                              },
                              icon: Icons.add,
                              iconColor: Colors.white,
                              backgroundColor: const Color(0xFF4CAF50),
                              splashColor: const Color(0xFF2E7A31)),
                        )
                      ],
                    ),
                    const SizedBox(height: 70),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // CERRAR ==========================================
                        ExpandedButtom(
                            backgroundColor: Colors.red[400],
                            label: "Cerrar",
                            textColor: Colors.white,
                            onTap: () {
                              final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();
                              googleAdsProvider.loadInterstitialAd();
                              formPartidaPredefinidaProvider.partidaPredefinidaEditar = null;
                              DialogNavigator.of(context).pop();
                            }),

                        const SizedBox(width: 10),
                        // CREAR ==========================================
                        ExpandedButtom(
                            backgroundColor: Colors.green[400],
                            label: formPartidaPredefinidaProvider.partidaPredefinidaEditar == null ? "Crear" : "Editar",
                            textColor: Colors.white,
                            onTap: () => crearEditarPartida(context: context, form: form)),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  crearEditarPartida({required FormGroup form, required BuildContext context}) async {
    final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
    form.markAllAsTouched();

    if (form.valid) {
      final PartidaPredefinidaProvider partidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
      final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();

      SqlResponse response = SqlResponse();

      if (formPartidaPredefinidaProvider.partidaPredefinidaEditar != null) {
        response = await partidaPredefinidaProvider.editPartida(context,
            partida: formPartidaPredefinidaProvider.partidaPredefinidaEditar!, partidaEdit: form.value);
      } else {
        final PartidaPredefinida partida = PartidaPredefinida.fromMap(form.value);
        response = await partidaPredefinidaProvider.newPartida(partida: partida);
      }

      if (!response.hasError!) {
        formPartidaPredefinidaProvider.partidaPredefinidaEditar = null;
        cerrarForm() {
          DialogNavigator.of(context).pop();
          formPartidaPredefinidaProvider.resetForm();
        }

        if (AppEnvironment.isPro) {
          cerrarForm();
        } else {
          googleAdsProvider.showInterstitialAd(onCloseFunction: () => cerrarForm());
        }
      } else {
        Fun.toast(type: ToasType.error, context: context, message: "Error registrando partida.");
      }
    } else {
      Fun.toast(type: ToasType.warning, context: context, message: "Revisar todos los campos de texto.");
    }
  }
}
