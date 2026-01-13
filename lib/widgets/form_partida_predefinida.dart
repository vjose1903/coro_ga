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
    final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.watch<PartidaPredefinidaProvider>();
    final form = formPartidaPredefinidaProvider.form;

    final dynamic tipoPartida = form.control('tipo').value;

    final Color titleColor = Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.7) : AppThemes.colorQuinto.withValues(alpha: 0.8);

    return Consumer(builder: (BuildContext context, value, Widget? child) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formPartidaPredefinidaProvider.partidaPredefinidaEditar != null ? "Editar Partida" : "Crear Partida predefinida",
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
                      children: [
                        Expanded(
                          flex: tipoPartida == '' || tipoPartida == null ? 1 : 1,
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
                        if (tipoPartida != '' && tipoPartida != null) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomReactiveInput(
                                formControlName: 'maxPuntuacion',
                                labelText: tipoPartida == "Rondas" ? "Cant. rondas" : "Puntuación Máxima",
                                inputType: TextInputType.number),
                          ),
                        ],
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
                              onTap: () => formPartidaPredefinidaProvider.changeCantidadJugadores(context: context, tipo: "-"),
                              icon: Icons.remove,
                              size: IconSize.medium,
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
                              onTap: () {
                                PremiumProvider premiumProvider = context.read<PremiumProvider>();

                                if (!premiumProvider.canAddPlayer(formPartidaPredefinidaProvider.cantidadJugadores)) {
                                  Toast.show(
                                      type: ToastType.info,
                                      context: context,
                                      message: "La versión gratis solo permite ${PremiumProvider.freeMaxPlayers} jugadores. ¡Desbloquea PRO para más!");
                                  return;
                                }

                                formPartidaPredefinidaProvider.changeCantidadJugadores(context: context, tipo: "+");
                              },
                              icon: Icons.add,
                              size: IconSize.medium,
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
                            label: "Volver",
                            textColor: Colors.white,
                            onTap: () => DialogNavigator.of(context).pop()),

                        const SizedBox(width: 10),
                        // CREAR ==========================================
                        ExpandedButtom(
                            backgroundColor: Colors.green[400],
                            label: formPartidaPredefinidaProvider.partidaPredefinidaEditar != null ? "Guardar" : "Crear",
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
        googleAdsProvider.showInterstitialAd(onCloseFunction: () {
          DialogNavigator.of(context).pop();
          formPartidaPredefinidaProvider.resetForm();
          googleAdsProvider.loadInterstitialAd();
        });
      } else {
        Toast.show(type: ToastType.error, context: context, message: "Error registrando partida.");
      }
    } else {
      Toast.show(type: ToastType.warning, context: context, message: "Revisar todos los campos de texto.");
    }
  }
}
