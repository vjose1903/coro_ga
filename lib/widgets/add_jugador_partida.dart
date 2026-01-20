import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/l10n/app_localizations.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/widgets/slide_up_header.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class AddJugadorPartida extends StatelessWidget {
  const AddJugadorPartida({Key? key, required this.panelController}) : super(key: key);

  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    GoogleBannerAd anuncio = GoogleBannerAd(location: AdLocation.agregarJugador);
    return AddJugador(anuncio: anuncio, panelController: panelController);
  }
}

class AddJugador extends StatefulWidget {
  const AddJugador({Key? key, required this.anuncio, required this.panelController}) : super(key: key);

  final GoogleBannerAd anuncio;
  final PanelController panelController;

  @override
  State<AddJugador> createState() => _AddJugadorState();
}

class _AddJugadorState extends State<AddJugador> {
  final ScrollController jugadoresController = ScrollController();

  rebuildWidget() {
    Fun.logColor(color: Colores.magenta, body: "mounted: $mounted");
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final isDark = Preferences.isDarkMode;
    FormGroup form = jugadorProvider.formJugador;

    final int cantJugadores = partidaProvider.partidaEnTurno?.jugadores?.length ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: (ResponsiveApp.size.height - (ResponsiveApp.size.height * 0.22)),
        child: Column(
          children: [
            // Header
            _AddJugadorHeader(cantJugadores: cantJugadores, panelController: widget.panelController),
            const SizedBox(height: 16),

            // Input Nombre + Botón agregar
            ReactiveForm(
              formGroup: form,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomReactiveInput(
                      formControlName: 'nombre',
                      labelText: AppLocalizations.of(context)!.playerName,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AddIconButton(onTap: () => _agregarJugador(context, form)),
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
              child: Container(
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
                    onEditJugador: (jugador) => _showEditarJugadorModal(context, jugador),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Anuncios (separado de la lista de jugadores)
            widget.anuncio
          ],
        ),
      ),
    );
  }

  void _showEditarJugadorModal(BuildContext context, Jugador jugador) {
    final screenHeight = MediaQuery.of(context).size.height;
    final jugadorProvider = context.read<JugadorProvider>();
    final slideUpProvider = context.read<SlideUpProvider>();

    jugadorProvider.jugadorEditar = jugador;
    jugadorProvider.formJugador.patchValue(jugador.toMap());

    // Cerrar el slideUp cuando se abre el modal (sin limpiar jugadorEditar)
    slideUpProvider.closeSlideUp(controller: widget.panelController, skipClean: true);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppThemes.themeColor_2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          height: screenHeight * 0.5,
          padding: const EdgeInsets.all(16),
          child: EditarEntidad(
            onClose: () => Navigator.pop(dialogContext),
          ),
        ),
      ),
    ).then((_) {
      // Esperar al siguiente frame para asegurar que los datos estén sincronizados
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

    if (!premiumProvider.canAddPlayer(partidaProvider.partidaEnTurno!.jugadores!.length)) {
      Toast.show(
          type: ToastType.info,
          context: context,
          message: AppLocalizations.of(context)!.freeVersionLimitPlayers(PremiumProvider.freeMaxPlayers),
          actionLabel: AppLocalizations.of(context)!.getPro,
          onAction: () => Navigator.pushNamed(context, 'premium'));
      return;
    }

    if (form.valid) {
      Jugador nuevoJugador = Jugador.fromMap(form.value);

      partidaProvider.addJugadorToPartida(context, jugador: nuevoJugador, partida: partidaProvider.partidaEnTurno!).then((value) async {
        form.reset();
        rebuildWidget();

        await Future.delayed(const Duration(milliseconds: 50));

        jugadoresController.animateTo(jugadoresController.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.easeOutCubic);
      });
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
    final isDark = Preferences.isDarkMode;

    return SlideUpHeader(
      panelController: panelController,
      child: Row(
        children: [
          // Icono
          Container(
            width: 42,
            height: 42,
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
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.userPlus,
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
                  AppLocalizations.of(context)!.players,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppThemes.colorQuinto,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  AppLocalizations.of(context)!.playersInGame(cantJugadores),
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.count,
  });

  final String title;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Row(
      children: [
        FaIcon(
          icon,
          size: 12,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppThemes.colorPrimero.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$count",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 10,
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
  const _AddIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
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
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.plus,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
