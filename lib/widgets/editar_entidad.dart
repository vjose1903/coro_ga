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
import 'slide_up_header.dart';
import 'widgets.dart';

class EditarEntidad extends StatelessWidget {
  const EditarEntidad({Key? key, this.pageController, this.panelController, this.onClose}) : super(key: key);

  final PageController? pageController;
  final PanelController? panelController;
  final VoidCallback? onClose;
  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();

    Jugador? jugador = jugadorProvider.jugadorEditar;
    Partida? partida = partidaProvider.partidaEditar;

    final bool isPartida = partida != null;
    late String tipo;
    dynamic entidad;
    IconData icon;

    final l10n = AppLocalizations.of(context)!;
    if (isPartida) {
      tipo = l10n.editGame.split(' ').last;
      entidad = partida;
      icon = FontAwesomeIcons.gamepad;
    } else {
      tipo = l10n.editPlayer.split(' ').last;
      entidad = jugador;
      icon = FontAwesomeIcons.user;
    }

    FormGroup form = isPartida ? formPartidaProvider.form : jugadorProvider.formJugador;

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // Header con avatar e información
          _EditHeader(
            tipo: tipo,
            nombre: entidad?.nombre ?? "",
            icon: icon,
            noNameLabel: AppLocalizations.of(context)!.noName,
            panelController: panelController,
            partida: partida,
            onRestart: partida != null && !partida.isSinIniciar
                ? () async {
                    await partida.restartPartida();
                    partidaProvider.refresh();
                    if (panelController != null) slideUpProvider.closeSlideUp(controller: panelController!);
                  }
                : null,
          ),
          const SizedBox(height: 16),

          // Formulario
          if (isPartida)
            EditPartida(key: const ValueKey('edit_partida'), form: form)
          else
            EditJugador(key: const ValueKey('edit_jugador'), form: form),
          const SizedBox(height: 16),

          // Botones de acción
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
                      slideUpProvider.closeSlideUp(controller: panelController!);
                    }
                    resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
                    await Future.delayed(const Duration(milliseconds: 200));
                    jugadorProvider.formJugador.reset();
                    formPartidaProvider.form.reset();
                  },
                ),
              ),
              const SizedBox(width: 12),
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Anuncio separado de los botones de acción
          GoogleBannerAd(location: AdLocation.editarEntidad)
        ],
      ),
    );
  }

  previusPage(pageController) async {
    pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }

  resetEntidadesEditar({required JugadorProvider jugadorProvider, required PartidaProvider partidaProvider}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    jugadorProvider.jugadorEditar = null;
    partidaProvider.partidaEditar = null;
  }
}

class EditJugador extends StatefulWidget {
  const EditJugador({Key? key, required this.form}) : super(key: key);

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
    return Expanded(
        child: ReactiveForm(
      formGroup: widget.form,
      child: Column(children: <Widget>[
        CustomReactiveInput(
            key: const ValueKey('edit_jugador_nombre'),
            formControlName: 'nombre',
            labelText: AppLocalizations.of(context)!.name,
            textCapitalization: TextCapitalization.words,
            focusNode: _focusNode)
      ]),
    ));
  }
}

class EditPartida extends StatefulWidget {
  const EditPartida({Key? key, required this.form}) : super(key: key);

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
        final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
        final dynamic tipoPartida = formPartidaProvider.form.control('tipo').value;

        return Expanded(
            child: ReactiveForm(
          formGroup: widget.form,
          child: Column(children: <Widget>[
            CustomReactiveInput(
                key: const ValueKey('edit_partida_nombre'),
                formControlName: 'nombre',
                labelText: AppLocalizations.of(context)!.name,
                textCapitalization: TextCapitalization.words,
                focusNode: _focusNode),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  // height: 45,
                  width: tipoPartida == '' ? ResponsiveApp.size.width - 21 : ResponsiveApp.size.width * 0.46,
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
                    width: tipoPartida == '' ? 0.01 : ResponsiveApp.size.width * 0.46,
                    child: CustomReactiveInput(
                        formControlName: 'maxPuntuacion',
                        labelText: tipoPartida == "Rondas" ? AppLocalizations.of(context)!.roundCount : AppLocalizations.of(context)!.maxScoreFull,
                        inputType: TextInputType.number)),
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
      partidaProvider.editPartida(context, partida: entidad, newNombrePartida: form.value["nombre"].toString()).then((value) async {
        entidad.nombre = form.value["nombre"].toString();
        partidaProvider.refresh();
        form.reset();
        resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);

        if (panelController != null) slideUpProvider.closeSlideUp(controller: panelController);
      });
    } else {
      Toast.show(type: ToastType.error, context: context, message: AppLocalizations.of(context)!.gameNameCannotBeEmpty);
    }
  } else {
    if (form.valid) {
      FocusManager.instance.primaryFocus?.unfocus();
      jugadorProvider.editJugador(context, jugador: entidad, newNombreJugador: form.value["nombre"].toString()).then((value) {
        entidad.nombre = form.value["nombre"].toString();
        partidaProvider.refresh();

        form.reset();
        if (onClose != null) {
          onClose();
        } else {
          previusPage(pageController);
        }
        resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
      });
    } else {
      Toast.show(type: ToastType.error, context: context, message: AppLocalizations.of(context)!.playerNameCannotBeEmpty);
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
    required this.noNameLabel,
    this.panelController,
    this.partida,
    this.onRestart,
  });

  final String tipo;
  final String nombre;
  final IconData icon;
  final String noNameLabel;
  final PanelController? panelController;
  final Partida? partida;
  final Future<void> Function()? onRestart;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    final content = Row(
      children: [
        // Avatar con icono
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemes.colorPrimero,
                AppThemes.colorPrimero.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppThemes.colorPrimero.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Información
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${l10n.edit} $tipo",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                nombre.isNotEmpty ? nombre : l10n.noName,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppThemes.colorQuinto,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Botón reiniciar (solo si es partida y ya inició)
        if (onRestart != null)
          Material(
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
                      "label": l10n.cancel,
                      "onTap": () => Navigator.pop(context),
                    }),
                    CustomActionsButtons.aceptarButton({
                      "label": l10n.accept,
                      "onTap": () async {
                        Navigator.pop(context);
                        await onRestart!();
                      },
                    }),
                  ],
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(10),
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
                    const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      l10n.restart,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    if (panelController != null) return SlideUpHeader(panelController: panelController!, child: content);
    return _HeaderContainer(child: content);
  }
}

/// Container base para headers sin panelController (mantiene el mismo estilo)
class _HeaderContainer extends StatelessWidget {
  const _HeaderContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)]
              : [AppThemes.colorPrimero.withValues(alpha: 0.08), AppThemes.colorPrimero.withValues(alpha: 0.03)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppThemes.colorPrimero.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
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
      gradientColors = isDark ? [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.1)] : [Colors.grey[200]!, Colors.grey[300]!];
      textColor = isDark ? Colors.white : AppThemes.colorQuinto;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(12),
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
              FaIcon(
                icon,
                color: textColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
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
