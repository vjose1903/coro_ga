import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../helpers/helpers.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/banner_prefetch_service.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../widgets/widgets.dart';

class PartidaScreen extends StatefulWidget {
  const PartidaScreen({Key? key}) : super(key: key);

  @override
  State<PartidaScreen> createState() => _PartidaScreenState();
}

class _PartidaScreenState extends State<PartidaScreen> with SingleTickerProviderStateMixin {
  late final PanelController panelController;
  late final AnimationController _fabAnimController;
  late final GoogleBannerAd anuncio;

  @override
  void initState() {
    super.initState();
    panelController = PanelController();
    anuncio = GoogleBannerAd(location: AdLocation.partida);
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () => _fabAnimController.forward());
      _showPendingAdIfNeeded();
    });
  }

  /// Muestra el anuncio intersticial si estaba pendiente (después de navegación)
  void _showPendingAdIfNeeded() {
    final googleAdsProvider = context.read<GoogleAdsProvider>();
    if (googleAdsProvider.showAdAfterNavigation) {
      googleAdsProvider.clearAdAfterNavigation();
      // Esperar a que la pantalla esté completamente cargada antes de mostrar
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          googleAdsProvider.showInterstitialAd(onCloseFunction: () {
            googleAdsProvider.loadInterstitialAd();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTracker(
      screenName: 'PartidaScreen',
      child: Consumer(
        builder: (BuildContext context, value, Widget? child) {
          context.watch<SlideUpProvider>();

          return Scaffold(
            body: _Body(panelController: panelController, anuncio: anuncio),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            floatingActionButton: Visibility(
              visible: !panelController.isAttached || panelController.isPanelClosed,
              child: ScaleTransition(
                scale: CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemes.colorTercero.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: const CircleBorder(),
                    onPressed: () => Navigator.pushReplacementNamed(context, 'formulario'),
                    child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomBar(panelController: panelController, child: const NavigationBar()),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.panelController, required this.anuncio}) : super(key: key);

  final PanelController panelController;
  final GoogleBannerAd anuncio;
  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
    Partida partida = partidaProvider.partidaEnTurno!;
    final bool compactHeight = ResponsiveApp.isSmallHeight;
    final double topMargin = compactHeight ? 24 : 40;
    final double bottomMargin = compactHeight ? 60 : 90;
    final double horizontalPadding = ResponsiveApp.scaleWidth(20);
    final double contentSpacing = ResponsiveApp.scaleHeight(20);
    final double betweenCardGap = compactHeight ? ResponsiveApp.scaleHeight(22) : ResponsiveApp.scaleHeight(25);
    final double adSpacing = ResponsiveApp.scaleHeight(15);

    return Layout(
        panelController: panelController,
        hasFooter: true,
        appBarTitle: partida.nombre,
        appBarLeading: CustomIconButtom(
          iconSize: ResponsiveApp.isSmallHeight ? 18 : 22,
          iconColor: Colors.white,
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),
        appBarTrailing: CustomIconButtom(
          iconSize: ResponsiveApp.isSmallHeight ? 18 : 22,
          iconColor: Colors.white,
          icon: Icons.edit_outlined,
          onTap: () {
            formPartidaProvider.form.patchValue(partida.toMap());
            partidaProvider.partidaEditar = partida;
            context.read<BannerPrefetchService>().ensurePrefetched(AdLocation.editarEntidad);
            slideUpProvider.openSlideUp(
              controller: panelController,
              maxHeightFraction: 0.5,
              bodyContent: EditarEntidad(panelController: panelController),
            );
          },
        ),
        bodyContent: Container(
            margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(children: [
              const CustomEstadoPartida(),
              SizedBox(height: contentSpacing),
              JugadoresCard(panelController: panelController),
              SizedBox(height: betweenCardGap),
              // Anuncio separado de la lista de jugadores
              anuncio,
              SizedBox(height: adSpacing),
            ])));
  }
}

class JugadoresCard extends StatelessWidget {
  const JugadoresCard({Key? key, required this.panelController}) : super(key: key);
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    openSlideUp() {
      final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
      final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
      context.read<BannerPrefetchService>().ensurePrefetched(AdLocation.agregarJugador);
      jugadorProvider.formJugador.reset();
      slideUpProvider.openSlideUp(controller: panelController, bodyContent: AddJugadorPartida(panelController: panelController));
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppThemes.themeColor_2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppThemes.colorCuarto.withValues(alpha: Preferences.isDarkMode ? 0.2 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header con botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(
                    icon: Icons.history_rounded,
                    onTap: () {
                      final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
                      context.read<BannerPrefetchService>().ensurePrefetched(AdLocation.puntuacion);
                      slideUpProvider.openSlideUp(controller: panelController, bodyContent: HistorialGeneral(panelController: panelController));
                    },
                  ),
                  _ActionButton(
                    icon: Icons.manage_accounts_rounded,
                    isPrimary: true,
                    onTap: openSlideUp,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Lista de jugadores
              Expanded(child: JugadoresList(panelController: panelController)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                  )
                : null,
            color: isPrimary ? null : (Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isPrimary ? Colors.white : (Preferences.isDarkMode ? Colors.white70 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

class JugadoresList extends StatelessWidget {
  const JugadoresList({Key? key, required this.panelController}) : super(key: key);
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final partida = partidaProvider.partidaEnTurno!;
    final jugadores = List<Jugador>.from(partida.jugadores ?? []);

    jugadores.sort((a, b) => a.id!.compareTo(b.id!));

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalSpacing = 10.0;
        const columns = 2;
        final availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width;
        final columnWidth = (availableWidth - horizontalSpacing * (columns - 1)) / columns;

        return SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              alignment: WrapAlignment.start,
              runSpacing: 10,
              spacing: horizontalSpacing,
              children: jugadores.asMap().entries.map((entry) {
                final index = entry.key;
                final jugador = entry.value;
                final jugadorCard = JugadorInfo(
                  jugador: jugador,
                  panelController: panelController,
                  forcedWidth: columnWidth,
                );

                return SizedBox(
                  width: columnWidth,
                  child: partidaProvider.isChangePartida
                      ? ElasticIn(
                          key: ValueKey('${partida.id}_${jugador.id}'),
                          delay: Duration(milliseconds: 100 * index), // Reducido de 100ms a 50ms
                          child: jugadorCard)
                      : jugadorCard,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class JugadorInfo extends StatelessWidget {
  const JugadorInfo({Key? key, required this.jugador, required this.panelController, this.forcedWidth}) : super(key: key);
  final Jugador jugador;
  final PanelController panelController;
  final double? forcedWidth;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final estado = partidaProvider.partidaEnTurno!.getJugadorEstatus(jugador);

    // Colores según estado
    final Map<String, Map<String, dynamic>> estadoConfig = {
      Estado.ganador: {
        'icon': Icons.trending_up_rounded,
        'color': Colors.green,
        'bgColor': Colors.green.withValues(alpha: 0.1),
      },
      Estado.perdedor: {
        'icon': Icons.trending_down_rounded,
        'color': Colors.red[400],
        'bgColor': Colors.red.withValues(alpha: 0.1),
      },
      Estado.empate: {
        'icon': Icons.swap_horiz_rounded,
        'color': Colors.amber[700],
        'bgColor': Colors.amber.withValues(alpha: 0.1),
      },
      Estado.not: {
        'icon': Icons.remove_rounded,
        'color': Colors.grey,
        'bgColor': Colors.grey.withValues(alpha: 0.1),
      },
    };

    final config = estadoConfig[estado] ?? estadoConfig[Estado.not]!;

    return _JugadorCard(
      jugador: jugador,
      estado: estado,
      config: config,
      width: forcedWidth,
      onTap: () {
        final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
        final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
        context.read<BannerPrefetchService>().ensurePrefetched(AdLocation.puntuacion);
        jugadorProvider.changeJugadorEnTurno(jugador);
        slideUpProvider.openSlideUp(controller: panelController, bodyContent: PuntuacionForm(panelController: panelController));
      },
    );
  }
}

class _JugadorCard extends StatelessWidget {
  final Jugador jugador;
  final String estado;
  final Map<String, dynamic> config;
  final double? width;
  final VoidCallback onTap;

  const _JugadorCard({
    required this.jugador,
    required this.estado,
    required this.config,
    this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWinner = estado == Estado.ganador;
    final bool isLoser = estado == Estado.perdedor;
    final bool compactWidth = ResponsiveApp.isSmallWidth;
    final double cardHeight = ResponsiveApp.scaleHeight(130);
    final double defaultCardWidth = ResponsiveApp.size.width * (compactWidth ? 0.48 : 0.4);
    final double cardWidth = width ?? defaultCardWidth;
    final double contentPadding = ResponsiveApp.scaleWidth(12);
    final double nameFontSize = ResponsiveApp.scaleText(14);
    final double scoreFontSize = ResponsiveApp.scaleText(42);
    final double iconSize = ResponsiveApp.scaleWidth(14);
    final double iconPadding = ResponsiveApp.scaleWidth(4);

    return Container(
      height: cardHeight,
      width: cardWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Preferences.isDarkMode ? [const Color(0xFF2A2D3E), const Color(0xFF1F2130)] : [const Color(0xFFE8ECFF), const Color(0xFFD4DBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner
              ? Colors.green.withValues(alpha: 0.4)
              : isLoser
                  ? Colors.red.withValues(alpha: 0.3)
                  : (Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.1) : AppThemes.colorPrimero.withValues(alpha: 0.2)),
          width: isWinner || isLoser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isWinner
                ? Colors.green.withValues(alpha: 0.2)
                : isLoser
                    ? Colors.red.withValues(alpha: 0.15)
                    : AppThemes.colorCuarto.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Text(
                  jugador.nombre!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w600,
                    color: Preferences.isDarkMode ? AppThemes.colorPrimero : AppThemes.colorTercero,
                  ),
                ),
                // Puntuación
                Expanded(
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isWinner
                            ? [Colors.green[400]!, Colors.green[600]!]
                            : isLoser
                                ? [Colors.red[300]!, Colors.red[500]!]
                                : [AppThemes.colorPrimero, AppThemes.colorTercero],
                      ).createShader(bounds),
                      child: Text(
                        jugador.puntuacion.toString(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: scoreFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Icono de estado
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: config['bgColor'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      config['icon'],
                      size: iconSize,
                      color: config['color'],
                    ),
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

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;
  late List<int> visibleIndeces = [];

  @override
  void initState() {
    super.initState();

    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();

    SchedulerBinding.instance.addPostFrameCallback((_) => scrollToGame(context));

    itemPositionsListener.itemPositions.addListener(() {
      visibleIndeces = itemPositionsListener.itemPositions.value.map((item) => item.index).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void scrollToGame(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    final int selectedIndex = partidaProvider.partidas.indexWhere((partida) => partida.id == partidaProvider.partidaEnTurno!.id);

    // Usar post frame callback en lugar de delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (partidaProvider.partidas.length > 3 &&
          visibleIndeces.isNotEmpty &&
          ((selectedIndex <= visibleIndeces.first) || (selectedIndex >= visibleIndeces.last))) {
        itemScrollController.scrollTo(
            index: selectedIndex, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic, alignment: 0.4);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    List<Partida> partidas = partidaProvider.partidas;

    if (partidas.isNotEmpty) {
      return ScrollablePositionedList.separated(
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: partidas.length,
          padding: const EdgeInsets.only(left: 20, right: 150),
          itemBuilder: (context, index) => _Chip(partida: partidas[index], scrollToGame: scrollToGame));
    } else {
      return Container();
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({Key? key, required this.partida, required this.scrollToGame}) : super(key: key);
  final Partida? partida;
  final Function scrollToGame;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final bool isSelected = partida!.id == partidaProvider.partidaEnTurno!.id;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                )
              : null,
          color: isSelected ? null : (Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? null
              : Border.all(
                  color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppThemes.colorTercero.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              if (!isSelected) {
                partidaProvider.changePartidaEnTurno(partida!);
                scrollToGame(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                partida!.nombre!,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: isSelected ? Colors.white : (Preferences.isDarkMode ? Colors.white70 : Colors.grey[700]),
                  fontSize: ResponsiveApp.scaleText(14),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
