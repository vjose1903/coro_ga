import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import 'header_section.dart';
import 'widgets.dart';

class FormPartidaPredefinida extends StatelessWidget {
  const FormPartidaPredefinida({super.key});

  @override
  Widget build(BuildContext context) {
    final PartidaPredefinidaProvider formPartidaPredefinidaProvider = context.watch<PartidaPredefinidaProvider>();
    final form = formPartidaPredefinidaProvider.form;
    final dynamic tipoPartida = form.control('tipo').value;
    final bool isEditing = formPartidaPredefinidaProvider.partidaPredefinidaEditar != null;
    final bool sinMaxPuntuacion = formPartidaPredefinidaProvider.sinMaxPuntuacion;

    return Consumer(builder: (BuildContext context, value, Widget? child) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _FormHeader(isEditing: isEditing),
            const SizedBox(height: 20),

            ReactiveForm(
              formGroup: form,
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    CustomReactiveInput(
                      formControlName: 'nombre',
                      labelText: AppLocalizations.of(context)!.gameName,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),

                    // Tipo y puntuación máxima
                    Row(
                      children: [
                        Expanded(
                          child: CustomReactiveDropDown(
                            formControlName: 'tipo',
                            labelText: AppLocalizations.of(context)!.type,
                            items: [DropdownMenuItem(value: 'Rondas', child: TextScale(AppLocalizations.of(context)!.rounds)), DropdownMenuItem(value: 'Puntuación', child: TextScale(AppLocalizations.of(context)!.score))],
                            onChanged: (value) => formPartidaPredefinidaProvider.changeTipo(value),
                          ),
                        ),
                        if (tipoPartida != null && tipoPartida != '' && !sinMaxPuntuacion) const SizedBox(width: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          width: tipoPartida == '' || tipoPartida == null || sinMaxPuntuacion ? 0 : ResponsiveApp.size.width * 0.43,
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: ResponsiveApp.size.width * 0.43,
                                child: CustomReactiveInput(formControlName: 'maxPuntuacion', labelText: tipoPartida == 'Rondas' ? AppLocalizations.of(context)!.roundCount : AppLocalizations.of(context)!.maxScore, inputType: TextInputType.number),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (tipoPartida != '' && tipoPartida != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          splashColor: AppThemes.colorPrimero.withValues(alpha: 0.12),
                          highlightColor: AppThemes.colorPrimero.withValues(alpha: 0.06),
                          onTap: () => formPartidaPredefinidaProvider.setSinMaxPuntuacion(!sinMaxPuntuacion),
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
                                  color: Preferences.isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
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
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: ResponsiveApp.scaleText(12),
                                      color: Preferences.isDarkMode ? Colors.white70 : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: sinMaxPuntuacion,
                                  activeThumbColor: AppThemes.colorPrimero,
                                  activeTrackColor: AppThemes.colorPrimero.withValues(alpha: 0.35),
                                  inactiveThumbColor: Preferences.isDarkMode ? Colors.white70 : Colors.grey[600],
                                  inactiveTrackColor: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3),
                                  onChanged: (value) => formPartidaPredefinidaProvider.setSinMaxPuntuacion(value),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Cantidad de jugadores
                    _JugadoresCounter(
                      cantidad: formPartidaPredefinidaProvider.form.control('cantidadJugadores').value ?? 2,
                      onRemove: () => formPartidaPredefinidaProvider.changeCantidadJugadores(context: context, tipo: '-'),
                      onAdd: () {
                        final PremiumProvider premiumProvider = context.read<PremiumProvider>();

                        if (!premiumProvider.canAddPlayer(formPartidaPredefinidaProvider.cantidadJugadores)) {
                          Toast.show(type: ToastType.info, context: context, message: AppLocalizations.of(context)!.freeVersionLimitPlayers(PremiumProvider.freeMaxPlayers), actionLabel: AppLocalizations.of(context)!.getPro, onAction: () => Navigator.pushNamed(context, 'premium'));
                          return;
                        }

                        formPartidaPredefinidaProvider.changeCantidadJugadores(context: context, tipo: '+');
                      },
                    ),
                    const SizedBox(height: 30),

                    // Botones de acción
                    Row(
                      children: [
                        // Volver
                        Expanded(
                          child: _ActionButton(
                            label: AppLocalizations.of(context)!.back,
                            icon: FontAwesomeIcons.arrowLeft,
                            isDestructive: true,
                            onTap: () {
                              context.read<PartidaPredefinidaProvider>().resetForm();
                              DialogNavigator.of(context).pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Crear/Guardar
                        Expanded(
                          child: _ActionButton(
                            label: isEditing ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.create,
                            icon: isEditing ? FontAwesomeIcons.floppyDisk : FontAwesomeIcons.plus,
                            isPrimary: true,
                            onTap: () => crearEditarPartida(context: context, form: form),
                          ),
                        ),
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
        response = await partidaPredefinidaProvider.editPartida(context, partida: formPartidaPredefinidaProvider.partidaPredefinidaEditar!, partidaEdit: form.value);
      } else {
        final PartidaPredefinida partida = PartidaPredefinida.fromMap(form.value);
        response = await partidaPredefinidaProvider.newPartida(partida: partida);
      }

      if (!response.hasError!) {
        // IMPORTANTE: Cerrar diálogo PRIMERO, mostrar anuncio DESPUÉS (pausa natural)
        DialogNavigator.of(context).pop();
        formPartidaPredefinidaProvider.resetForm();

        // Mostrar anuncio después de un delay para dar pausa natural
        Future.delayed(const Duration(milliseconds: 600), () {
          googleAdsProvider.showInterstitialAd(onCloseFunction: () {
            googleAdsProvider.loadInterstitialAd();
          });
        });
      } else {
        Toast.show(type: ToastType.error, context: context, message: AppLocalizations.of(context)!.errorRegisteringGame);
      }
    } else {
      Toast.show(type: ToastType.warning, context: context, message: AppLocalizations.of(context)!.checkAllFields);
    }
  }
}

// Header del formulario con neumorfismo
class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.isEditing});
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return HeaderSection(
      panelController: null,
      icon: isEditing ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.gamepad,
      iconBackgroundColor: isEditing ? const Color(0xFF29B6F6) : const Color(0xFF66BB6A),
      title: isEditing ? AppLocalizations.of(context)!.editPredefinedGame : AppLocalizations.of(context)!.newPredefinedGame,
      subtitle: isEditing ? AppLocalizations.of(context)!.modifyGameData : AppLocalizations.of(context)!.configureYourPredefined,
      useLandscapeLayout: ResponsiveLayoutBuilder.maybeOf(context)?.useLandscapeLayout ?? ResponsiveLayoutBuilder.resolveUseLandscapeLayout(context),
      isWide: ResponsiveLayoutBuilder.maybeOf(context)?.isWide ?? ResponsiveLayoutBuilder.resolveIsWide(context),
    );
  }
}

// Contador de jugadores
class _JugadoresCounter extends StatelessWidget {
  const _JugadoresCounter({
    required this.cantidad,
    required this.onRemove,
    required this.onAdd,
  });
  final int cantidad;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconScale(
                FontAwesomeIcons.userGroup,
                size: 14,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              const SizedBox(width: 8),
              TextScale(
                AppLocalizations.of(context)!.playerCount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: ResponsiveApp.scaleText(13),
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Botón restar
              _CounterButton(
                icon: FontAwesomeIcons.minus,
                color: const Color(0xFFEF5350),
                onTap: onRemove,
              ),
              const SizedBox(width: 10),
              // Valor
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppThemes.inputColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextScale(
                      cantidad.toString(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ResponsiveApp.scaleText(22),
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppThemes.colorCuarto,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Botón sumar
              _CounterButton(
                icon: FontAwesomeIcons.plus,
                color: const Color(0xFF66BB6A),
                onTap: onAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Botón del contador
class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: IconScale(icon, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Botón de acción
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.isPrimary = false,
    this.isDestructive = false,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = isPrimary
        ? [const Color(0xFF66BB6A), const Color(0xFF43A047)]
        : isDestructive
            ? [const Color(0xFFEF5350), const Color(0xFFE53935)]
            : [const Color(0xFF42A5F5), const Color(0xFF1E88E5)];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconScale(icon, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              TextScale(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveApp.scaleText(14),
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
