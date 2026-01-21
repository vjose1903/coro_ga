import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/l10n/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Layout(
        panelController: PanelController(),
        appBarTitle: l10n.createNewGame,
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
    return Consumer(builder: (BuildContext context, value, Widget? child) {
      final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
      final form = formPartidaProvider.form;
      final isDark = Preferences.isDarkMode;

      final dynamic tipoPartida = form.control('tipo').value;

      return Container(
          height: ((ResponsiveApp.size.height - (ResponsiveApp.size.height * 0.125)) - 80),
          margin: ResponsiveApp.only(top: 15, bottom: 40),
          padding: ResponsiveApp.symmetric(horizontal: 20),
          child: ReactiveForm(
            formGroup: form,
            child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Botón plantillas
                  Align(
                    alignment: Alignment.centerRight,
                    child: _PlantillasButton(
                      onTap: () => openDefaultsPartidasDialog(context),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Nombre de la partida
                  CustomReactiveInput(
                      formControlName: 'nombre', labelText: AppLocalizations.of(context)!.gameName, textCapitalization: TextCapitalization.words),
                  const SizedBox(height: 14),

                  // Tipo y puntuación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        width: tipoPartida == '' || tipoPartida == null ? ResponsiveApp.size.width - 42 : ResponsiveApp.size.width * 0.43,
                        child: CustomReactiveDropDown(
                          formControlName: 'tipo',
                          labelText: AppLocalizations.of(context)!.type,
                          items: [
                            DropdownMenuItem(value: "Rondas", child: Text(AppLocalizations.of(context)!.rounds)),
                            DropdownMenuItem(value: "Puntuación", child: Text(AppLocalizations.of(context)!.score))
                          ],
                          onChanged: (value) => formPartidaProvider.changeTipo(value),
                        ),
                      ),
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          width: tipoPartida == '' || tipoPartida == null ? 0.01 : ResponsiveApp.size.width * 0.43,
                          child: CustomReactiveInput(
                              formControlName: 'maxPuntuacion',
                              labelText: tipoPartida == "Rondas" ? AppLocalizations.of(context)!.roundCount : AppLocalizations.of(context)!.maxScore,
                              inputType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sección Jugadores
                  _JugadoresSection(jugadoresController: jugadoresController),
                  const SizedBox(height: 12),

                  // Lista de jugadores
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppThemes.themeColor_2,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.7),
                            offset: const Offset(-2, -2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: _Inputs(jugadoresController: jugadoresController),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón Crear
                  _CreateButton(
                    onTap: () => _crearPartida(context, form, formPartidaProvider),
                  ),
                ],
              ),
            ),
          ));
    });
  }

  void _crearPartida(BuildContext context, FormGroup form, FormPartidaProvider formPartidaProvider) async {
    form.markAllAsTouched();

    if (form.valid) {
      final PartidaProvider partidaProvider = context.read<PartidaProvider>();
      final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();

      MyLoading.show();
      final Partida partida = Partida.fromMap(form.value);
      final response = await partidaProvider.newPartida(partida, context);
      MyLoading.close();

      if (!response.hasError!) {
        final newPartida = response.data;

        // IMPORTANTE: Navegar PRIMERO, mostrar anuncio DESPUÉS (evita bloquear resultado)
        partidaProvider.changePartidaEnTurno(newPartida);
        formPartidaProvider.resetForm();
        googleAdsProvider.markAdForAfterNavigation();
        Navigator.pushReplacementNamed(context, 'partida');
      } else {
        Toast.show(type: ToastType.error, context: context, message: AppLocalizations.of(context)!.errorRegisteringGame);
      }
    } else {
      Toast.show(type: ToastType.warning, context: context, message: AppLocalizations.of(context)!.checkAllFields);
    }
  }
}

// Botón de plantillas
class _PlantillasButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PlantillasButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
              padding: ResponsiveApp.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppThemes.colorPrimero,
                AppThemes.colorTercero,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppThemes.colorTercero.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.layerGroup,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.predefined,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sección de jugadores con header
class _JugadoresSection extends StatelessWidget {
  final ScrollController jugadoresController;

