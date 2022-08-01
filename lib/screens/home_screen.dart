import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:we_slide/we_slide.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    partidaProvider.getPartidas(context, isLoading: true);
    return const MainHome();
  }
}

class MainHome extends StatelessWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WeSlideController weSlideController = WeSlideController();
    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final WeSlideProvider weSlideProvider = context.watch<WeSlideProvider>();

        return Scaffold(
          body: Layout(
            appBarTitle: 'Mis Partidas',
            appBarTrailing: CustomIconButtom(
              iconSize: 25,
              iconColor: Colors.white,
              icon: Icons.menu,
              onTap: () => print('algo'),
            ),
            bodyContent: _Body(weSlideController: weSlideController),
            weSlideController: weSlideController,
          ),
          floatingActionButton: Visibility(
            visible: !weSlideController.isOpened,
            child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, 'formulario', arguments: {"tipo": "crear"}), child: const Icon(Icons.add, size: 30)),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.weSlideController}) : super(key: key);
  final WeSlideController weSlideController;

  @override
  Widget build(BuildContext context) {
    // final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    return ListPartidas(weSlideController: weSlideController);
    // return FutureBuilder(
    //   future: partidaProvider.getPartidas(context, isLoading: true),
    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
    //     if (!snapshot.hasData) {
    //       return const Center(
    //         child: CircularProgressIndicator(color: AppThemes.colorSegundo),
    //       );
    //     } else {
    //       return ListPartidas(weSlideController: weSlideController);
    //     }
    //   },
    // );
  }

  getPartida(PartidaProvider partidaProvider, context) async {
    final partida = await partidaProvider.getPartidaById(5, context);

    if (partida == null) {
      Fun.toast(type: ToasType.error, context: context, message: "Partida buscada no existe");
    } else {}
  }
}

class ListPartidas extends StatelessWidget {
  const ListPartidas({Key? key, required this.weSlideController}) : super(key: key);
  final WeSlideController weSlideController;
  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();

    final List<Partida> partidas = partidaProvider.partidas;

    if (partidas.isEmpty) {
      if (partidaProvider.firstSearch) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.gamepad, size: 50, color: Colors.grey.withOpacity(0.7)),
            Text('No hay partidas iniciadas', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.grey[500]))
          ],
        ));
      } else {
        return const Center(
          child: CircularProgressIndicator(color: AppThemes.colorSegundo),
        );
      }
    } else {
      return ListView.separated(
          itemCount: partidas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 30),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_, index) {
            return BounceInLeft(
              delay: Duration(milliseconds: 100 * index),
              child: PartidaCard(
                partida: partidas[index],
                onTap: () => partidaProvider.navigateToPartida(context: context, partida: partidas[index]),

                functionBorrar: (handler) async {
                  CustomAlertDialog.show(context,
                      menssage: "Seguro que desea eliminar la partida: ${partidas[index].nombre}",
                      title: "Confirmar",
                      dialogType: DialogType.error,
                      buttonsList: [
                        CustomActionsButtons.cancelButton({"onTap": () => Navigator.pop(context)}),
                        CustomActionsButtons.aceptarButton({"onTap": () => removePartida(context, handler, partidas, index)})
                      ]);
                },
                // functionEditar: () async => partidaProvider.newPartida(partidas[index], context),
                functionEditar: () {
                  partidaProvider.partidaEditar = partidas[index];
                  weSlideProvider.openWeSlide(controller: weSlideController, body: EditarEntidad(weSlideController: weSlideController));
                },

                index: index,
              ),
            );
          });
    }
  }

  // removePartida(CompletionHandler handler, Partida partida) async {
  Future removePartida(BuildContext context, CompletionHandler handler, List<Partida> partidas, int index) async {
    Navigator.pop(context);
    final partidaProvider = context.read<PartidaProvider>();
    final responseFuture = partidaProvider.deletePartida(context, partida: partidas[index], handler: handler);

    return responseFuture;
  }
}
