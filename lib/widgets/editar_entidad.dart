import 'package:flutter/material.dart';
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
import 'header_section.dart';
import 'widgets.dart';

class EditarEntidad extends StatelessWidget {
  const EditarEntidad(
      {super.key, this.pageController, this.panelController, this.onClose});

  final PageController? pageController;
  final PanelController? panelController;
  final VoidCallback? onClose;
  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final FormPartidaProvider formPartidaProvider =
        context.watch<FormPartidaProvider>();
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();

    final Jugador? jugador = jugadorProvider.jugadorEditar;
    final Partida? partida = partidaProvider.partidaEditar;

    final bool isPartida = partida != null;
    late String tipo;
    dynamic entidad;
    IconData icon;
    Offset offset;

    final l10n = AppLocalizations.of(context)!;
    if (isPartida) {
      tipo = l10n.editGame.split(' ').last;
      entidad = partida;
      icon = FontAwesomeIcons.gamepad;
      offset = const Offset(-1.5, 0);
    } else {
      tipo = l10n.editPlayer.split(' ').last;
      entidad = jugador;
      icon = FontAwesomeIcons.user;
      offset = const Offset(0, 0);
    }

    final FormGroup form =
        isPartida ? formPartidaProvider.form : jugadorProvider.formJugador;

    return ResponsiveLayoutBuilder(builder: (context, constraints, info) {
      final useLandscapeLayout = info.useLandscapeLayout;
      final isWide = info.isWide;

      return SafeArea(
        top: false,
        bottom: false,
        left: useLandscapeLayout,
        right: useLandscapeLayout,
        child: LayoutBuilder(builder: (context, viewportConstraints) {
          final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: Padding(
              padding: ResponsiveApp.only(bottom: 10),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        children: [
                          // Header con avatar e información
                          _EditHeader(
                            tipo: tipo,
                            nombre: entidad?.nombre ?? '',
                            icon: icon,
                            offset: offset,
                            noNameLabel: AppLocalizations.of(context)!.noName,
                            useLandscapeLayout: useLandscapeLayout,
                            isWide: isWide,
                            panelController: panelController,
                            partida: partida,
                            onRestart: partida != null && !partida.isSinIniciar
                                ? () async {
                                    await partida.restartPartida();
                                    partidaProvider.refresh();
                                    if (panelController != null) {
                                      slideUpProvider.closeSlideUp(
                                          controller: panelController!);
                                    }
                                  }
                                : null,
                          ),
                          SizedBox(height: ResponsiveApp.scaleHeight(16)),

                          // Formulario
                          if (isPartida)
                            EditPartida(
                                key: const ValueKey('edit_partida'), form: form)
                          else
                            EditJugador(
                                key: const ValueKey('edit_jugador'),
                                form: form),
                          SizedBox(height: ResponsiveApp.scaleHeight(16)),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // CANCELAR
                      Expanded(
                        child: _ActionButton(
                            label: l10n.cancel,
                            icon: FontAwesomeIcons.xmark,
                            isDestructive: true,
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (onClose != null) {
                                onClose!();
                              } else if (pageController != null) {
                                previusPage(pageController);
                              } else if (panelController != null) {
                                slideUpProvider.closeSlideUp(
                                    controller: panelController!);
                              }
                              resetEntidadesEditar(
                                  jugadorProvider: jugadorProvider,
                                  partidaProvider: partidaProvider);
                              await Future.delayed(
                                  const Duration(milliseconds: 200));
                              jugadorProvider.formJugador.reset();
                              formPartidaProvider.form.reset();
                            },
                            useLandscapeLayout: useLandscapeLayout),
                      ),
                      SizedBox(width: ResponsiveApp.scaleWidth(12)),
                      // ACEPTAR
                      Expanded(
                        child: _ActionButton(
                            label: l10n.save,
                            icon: FontAwesomeIcons.check,
                            isPrimary: true,
                            onTap: () {
                              aceptarFunction(context, entidad,
                                  form: form,
                                  jugadorProvider: jugadorProvider,
                                  partidaProvider: partidaProvider,
                                  previusPage: previusPage,
                                  resetEntidadesEditar: resetEntidadesEditar,
                                  isPartida: isPartida,
                                  pageController: pageController,
                                  panelController: panelController,
                                  onClose: onClose);
                            },
                            useLandscapeLayout: useLandscapeLayout),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  previusPage(pageController) async {
    pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart);
  }

  resetEntidadesEditar(
      {required JugadorProvider jugadorProvider,
      required PartidaProvider partidaProvider}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    jugadorProvider.jugadorEditar = null;
    partidaProvider.partidaEditar = null;
  }
}

class EditJugador extends StatefulWidget {
  const EditJugador({super.key, required this.form});

  final FormGroup form;

  @override
  State<EditJugador> createState() => _EditJugadorState();
}

class _EditJugadorState extends State<EditJugador> {
  late final FocusNode _focusNode;
  bool _focusRequested = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _requestFocusOnce();
  }

  void _requestFocusOnce() {
    if (_focusRequested) return;
    _focusRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && !_focusNode.hasFocus) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: widget.form,
      child: Column(children: <Widget>[
        CustomReactiveInput(
            key: const ValueKey('edit_jugador_nombre'),
            formControlName: 'nombre',
            labelText: AppLocalizations.of(context)!.name,
            textCapitalization: TextCapitalization.words,
            focusNode: _focusNode)
      ]),
    );
  }
}

class EditPartida extends StatefulWidget {
  const EditPartida({super.key, required this.form});

  final FormGroup form;

  @override
  State<EditPartida> createState() => _EditPartidaState();
}

class _EditPartidaState extends State<EditPartida> {
  late final FocusNode _focusNode;
  bool _focusRequested = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _requestFocusOnce();
  }

  void _requestFocusOnce() {
    if (_focusRequested) return;
    _focusRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && !_focusNode.hasFocus) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final FormPartidaProvider formPartidaProvider =
            context.watch<FormPartidaProvider>();
        final dynamic tipoPartida =
            formPartidaProvider.form.control('tipo').value;

        return ReactiveForm(
          formGroup: widget.form,
          child: Column(children: <Widget>[
            CustomReactiveInput(
                key: const ValueKey('edit_partida_nombre'),
                formControlName: 'nombre',
                labelText: AppLocalizations.of(context)!.name,
                textCapitalization: TextCapitalization.words,
                focusNode: _focusNode),
            SizedBox(height: ResponsiveApp.scaleHeight(10)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              child: (tipoPartida == null || tipoPartida == '')
                  ? CustomReactiveDropDown(
                      key: const ValueKey('tipo_solo'),
                      formControlName: 'tipo',
                      labelText: AppLocalizations.of(context)!.type,
                      items: [
                        DropdownMenuItem(
                            value: 'Rondas',
                            child: TextScale(
                                AppLocalizations.of(context)!.rounds)),
                        DropdownMenuItem(
                            value: 'Puntuación',
                            child:
                                TextScale(AppLocalizations.of(context)!.score))
                      ],
                      onChanged: (value) =>
                          formPartidaProvider.changeTipo(value),
                    )
                  : Row(
                      key: const ValueKey('tipo_y_max'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomReactiveDropDown(
                            formControlName: 'tipo',
                            labelText: AppLocalizations.of(context)!.type,
                            items: [
                              DropdownMenuItem(
                                  value: 'Rondas',
                                  child: TextScale(
                                      AppLocalizations.of(context)!.rounds)),
                              DropdownMenuItem(
                                  value: 'Puntuación',
                                  child: TextScale(
                                      AppLocalizations.of(context)!.score))
                            ],
                            onChanged: (value) =>
                                formPartidaProvider.changeTipo(value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomReactiveInput(
                              formControlName: 'maxPuntuacion',
                              labelText: tipoPartida == 'Rondas'
                                  ? AppLocalizations.of(context)!.roundCount
                                  : AppLocalizations.of(context)!.maxScoreFull,
                              inputType: TextInputType.number),
                        ),
                      ],
                    ),
            ),
          ]),
        );
      },
    );
  }
}

