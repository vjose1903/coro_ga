import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/l10n/app_localizations.dart';
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
    final bool isEditing = formPartidaPredefinidaProvider.partidaPredefinidaEditar != null;

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
                  mainAxisSize: MainAxisSize.max,
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
                            items: [
                              DropdownMenuItem(value: "Rondas", child: Text(AppLocalizations.of(context)!.rounds)),
                              DropdownMenuItem(value: "Puntuación", child: Text(AppLocalizations.of(context)!.score))
                            ],
                            onChanged: (value) => formPartidaPredefinidaProvider.changeTipo(value),
                          ),
                        ),
                        if (tipoPartida != '' && tipoPartida != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomReactiveInput(
                              formControlName: 'maxPuntuacion',
                              labelText: tipoPartida == "Rondas" ? AppLocalizations.of(context)!.roundCount : AppLocalizations.of(context)!.maxScore,
                              inputType: TextInputType.number,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Cantidad de jugadores
                    _JugadoresCounter(
                      cantidad: formPartidaPredefinidaProvider.form.control("cantidadJugadores").value ?? 2,
                      onRemove: () => formPartidaPredefinidaProvider.changeCantidadJugadores(context: context, tipo: "-"),
                      onAdd: () {
                        PremiumProvider premiumProvider = context.read<PremiumProvider>();

                        if (!premiumProvider.canAddPlayer(formPartidaPredefinidaProvider.cantidadJugadores)) {
                          final l10n = AppLocalizations.of(context)!;
                          Toast.show(
                              type: ToastType.info,
                              context: context,
                              message: AppLocalizations.of(context)!.freeVersionLimitPlayers(PremiumProvider.freeMaxPlayers),
                              actionLabel: AppLocalizations.of(context)!.getPro,
                              onAction: () => Navigator.pushNamed(context, 'premium'));
                          return;
                        }

                        formPartidaPredefinidaProvider.changeCantidadJugadores(context: context, tipo: "+");
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
        Toast.show(type: ToastType.error, context: context, message: AppLocalizations.of(context)!.errorRegisteringGame);
      }
    } else {
      Toast.show(type: ToastType.warning, context: context, message: AppLocalizations.of(context)!.checkAllFields);
    }
  }
}

// Header del formulario con neumorfismo
class _FormHeader extends StatelessWidget {
  final bool isEditing;

  const _FormHeader({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.7),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEditing
                    ? [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)]
                    : [const Color(0xFF81C784), const Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (isEditing ? const Color(0xFF29B6F6) : const Color(0xFF66BB6A)).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: FaIcon(
                isEditing ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.gamepad,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? AppLocalizations.of(context)!.editPredefinedGame : AppLocalizations.of(context)!.newPredefinedGame,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppThemes.colorCuarto,
                  ),
                ),
                Text(
                  isEditing ? AppLocalizations.of(context)!.modifyGameData : AppLocalizations.of(context)!.configureYourPredefined,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Contador de jugadores
class _JugadoresCounter extends StatelessWidget {
  final int cantidad;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _JugadoresCounter({
    required this.cantidad,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.7),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
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
              FaIcon(
                FontAwesomeIcons.userGroup,
                size: 14,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.playerCount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
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
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cantidad.toString(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
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
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

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
            child: FaIcon(icon, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Botón de acción
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.isPrimary = false,
    this.isDestructive = false,
    required this.onTap,
  });

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
              FaIcon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