  const _JugadoresSection({required this.jugadoresController});

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
    final isDark = Preferences.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.colorPrimero, AppThemes.colorPrimero.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.users,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.players,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppThemes.colorCuarto,
              ),
            ),
            Container(
            margin: ResponsiveApp.only(left: 10),
            padding: ResponsiveApp.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppThemes.colorTercero.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formPartidaProvider.jugadores.length.toString(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (formPartidaProvider.jugadores.length < 20)
          _AddPlayerButton(
            onTap: () => _addJugador(context, formPartidaProvider),
          ),
      ],
    );
  }

  void _addJugador(BuildContext context, FormPartidaProvider formPartidaProvider) {
    final PremiumProvider premiumProvider = context.read<PremiumProvider>();

    if (!premiumProvider.canAddPlayer(formPartidaProvider.jugadores.length)) {
      final l10n = AppLocalizations.of(context)!;
      Toast.show(
          type: ToastType.info,
          context: context,
          message: l10n.freeVersionLimitPlayers(PremiumProvider.freeMaxPlayers),
          actionLabel: l10n.getPro,
          onAction: () => Navigator.pushNamed(context, 'premium'));
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    formPartidaProvider.addJugadorToList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (jugadoresController.hasClients) {
        jugadoresController.animateTo(jugadoresController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800), curve: Curves.easeOutCubic);
      }
    });

    if (formPartidaProvider.jugadores.length == 20) {
      final l10n = AppLocalizations.of(context)!;
      Toast.show(type: ToastType.info, context: context, message: l10n.maxPlayersReached);
    }
  }
}

// Botón agregar jugador
class _AddPlayerButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPlayerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF43A047).withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(FontAwesomeIcons.plus, size: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Botón crear partida
class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: ResponsiveApp.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF43A047).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.plus, size: 16, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.createGame,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Inputs extends StatelessWidget {
  const _Inputs({Key? key, required this.jugadoresController}) : super(key: key);
  final ScrollController jugadoresController;

  @override
  Widget build(BuildContext context) {
    final jugadoresLength = context.select<FormPartidaProvider, int>((provider) => provider.jugadores.length);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return ListView.separated(
      controller: jugadoresController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12 + keyboardHeight),
      addAutomaticKeepAlives: true,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: jugadoresLength,
      itemBuilder: (_, index) => _JugadorInput(index: index, scrollController: jugadoresController),
    );
  }
}

class _JugadorInput extends StatefulWidget {
  const _JugadorInput({required this.index, required this.scrollController});
  final int index;
  final ScrollController scrollController;

  @override
  State<_JugadorInput> createState() => _JugadorInputState();
}

class _JugadorInputState extends State<_JugadorInput> with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;
  late final FormPartidaProvider _provider;
  late final FocusNode _focusNode;
  final GlobalKey _inputKey = GlobalKey();

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

  void _onFocusChange() {
    if (_focusNode.hasFocus && _inputKey.currentContext != null) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && _inputKey.currentContext != null && widget.scrollController.hasClients) {
          final RenderBox? renderBox = _inputKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final screenHeight = MediaQuery.of(context).size.height;
            final itemBottom = position.dy + renderBox.size.height;
            final visibleBottom = screenHeight - keyboardHeight;

            if (itemBottom > visibleBottom - 50) {
              final scrollOffset = widget.scrollController.offset + (itemBottom - visibleBottom) + 80;
              widget.scrollController.animateTo(
                scrollOffset.clamp(0, widget.scrollController.position.maxScrollExtent),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _provider = context.read<FormPartidaProvider>();
    _controller = TextEditingController(text: _formControl.value ?? '');
    _controller.addListener(_syncToForm);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncToForm);
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Preferences.isDarkMode;

    return Row(
      children: [
        // Número del jugador
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppThemes.colorPrimero.withValues(alpha: 0.8),
                AppThemes.colorPrimero.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${widget.index + 1}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Input
        Expanded(
          key: _inputKey,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: isDark ? Colors.white : AppThemes.colorCuarto,
            ),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.name,
              fillColor: AppThemes.inputColor,
              filled: true,
              labelStyle: TextStyle(
                color: AppThemes.labelInputColor,
                fontFamily: 'Poppins',
              ),
              floatingLabelStyle: TextStyle(
                color: AppThemes.colorQuinto,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        // Botón eliminar
        if (widget.index >= 2) ...[
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _provider.removeJugadorToList(widget.index),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: FaIcon(FontAwesomeIcons.minus, size: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
