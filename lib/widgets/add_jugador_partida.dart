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

class AddJugadorPartida extends StatelessWidget {
  const AddJugadorPartida({required this.panelController, super.key});

  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return AddJugador(panelController: panelController);
  }
}

class AddJugador extends StatefulWidget {
  const AddJugador({required this.panelController, super.key});

  final PanelController panelController;

  @override
  State<AddJugador> createState() => _AddJugadorState();
}

class _AddJugadorState extends State<AddJugador> {
  final ScrollController jugadoresController = ScrollController();

  void rebuildWidget() {
    Fun.logColor(color: Colores.magenta, body: 'mounted: $mounted');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final isDark = Preferences.isDarkMode;
    final FormGroup form = jugadorProvider.formJugador;

    final int cantJugadores = partidaProvider.partidaEnTurno?.jugadores?.length ?? 0;

    return ResponsiveLayoutBuilder(
      useMediaQuery: true,
      builder: (context, constraints, info) {
        final useLandscapeLayout = info.useLandscapeLayout;
        final isWide = info.isWide;

        return SafeArea(
          top: false,
          bottom: false,
          left: useLandscapeLayout,
          right: useLandscapeLayout,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: (ResponsiveApp.size.height - (ResponsiveApp.size.height * 0.22)),
              child: Column(
                children: [
                  // Header
                  _AddJugadorHeader(cantJugadores: cantJugadores, panelController: widget.panelController),
                  const SizedBox(height: 16),

                  // Sección jugadores actuales
                  _SectionTitle(title: AppLocalizations.of(context)!.addPlayer, icon: FontAwesomeIcons.plus),
                  const SizedBox(height: 10),

                  // Input Nombre + Botón agregar
                  ReactiveForm(
                    formGroup: form,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomReactiveInput(
                            formControlName: 'nombre',
                            labelText: AppLocalizations.of(context)!.playerName,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _AddIconButton(useLandscapeLayout: useLandscapeLayout, isWide: isWide, onTap: () => _agregarJugador(context, form)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sección jugadores actuales
                  _SectionTitle(
                    title: AppLocalizations.of(context)!.currentPlayers,
                    icon: FontAwesomeIcons.users,
                    count: cantJugadores,
                  ),
                  const SizedBox(height: 8),

                  // Lista de jugadores
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppThemes.themeColor_1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: JugadoresActuales(
                          jugadoresController: jugadoresController,
                          rebuildWidget: rebuildWidget,
                          useLandscapeLayout: useLandscapeLayout,
                          isWide: isWide,
                          onEditJugador: (jugador) => _showEditarJugadorModal(context, jugador, useLandscapeLayout),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditarJugadorModal(BuildContext context, Jugador jugador, bool useLandscapeLayout) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final jugadorProvider = context.read<JugadorProvider>();
    final slideUpProvider = context.read<SlideUpProvider>();

    jugadorProvider.jugadorEditar = jugador;
    jugadorProvider.formJugador.patchValue(jugador.toMap());

    // Cerrar el slideUp cuando se abre el modal (sin limpiar jugadorEditar)
    slideUpProvider.closeSlideUp(controller: widget.panelController, skipClean: true);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppThemes.themeColor_2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: useLandscapeLayout ? screenWidth * 0.6 : double.infinity,
          height: screenHeight * 0.5,
          padding: const EdgeInsets.all(16),
          child: EditarEntidad(
            panelController: widget.panelController,
            onClose: () => Navigator.pop(dialogContext),
          ),
        ),
      ),
    ).then((_) {
      // Esperar al siguiente frame para asegurar que los datos estén sincronizados
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        slideUpProvider.openSlideUp(
          controller: widget.panelController,
          bodyContent: AddJugadorPartida(panelController: widget.panelController),
        );
      });
    });
  }

  void _agregarJugador(BuildContext context, FormGroup form) async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final PremiumProvider premiumProvider = context.read<PremiumProvider>();
    final partida = partidaProvider.partidaEnTurno;
    if (partida == null || partida.jugadores == null) return;

    if (!premiumProvider.canAddPlayer(partida.jugadores!.length)) {
      Toast.show(type: ToastType.info, context: context, message: AppLocalizations.of(context)!.freeVersionLimitPlayers(PremiumProvider.freeMaxPlayers), actionLabel: AppLocalizations.of(context)!.getPro, onAction: () => Navigator.pushNamed(context, 'premium'));
      return;
    }

    if (form.valid) {
      final Jugador nuevoJugador = Jugador.fromMap(form.value);

      await partidaProvider.addJugadorToPartida(
        context,
        jugador: nuevoJugador,
        partida: partida,
      );
      form.reset();
      rebuildWidget();

      await Future.delayed(const Duration(milliseconds: 50));

      await jugadoresController.animateTo(
        jugadoresController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOutCubic,
      );
    } else {
      Toast.show(type: ToastType.error, context: context, message: AppLocalizations.of(context)!.enterNewPlayerName);
    }
  }
}

// ============================================
// WIDGETS PRIVADOS
// ============================================

class _AddJugadorHeader extends StatelessWidget {
  const _AddJugadorHeader({required this.cantJugadores, required this.panelController});

  final int cantJugadores;
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return HeaderSection(
      panelController: panelController,
      icon: FontAwesomeIcons.userPlus,
      iconBackgroundColor: const Color(0xFF4CAF50),
      title: AppLocalizations.of(context)!.players,
      subtitle: AppLocalizations.of(context)!.playersInGame(cantJugadores),
      useLandscapeLayout: ResponsiveLayoutBuilder.maybeOf(context)?.useLandscapeLayout ?? ResponsiveLayoutBuilder.resolveUseLandscapeLayout(context),
      isWide: ResponsiveLayoutBuilder.maybeOf(context)?.isWide ?? ResponsiveLayoutBuilder.resolveIsWide(context),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    this.count,
  });

  final String title;
  final IconData icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Row(
      children: [
        IconScale(
          icon,
          size: 12,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        TextScale(
          title,
          size: 12,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppThemes.colorPrimero.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextScale(
              '$count',
              size: 10,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AppThemes.colorPrimero,
              ),
            ),
          ),
      ],
    );
  }
}

class _AddIconButton extends StatelessWidget {
  const _AddIconButton({required this.onTap, required this.useLandscapeLayout, required this.isWide});

  final VoidCallback onTap;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: useLandscapeLayout ? (isWide ? 40 : 38) : 52,
          height: useLandscapeLayout ? (isWide ? 40 : 38) : 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF43A047)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: IconScale(
              FontAwesomeIcons.plus,
              color: Colors.white,
              size: isWide ? 19 : 15,
            ),
          ),
        ),
      ),
    );
  }
}
