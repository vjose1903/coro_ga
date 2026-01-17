import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class EditarEntidad extends StatelessWidget {
  const EditarEntidad({Key? key, this.pageController, this.panelController}) : super(key: key);

  final PageController? pageController;
  final PanelController? panelController;
  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();

    Jugador? jugador = jugadorProvider.jugadorEditar;
    Partida? partida = partidaProvider.partidaEditar;

    late String tipo;
    dynamic entidad;
    IconData icon;

    if (partida != null) {
      tipo = "Partida";
      entidad = partida;
      icon = FontAwesomeIcons.gamepad;
    } else {
      tipo = "Jugador";
      entidad = jugador;
      icon = FontAwesomeIcons.user;
    }

    FormGroup form = tipo == "Partida" ? formPartidaProvider.form : jugadorProvider.formJugador;

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
          ),
          const SizedBox(height: 16),
          
          // Formulario
          if (tipo == "Partida") EditPartida(form: form) else EditJugador(form: form),
          const SizedBox(height: 16),
          
          // Botones de acción
          Row(
            children: [
              // CANCELAR
              Expanded(
                child: _ActionButton(
                  label: "Cancelar",
                  icon: FontAwesomeIcons.xmark,
                  isDestructive: true,
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (panelController != null) slideUpProvider.closeSlideUp(controller: panelController!);
                    if (pageController != null) previusPage(pageController);
                    resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
                    await Future.delayed(const Duration(milliseconds: 200));
                    form.reset();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // ACEPTAR
              Expanded(
                child: _ActionButton(
                  label: "Guardar",
                  icon: FontAwesomeIcons.check,
                  isPrimary: true,
                  onTap: () {
                    aceptarFunction(context, entidad,
                        form: form,
                        jugadorProvider: jugadorProvider,
                        partidaProvider: partidaProvider,
                        previusPage: previusPage,
                        resetEntidadesEditar: resetEntidadesEditar,
                        tipo: tipo,
                        pageController: pageController,
                        panelController: panelController);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ANUNCIOS
          GoogleBannerAd(location: AdLocation.editarEntidad)
        ],
      ),
    );
  }

  previusPage(pageController) async {
    pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }

  resetEntidadesEditar({required JugadorProvider jugadorProvider, required PartidaProvider partidaProvider}) async {
    await Future.delayed(const Duration(seconds: 1));
    jugadorProvider.jugadorEditar = null;
    partidaProvider.partidaEditar = null;
  }
}

class EditJugador extends StatelessWidget {
  const EditJugador({Key? key, required this.form}) : super(key: key);

  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ReactiveForm(
      formGroup: form,
      child: Column(children: const <Widget>[
        CustomReactiveInput(formControlName: 'nombre', labelText: "nombre", textCapitalization: TextCapitalization.words)
      ]),
    ));
  }
}

class EditPartida extends StatelessWidget {
  const EditPartida({Key? key, required this.form}) : super(key: key);

  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
        final dynamic tipoPartida = formPartidaProvider.form.control('tipo').value;

        return Expanded(
            child: ReactiveForm(
          formGroup: form,
          child: Column(children: <Widget>[
            const CustomReactiveInput(formControlName: 'nombre', labelText: "nombre", textCapitalization: TextCapitalization.words),
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
                    width: tipoPartida == '' ? 0.01 : ResponsiveApp.size.width * 0.46,
                    child: CustomReactiveInput(
                        formControlName: 'maxPuntuacion',
                        labelText: tipoPartida == "Rondas" ? "Cant. rondas" : "Puntuación Máxima",
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
    required String tipo,
    required JugadorProvider jugadorProvider,
    required PartidaProvider partidaProvider,
    required Function previusPage,
    required Function resetEntidadesEditar,
    PanelController? panelController,
    PageController? pageController}) {
  if (tipo == "Partida") {
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
      Toast.show(type: ToastType.error, context: context, message: "El nombre de la partida no puede estar vacio.");
    }
  } else {
    if (form.valid) {
      FocusManager.instance.primaryFocus?.unfocus();
      jugadorProvider.editJugador(context, jugador: entidad, newNombreJugador: form.value["nombre"].toString()).then((value) {
        entidad.nombre = form.value["nombre"].toString();
        partidaProvider.refresh();

        form.reset();
        previusPage(pageController);
        resetEntidadesEditar(jugadorProvider: jugadorProvider, partidaProvider: partidaProvider);
      });
    } else {
      Toast.show(type: ToastType.error, context: context, message: "El nombre del jugador no puede estar vacio.");
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
  });

  final String tipo;
  final String nombre;
  final IconData icon;

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
      child: Row(
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
                  "Editar $tipo",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  nombre.isNotEmpty ? nombre : "Sin nombre",
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
        ],
      ),
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
      gradientColors = isDark
          ? [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.1)]
          : [Colors.grey[200]!, Colors.grey[300]!];
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
                color: (isPrimary ? Colors.green : isDestructive ? Colors.red : Colors.black)
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
