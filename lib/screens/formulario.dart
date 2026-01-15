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
      if (Preferences.isFirstTimeOpen)
        context.read<PartidaPredefinidaProvider>().seed();

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
        bodyContent: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), child: _Body()),
      ),
    );
  }
}

openDefaultsPartidasDialog(BuildContext context) {
  final PartidaPredefinidaProvider formPartidaPredefinidaProvider =
      context.read<PartidaPredefinidaProvider>();
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
      final FormPartidaProvider formPartidaProvider =
          context.watch<FormPartidaProvider>();
      final form = formPartidaProvider.form;
      final isDarkMode = Preferences.isDarkMode;

      final dynamic tipoPartida = form.control('tipo').value;

      return Container(
          height: ((ResponsiveApp.size.height -
                  (ResponsiveApp.size.height * 0.125)) -
              80),
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
                      iconColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppThemes.colorCuarto.withValues(alpha: 0.7),
                      backgroundColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppThemes.colorCuarto.withValues(alpha: 0.5),
                      splashColor: const Color(0xFF2E7A31),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //
                  const CustomReactiveInput(
                      formControlName: 'nombre',
                      labelText: "Nombre Partida",
                      textCapitalization: TextCapitalization.words),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        width: tipoPartida == '' || tipoPartida == null
                            ? ResponsiveApp.size.width - 52
                            : ResponsiveApp.size.width * 0.425,
                        child: CustomReactiveDropDown(
                          formControlName: 'tipo',
                          labelText: "Tipo",
                          items: const [
                            DropdownMenuItem(
                                value: "Rondas", child: Text("Rondas")),
                            DropdownMenuItem(
                                value: "Puntuación", child: Text("Puntuación"))
                          ],
                          onChanged: (value) =>
                              formPartidaProvider.changeTipo(value),
                        ),
                      ),
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          width: tipoPartida == '' || tipoPartida == null
                              ? 0.01
                              : ResponsiveApp.size.width * 0.425,
                          child: CustomReactiveInput(
                              formControlName: 'maxPuntuacion',
                              labelText: tipoPartida == "Rondas"
                                  ? "Cant. rondas"
                                  : "Puntuación Máxima",
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
                    shadowColor: AppThemes.colorQuinto.withValues(alpha: 0.3),
                    elevation: 7,
                    child: _Inputs(jugadoresController: jugadoresController),
                  )),
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        form.markAllAsTouched();

                        if (form.valid) {
                          final PartidaProvider partidaProvider =
                              context.read<PartidaProvider>();
                          final GoogleAdsProvider googleAdsProvider =
                              context.read<GoogleAdsProvider>();

                          MyLoading.show();
                          final Partida partida = Partida.fromMap(form.value);
                          final response = await partidaProvider.newPartida(
                              partida, context);
                          MyLoading.close();

                          if (!response.hasError!) {
                            final newPartida = response.data;

                            googleAdsProvider.showInterstitialAd(
                                onCloseFunction: () {
                              partidaProvider.changePartidaEnTurno(newPartida);
                              Navigator.pushReplacementNamed(
                                  context, 'partida');
                              formPartidaProvider.resetForm();
                            });
                          } else {
                            Toast.show(
                                type: ToastType.error,
                                context: context,
                                message: "Error registrando partida.");
                          }
                        } else {
                          Toast.show(
                              type: ToastType.warning,
                              context: context,
                              message: "Revisar todos los campos de texto.");
                        }
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text("Crear",
                            style:
                                TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'Poppins')),
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
    final FormPartidaProvider formPartidaProvider =
        context.watch<FormPartidaProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Jugadores',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w100)),
            Container(
              width: 26,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppThemes.colorTercero,
                  borderRadius: BorderRadius.circular(50)),
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
            onTap: () {
              final PremiumProvider premiumProvider =
                  context.read<PremiumProvider>();

              if (!premiumProvider
                  .canAddPlayer(formPartidaProvider.jugadores.length)) {
                Toast.show(
                    type: ToastType.info,
                    context: context,
                    message:
                        "La versión gratis solo permite ${PremiumProvider.freeMaxPlayers} jugadores. ¡Desbloquea PRO para más!");
                return;
              }

              FocusManager.instance.primaryFocus?.unfocus();
              formPartidaProvider.addJugadorToList();

              // Usar post frame para scroll después del rebuild
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (jugadoresController.hasClients) {
                  jugadoresController.animateTo(
                      jugadoresController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic);
                }
              });

              if (formPartidaProvider.jugadores.length == 20) {
                Toast.show(
                    type: ToastType.info,
                    context: context,
                    message: "Máximo de jugadores alcanzados");
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
    final jugadoresLength = context.select<FormPartidaProvider, int>(
        (provider) => provider.jugadores.length);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ListView.separated(
        controller: jugadoresController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        addAutomaticKeepAlives: true,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemCount: jugadoresLength,
        itemBuilder: (_, index) => _JugadorInput(index: index),
      ),
    );
  }
}

class _JugadorInput extends StatefulWidget {
  const _JugadorInput({required this.index});
  final int index;

  @override
  State<_JugadorInput> createState() => _JugadorInputState();
}

class _JugadorInputState extends State<_JugadorInput>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;
  late final FormPartidaProvider _provider;

  @override
  bool get wantKeepAlive => true;

  FormControl<String> get _formControl {
    final array = _provider.form.control('jugadores') as FormArray;
    return (array.controls[widget.index] as FormGroup).control('nombre') as FormControl<String>;
  }

  void _syncToForm() {
    if (mounted && _formControl.value != _controller.text) {
      _formControl.value = _controller.text;
    }
  }

  @override
  void initState() {
    super.initState();
    _provider = context.read<FormPartidaProvider>();
    _controller = TextEditingController(text: _formControl.value ?? '');
    _controller.addListener(_syncToForm);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncToForm);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Row(
      children: [
        SizedBox(
          width: 25,
          child: Text(
            '${widget.index + 1}',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.withValues(alpha: 0.6)),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: "Nombre",
              fillColor: AppThemes.inputColor,
              filled: true,
              labelStyle: TextStyle(color: AppThemes.labelInputColor, fontFamily: 'Poppins'),
              floatingLabelStyle: TextStyle(
                color: AppThemes.colorQuinto,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppThemes.colorQuinto),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (widget.index >= 2)
          CustomIconButtom(
            onTap: () => _provider.removeJugadorToList(widget.index),
            icon: Icons.remove,
            size: IconSize.min,
            iconSize: 25,
            backgroundColor: const Color(0xFFAF4C4C),
            splashColor: const Color(0xFF7A2E2E),
          ),
      ],
    );
  }
}
