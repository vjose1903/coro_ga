import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/models/models.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({Key? key}) : super(key: key);

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  @override
  initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (Preferences.isFirstTimeOpen) context.read<PartidaPredefinidaProvider>().seed();

      openDefaultsPartidasDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();

    googleAdsProvider.loadInterstitialAd();

    return Scaffold(
      body: Layout(
        panelController: SlidingUpPanelController(),
        appBarTitle: "Crear nueva partida",
        appBarLeading: CustomIconButtom(
          iconSize: 25,
          iconColor: Colors.white,
          icon: Icons.arrow_back_ios_new,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context, 'home');
          },
        ),
        bodyContent: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: _Body()),
      ),
    );
  }
}

openDefaultsPartidasDialog(BuildContext context) {
  final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
  formPartidaPredefinidaProvider.resetForm();

  FluidAlerts.show(context,
      rootPage: SizedBox(
        width: (ResponsiveApp.size.width - 40),
        height: (ResponsiveApp.size.height - 150),
        child: const PartidasDefaultAlert(),
      ));
}

class _Body extends StatelessWidget {
  _Body({Key? key}) : super(key: key);

  final ScrollController jugadoresController = ScrollController();

  @override
  Widget build(BuildContext context) {
    //
    return Consumer(builder: (BuildContext context, value, Widget? child) {
      final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
      final form = formPartidaProvider.form;
      final isDarkMode = Preferences.isDarkMode;

      final dynamic tipoPartida = form.control('tipo').value;

      return Container(
          height: ((ResponsiveApp.size.height - (ResponsiveApp.size.height * 0.125)) - 80),
          margin: const EdgeInsets.only(top: 15, bottom: 40),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ReactiveForm(
            formGroup: form,
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomIconButtom(
                      onTap: () => openDefaultsPartidasDialog(context),
                      icon: Icons.apps_rounded,
                      size: IconSize.min,
                      iconSize: 20,
                      iconColor: isDarkMode ? Colors.white.withOpacity(0.4) : AppThemes.colorCuarto.withOpacity(0.7),
                      backgroundColor: isDarkMode ? Colors.white.withOpacity(0.2) : AppThemes.colorCuarto.withOpacity(0.5),
                      splashColor: const Color(0xFF2E7A31),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //
                  const CustomReactiveInput(formControlName: 'nombre', labelText: "Nombre Partida", textCapitalization: TextCapitalization.words),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        width: tipoPartida == '' || tipoPartida == null ? ResponsiveApp.size.width - 52 : ResponsiveApp.size.width * 0.425,
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
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          width: tipoPartida == '' || tipoPartida == null ? 0.01 : ResponsiveApp.size.width * 0.425,
                          child: CustomReactiveInput(
                              formControlName: 'maxPuntuacion',
                              labelText: tipoPartida == "Rondas" ? "Cant. rondas" : "Puntuación Máxima",
                              inputType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Titulo(jugadoresController: jugadoresController),
                  const SizedBox(height: 10),
                  Expanded(
                      child: Material(
                    color: AppThemes.themeColor_2,
                    borderRadius: BorderRadius.circular(12),
                    shadowColor: AppThemes.colorQuinto.withOpacity(0.3),
                    elevation: 7,
                    child: _Inputs(jugadoresController: jugadoresController),
                  )),
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        form.markAllAsTouched();

                        if (form.valid) {
                          final PartidaProvider partidaProvider = context.read<PartidaProvider>();
                          final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();

                          MyLoading.show();
                          final Partida partida = Partida.fromMap(form.value);
                          final response = await partidaProvider.newPartida(partida, context);
                          MyLoading.close();

                          if (!response.hasError!) {
                            crearPartida() {
                              final newPartida = response.data;
                              partidaProvider.changePartidaEnTurno(newPartida);
                              Navigator.pushReplacementNamed(context, 'partida');
                              formPartidaProvider.resetForm();
                            }

                            if (AppEnvironment.isPro) {
                              crearPartida();
                            } else {
                              googleAdsProvider.showInterstitialAd(onCloseFunction: () => crearPartida());
                            }
                            
                          } else {
                            Fun.toast(type: ToasType.error, context: context, message: "Error registrando partida.");
                          }
                        } else {
                          Fun.toast(type: ToasType.warning, context: context, message: "Revisar todos los campos de texto.");
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text("Crear", style: TextStyle(fontSize: 15, fontFamily: 'Poppins')),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
    });
  }
}

class Titulo extends StatelessWidget {
  const Titulo({Key? key, required this.jugadoresController}) : super(key: key);
  final ScrollController jugadoresController;
  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Jugadores', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w100)),
            Container(
              width: 26,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppThemes.colorTercero, borderRadius: BorderRadius.circular(50)),
              child: Center(
                  child: Text(
                formPartidaProvider.jugadores.length.toString(),
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(color: Colors.white),
              )),
            )
          ],
        ),
        Visibility(
          visible: formPartidaProvider.jugadores.length < 20,
          child: CustomIconButtom(
            onTap: () async {
              bool continuar = true;

              if (!AppEnvironment.isPro && formPartidaProvider.jugadores.length > 3) {
                continuar = false;
                Fun.toast(
                    type: ToasType.info,
                    context: context,
                    message: "La version gratis de Coro Games, solo permite 4 jugadores, para agregar más comprar la versión Pro.");
              }

              if (continuar) {
                FocusManager.instance.primaryFocus?.unfocus();
                formPartidaProvider.addJugadorToList();
                await Future.delayed(const Duration(milliseconds: 20));

                jugadoresController.animateTo(jugadoresController.position.maxScrollExtent,
                    duration: const Duration(seconds: 1, milliseconds: 500), curve: Curves.elasticOut);

                if (formPartidaProvider.jugadores.length == 20) {
                  Fun.toast(type: ToasType.info, context: context, message: "Máximo de jugadores alcanzados");
                }
              }
            },
            icon: Icons.add,
            size: IconSize.min,
            iconSize: 25,
            backgroundColor: const Color(0xFF4CAF50),
            splashColor: const Color(0xFF2E7A31),
          ),
        )
      ],
    );
  }
}