aceptarFunction(BuildContext context, dynamic entidad,
    {required FormGroup form,
    required bool isPartida,
    required JugadorProvider jugadorProvider,
    required PartidaProvider partidaProvider,
    required Function previusPage,
    required Function resetEntidadesEditar,
    PanelController? panelController,
    PageController? pageController,
    VoidCallback? onClose}) {
  if (isPartida) {
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
    if (form.valid) {
      FocusManager.instance.primaryFocus?.unfocus();
      partidaProvider
          .editPartida(context,
              partida: entidad,
              newNombrePartida: form.value['nombre'].toString())
          .then((value) async {
        entidad.nombre = form.value['nombre'].toString();
        partidaProvider.refresh();
        form.reset();
        resetEntidadesEditar(
            jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);

        if (panelController != null)
          slideUpProvider.closeSlideUp(controller: panelController);
      });
    } else {
      Toast.show(
          type: ToastType.error,
          context: context,
          message: AppLocalizations.of(context)!.gameNameCannotBeEmpty);
    }
  } else {
    if (form.valid) {
      FocusManager.instance.primaryFocus?.unfocus();
      jugadorProvider
          .editJugador(context,
              jugador: entidad,
              newNombreJugador: form.value['nombre'].toString())
          .then((value) {
        entidad.nombre = form.value['nombre'].toString();
        partidaProvider.refresh();

        form.reset();
        if (onClose != null) {
          onClose();
        } else {
          previusPage(pageController);
        }
        resetEntidadesEditar(
            jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
      });
    } else {
      Toast.show(
          type: ToastType.error,
          context: context,
          message: AppLocalizations.of(context)!.playerNameCannotBeEmpty);
    }
  }
}

// ============================================
// WIDGETS PRIVADOS
// ============================================

class _EditHeader extends StatelessWidget {
  const _EditHeader({
    required this.tipo,
    required this.nombre,
    required this.icon,
    required this.offset,
    required this.noNameLabel,
    required this.useLandscapeLayout,
    required this.isWide,
    this.panelController,
    this.partida,
    this.onRestart,
  });

  final String tipo;
  final String nombre;
  final IconData icon;
  final Offset offset;
  final String noNameLabel;
  final bool useLandscapeLayout;
  final bool isWide;
  final PanelController? panelController;
  final Partida? partida;
  final Future<void> Function()? onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HeaderSection(
      panelController: panelController,
      icon: icon,
      iconOffset: offset,
      iconBackgroundColor: AppThemes.colorPrimero,
      title: '${l10n.edit} $tipo',
      subtitle: nombre.isNotEmpty ? nombre : noNameLabel,
      useLandscapeLayout: useLandscapeLayout,
      isWide: isWide,
      rightWidget: onRestart == null
          ? null
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  CustomAlertDialog.show(
                    context,
                    title: l10n.confirm,
                    menssage: l10n.confirmRestartGame(partida!.nombre!),
                    dialogType: DialogType.warning,
                    buttonsList: [
                      CustomActionsButtons.cancelButton({
                        'label': l10n.cancel,
                        'onTap': () => Navigator.pop(context),
                      }),
                      CustomActionsButtons.aceptarButton({
                        'label': l10n.accept,
                        'onTap': () async {
                          Navigator.pop(context);
                          await onRestart!();
                        },
                      }),
                    ],
                  );
                },
                borderRadius: useLandscapeLayout
                    ? ResponsiveApp.borderRadius(6)
                    : ResponsiveApp.borderRadius(10),
                child: Container(
                  padding: ResponsiveApp.symmetric(
                      horizontal: useLandscapeLayout ? 6 : 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                    ),
                    borderRadius: useLandscapeLayout
                        ? ResponsiveApp.borderRadius(6)
                        : ResponsiveApp.borderRadius(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFA000).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconScale(Icons.restart_alt_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: ResponsiveApp.scaleWidth(4)),
                      TextScale(
                        l10n.restart,
                        size: 12,
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
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.useLandscapeLayout,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool useLandscapeLayout;
  final bool isPrimary;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    Color textColor;
    List<Color> gradientColors;

    if (isPrimary) {
      gradientColors = [
        const Color(0xFF4CAF50),
        const Color(0xFF43A047),
      ];
      textColor = Colors.white;
    } else if (isDestructive) {
      gradientColors = [
        const Color(0xFFEF5350),
        const Color(0xFFE53935),
      ];
      textColor = Colors.white;
    } else {
      gradientColors = isDark
          ? [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.1)
            ]
          : [Colors.grey[200]!, Colors.grey[300]!];
      textColor = isDark ? Colors.white : AppThemes.colorQuinto;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: useLandscapeLayout
            ? ResponsiveApp.borderRadius(5)
            : ResponsiveApp.borderRadius(12),
        child: Container(
          padding: ResponsiveApp.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            borderRadius: useLandscapeLayout
                ? ResponsiveApp.borderRadius(5)
                : ResponsiveApp.borderRadius(12),
            boxShadow: [
              BoxShadow(
                color: (isPrimary
                        ? Colors.green
                        : isDestructive
                            ? Colors.red
                            : Colors.black)
                    .withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconScale(
                icon,
                color: textColor,
                size: 16,
              ),
              SizedBox(width: ResponsiveApp.scaleWidth(8)),
              TextScale(
                label,
                size: 16,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
