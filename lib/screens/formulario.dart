import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  @override
  initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (Preferences.isFirstTimeOpen) {
        unawaited(context.read<PartidaPredefinidaProvider>().seed());
      }

      openDefaultsPartidasDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();

    googleAdsProvider.loadInterstitialAd();

    final l10n = AppLocalizations.of(context)!;
    return ScreenTracker(
      screenName: 'FormularioScreen',
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Layout(
          panelController: PanelController(),
          appBarTitle: l10n.createNewGame,
          appBarLeading: CustomIconButtom(
            iconSize: ResponsiveApp.isSmallHeight ? 16 : 20,
            iconColor: Colors.white,
            icon: Icons.arrow_back_ios_new,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context, 'home');
            },
          ),
          bodyContent: _Body(),
        ),
      ),
    );
  }
}

void openDefaultsPartidasDialog(BuildContext context) {
  final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.read<PartidaPredefinidaProvider>();
  formPartidaPredefinidaProvider.resetForm();

  FluidAlerts.show(
    context,
    rootPage: OrientationBuilder(
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
        return SizedBox(
          width: size.width - 40,
          height: size.height - (isLandscape ? 50 : 150),
          child: const PartidasDefaultAlert(),
        );
      },
    ),
  );
}

class _Body extends StatelessWidget {
  _Body();

  final ScrollController jugadoresController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, value, Widget? child) {
      final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
      final form = formPartidaProvider.form;
      final isDark = Preferences.isDarkMode;
      final bool sinMaxPuntuacion = formPartidaProvider.sinMaxPuntuacion;

      final dynamic tipoPartida = form.control('tipo').value;

      return ResponsiveLayoutBuilder(
        builder: (context, constraints, info) {
          final bool useLandscapeLayout = info.useLandscapeLayout;
          final bool isWide = info.isWide;
          final EdgeInsets contentPadding = ResponsiveApp.symmetric(horizontal: useLandscapeLayout ? 16 : 20);

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: contentPadding.left,
                right: contentPadding.right,
                top: useLandscapeLayout ? 10 : 15,
                bottom: useLandscapeLayout ? 20 : 40,
              ),
              child: ReactiveForm(
                key: ValueKey(form),
                formGroup: form,
                child: useLandscapeLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _FormDetailsColumn(
                              tipoPartida: tipoPartida,
                              sinMaxPuntuacion: sinMaxPuntuacion,
                              isDark: isDark,
                              formPartidaProvider: formPartidaProvider,
                              onOpenDefaults: () => openDefaultsPartidasDialog(context),
                              onCreate: () => _crearPartida(context, form, formPartidaProvider),
                              useLandscapeLayout: useLandscapeLayout,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _FormPlayersColumn(isDark: isDark, jugadoresController: jugadoresController, onCreate: () => _crearPartida(context, form, formPartidaProvider), useLandscapeLayout: useLandscapeLayout, isWide: isWide),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FormDetailsColumn(
                            tipoPartida: tipoPartida,
                            sinMaxPuntuacion: sinMaxPuntuacion,
                            isDark: isDark,
                            formPartidaProvider: formPartidaProvider,
                            onOpenDefaults: () => openDefaultsPartidasDialog(context),
                            onCreate: () => _crearPartida(context, form, formPartidaProvider),
                            useLandscapeLayout: useLandscapeLayout,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _FormPlayersColumn(isDark: isDark, jugadoresController: jugadoresController, onCreate: () => _crearPartida(context, form, formPartidaProvider), useLandscapeLayout: useLandscapeLayout, isWide: isWide),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      );
    });
  }

  void _crearPartida(BuildContext context, FormGroup form, FormPartidaProvider formPartidaProvider) async {
    form.markAllAsTouched();

    if (form.valid) {
      final PartidaProvider partidaProvider = context.read<PartidaProvider>();
      final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();

      await MyLoading.show();
      final Partida partida = Partida.fromMap(form.value);
      if (!context.mounted) return;
      final response = await partidaProvider.newPartida(partida, context);
      await MyLoading.close();
      if (!context.mounted) return;

      if (!response.hasError!) {
        final newPartida = response.data;

        // IMPORTANTE: En FREE, mostrar anuncio ANTES de navegar. En premium, navegar directo.
        partidaProvider.changePartidaEnTurno(newPartida);
        formPartidaProvider.resetForm(context: context);
        final navigator = Navigator.of(context);

        void goToPartida() {
          if (!context.mounted) return;
          navigator.pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            navigator.pushNamed('partida');
          });
        }

        if (Preferences.isPremium) {
          goToPartida();
        } else {
          googleAdsProvider.showInterstitialAd(onCloseFunction: () {
            if (!context.mounted) return;
            goToPartida();
            googleAdsProvider.loadInterstitialAd();
          });
        }
      } else {
        Toast.show(type: ToastType.error, context: context, message: AppLocalizations.of(context)!.errorRegisteringGame);
      }
    } else {
      Toast.show(type: ToastType.warning, context: context, message: AppLocalizations.of(context)!.checkAllFields);
    }
  }
}