class _Inputs extends StatelessWidget {
  const _Inputs({Key? key, required this.jugadoresController}) : super(key: key);
  final ScrollController jugadoresController;
  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();

    final formJugadoresArray = formPartidaProvider.form.control('jugadores') as FormArray<dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ReactiveFormArray(
          formArrayName: 'jugadores',
          builder: (context, formArray, child) {
            final jugadoresInputs = [];
            final Iterable<FormGroup> jugadoresControls = formJugadoresArray.controls.map((control) => control as FormGroup);

            for (var index = 0; index < jugadoresControls.length; index++) {
              final currentform = jugadoresControls.toList()[index];
              jugadoresInputs.add(_JugadorInput(formGroup: currentform, index: index));
            }

            final jugadores = jugadoresInputs.toList();

            return ListView.separated(
              controller: jugadoresController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemCount: jugadores.length,
              itemBuilder: (BuildContext context, int index) {
                return jugadores[index];
              },
            );
          }),
    );
  }
}

class _JugadorInput extends StatelessWidget {
  const _JugadorInput({Key? key, required this.formGroup, required this.index}) : super(key: key);

  final FormGroup formGroup;

  final int index;

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
    return ReactiveForm(
        formGroup: formGroup,
        child: Row(
          children: [
            Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: SizedBox(
                    width: 20,
                    child: Text(
                      (index + 1).toString(),
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.withOpacity(0.6)),
                    ))),
            const SizedBox(width: 5),
            Flexible(
              flex: 12,
              fit: FlexFit.tight,
              child:
                  CustomReactiveInput(key: UniqueKey(), formControlName: 'nombre', labelText: "Nombre", textCapitalization: TextCapitalization.words),
            ),
            const SizedBox(width: 10),
            Visibility(
              visible: index >= 2,
              child: CustomIconButtom(
                  onTap: () => formPartidaProvider.removeJugadorToList(index),
                  icon: Icons.remove,
                  size: IconSize.min,
                  iconSize: 25,
                  backgroundColor: const Color(0xFFAF4C4C),
                  splashColor: const Color(0xFF7A2E2E)),
            )
          ],
        ));
  }
}