class _FormDetailsColumn extends StatelessWidget {
  const _FormDetailsColumn({
    required this.tipoPartida,
    required this.sinMaxPuntuacion,
    required this.isDark,
    required this.formPartidaProvider,
    required this.onOpenDefaults,
    required this.onCreate,
    required this.useLandscapeLayout,
  });

  final dynamic tipoPartida;
  final bool sinMaxPuntuacion;
  final bool isDark;
  final FormPartidaProvider formPartidaProvider;
  final VoidCallback onOpenDefaults;
  final VoidCallback onCreate;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botón plantillas
        Align(
          alignment: Alignment.centerRight,
          child: _PlantillasButton(onTap: onOpenDefaults, useLandscapeLayout: useLandscapeLayout),
        ),
        const SizedBox(height: 14),
        // Nombre de la partida
        CustomReactiveInput(
          formControlName: 'nombre',
          labelText: AppLocalizations.of(context)!.gameName,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 14),
        // Tipo y puntuación
        LayoutBuilder(
          builder: (context, constraints) {
            final useLandscapeLayout = ResponsiveApp.isLandscapeFor(constraints) || constraints.maxWidth >= 700;
            final scoreFieldWidth = constraints.maxWidth * (useLandscapeLayout ? 0.45 : 0.43);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomReactiveDropDown(
                    formControlName: 'tipo',
                    labelText: AppLocalizations.of(context)!.type,
                    items: [
                      DropdownMenuItem(value: 'Rondas', child: TextScale(AppLocalizations.of(context)!.rounds)),
                      DropdownMenuItem(value: 'Puntuación', child: TextScale(AppLocalizations.of(context)!.score)),
                    ],
                    onChanged: (value) => formPartidaProvider.changeTipo(value),
                  ),
                ),
                if (tipoPartida != null && tipoPartida != '' && !sinMaxPuntuacion) const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  width: tipoPartida == '' || tipoPartida == null || sinMaxPuntuacion ? 0 : scoreFieldWidth,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: scoreFieldWidth,
                        child: CustomReactiveInput(
                          formControlName: 'maxPuntuacion',
                          labelText: tipoPartida == 'Rondas' ? AppLocalizations.of(context)!.roundCount : AppLocalizations.of(context)!.maxScore,
                          inputType: TextInputType.number,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        if (tipoPartida != null && tipoPartida != '')
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: AppThemes.colorPrimero.withValues(alpha: 0.12),
              highlightColor: AppThemes.colorPrimero.withValues(alpha: 0.06),
              onTap: () => formPartidaProvider.setSinMaxPuntuacion(!sinMaxPuntuacion),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: AppThemes.inputColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextScale(
                        tipoPartida == 'Rondas' ? AppLocalizations.of(context)!.noMaxRounds : AppLocalizations.of(context)!.noMaxScore,
                        size: 12,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 46,
                      height: 28,
                      child: FittedBox(
                        child: Switch(
                          value: sinMaxPuntuacion,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          activeThumbColor: AppThemes.colorPrimero,
                          activeTrackColor: AppThemes.colorPrimero.withValues(alpha: 0.35),
                          inactiveThumbColor: isDark ? Colors.white70 : Colors.grey[600],
                          inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3),
                          onChanged: (value) => formPartidaProvider.setSinMaxPuntuacion(value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (useLandscapeLayout) ...[
          const Spacer(),
          _CreateButton(onTap: onCreate),
        ],
      ],
    );
  }
}

class _FormPlayersColumn extends StatelessWidget {
  const _FormPlayersColumn({
    required this.isDark,
    required this.jugadoresController,
    required this.onCreate,
    required this.useLandscapeLayout,
    required this.isWide,
  });

  final bool isDark;
  final ScrollController jugadoresController;
  final VoidCallback onCreate;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _JugadoresSection(jugadoresController: jugadoresController, useLandscapeLayout: useLandscapeLayout, isWide: isWide),
        SizedBox(height: useLandscapeLayout ? 8 : 12),
        Expanded(
          child: DecoratedBox(
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
        if (!useLandscapeLayout) ...[
          const SizedBox(height: 16),
          _CreateButton(onTap: onCreate),
        ],
      ],
    );
  }
}

// Botón de plantillas
class _PlantillasButton extends StatelessWidget {
  const _PlantillasButton({required this.onTap, required this.useLandscapeLayout});
  final VoidCallback onTap;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: ResponsiveApp.symmetric(horizontal: useLandscapeLayout ? 5 : 12, vertical: 8),
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
              const IconScale(
                FontAwesomeIcons.layerGroup,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              TextScale(
                AppLocalizations.of(context)!.predefined,
                size: 12,
                style: const TextStyle(
                  fontFamily: 'Poppins',
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
  const _JugadoresSection({required this.jugadoresController, required this.useLandscapeLayout, required this.isWide});
  final ScrollController jugadoresController;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
    final isDark = Preferences.isDarkMode;

    final avatarSize = (useLandscapeLayout ? ResponsiveApp.scaleWidth(15) : ResponsiveApp.scaleWidth(30)).clamp(28.0, 52.0);
    final iconSize = (useLandscapeLayout ? ResponsiveApp.scaleWidth(4) : ResponsiveApp.scaleWidth(10)).clamp(5.0, 22.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.colorPrimero, AppThemes.colorPrimero.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Transform.translate(offset: const Offset(-1.0, 0.0), child: IconScale(FontAwesomeIcons.users, color: Colors.white, size: iconSize))),
            ),
            const SizedBox(width: 10),
            TextScale(
              AppLocalizations.of(context)!.players,
              size: 16,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppThemes.colorCuarto,
              ),
            ),
            Container(
              margin: ResponsiveApp.only(left: useLandscapeLayout ? 5 : 10),
              padding: ResponsiveApp.symmetric(horizontal: useLandscapeLayout ? 4 : 10, vertical: useLandscapeLayout ? 6 : 4),
              decoration: BoxDecoration(
                color: AppThemes.colorTercero.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(useLandscapeLayout ? 8 : 12),
              ),
              child: TextScale(
                formPartidaProvider.jugadores.length.toString(),
                size: 13,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (formPartidaProvider.jugadores.length < 20) _AddPlayerButton(useLandscapeLayout: useLandscapeLayout, isWide: isWide, onTap: () => _addJugador(context, formPartidaProvider)),
      ],
    );
  }

  void _addJugador(BuildContext context, FormPartidaProvider formPartidaProvider) {
    final PremiumProvider premiumProvider = context.read<PremiumProvider>();

    if (!premiumProvider.canAddPlayer(formPartidaProvider.jugadores.length)) {
      final l10n = AppLocalizations.of(context)!;
      Toast.show(type: ToastType.info, context: context, message: l10n.freeVersionLimitPlayers(PremiumProvider.freeMaxPlayers), actionLabel: l10n.getPro, onAction: () => Navigator.pushNamed(context, 'premium'));
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    formPartidaProvider.addJugadorToList(context: context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (jugadoresController.hasClients) {
        jugadoresController.animateTo(jugadoresController.position.maxScrollExtent, duration: const Duration(milliseconds: 800), curve: Curves.easeOutCubic);
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
  const _AddPlayerButton({required this.onTap, required this.useLandscapeLayout, required this.isWide});

  final VoidCallback onTap;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(useLandscapeLayout ? 7 : 10),
        child: Container(
          width: useLandscapeLayout ? 30 : 36,
          height: useLandscapeLayout ? 30 : 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(useLandscapeLayout ? 7 : 10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF43A047).withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: IconScale(FontAwesomeIcons.plus, size: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Botón crear partida
class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});
  final VoidCallback onTap;

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
              const IconScale(FontAwesomeIcons.plus, size: 16, color: Colors.white),
              const SizedBox(width: 10),
              TextScale(
                AppLocalizations.of(context)!.createGame,
                size: 16,
                style: const TextStyle(
                  fontFamily: 'Poppins',
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
  const _Inputs({required this.jugadoresController});
  final ScrollController jugadoresController;

  @override
  Widget build(BuildContext context) {
    final formPartidaProvider = context.watch<FormPartidaProvider>();
    final jugadoresLength = formPartidaProvider.jugadores.length;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final listBottomPadding = ResponsiveApp.isSmallHeight ? 10.0 : 20.0;

    return ListView.separated(
      controller: jugadoresController,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: listBottomPadding + keyboardHeight),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: jugadoresLength,
      itemBuilder: (_, index) => _JugadorInput(
        index: index,
        scrollController: jugadoresController,
      ),
    );
  }
}

class _JugadorInput extends StatefulWidget {
  const _JugadorInput({
    required this.index,
    required this.scrollController,
  });

  final int index;
  final ScrollController scrollController;

  @override
  State<_JugadorInput> createState() => _JugadorInputState();
}

class _JugadorInputState extends State<_JugadorInput> {
  late final FormPartidaProvider _provider;
  late final FocusNode _focusNode;
  final GlobalKey _inputKey = GlobalKey();

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
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: TextScale(
              '${widget.index + 1}',
              size: 12,
              style: const TextStyle(
                fontFamily: 'Poppins',
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
          child: CustomReactiveInput(
            formControlName: 'jugadores.${widget.index}.nombre',
            labelText: AppLocalizations.of(context)!.name,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.words,
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
                child: const Center(
                  child: IconScale(FontAwesomeIcons.minus, size: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
