import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("----- HomeScreen -----");

    return Scaffold(
      body: Layout(
        appBarTitle: 'Mis Partidas',
        appBarTrailing: CustomIconButtom(
          iconSize: 25,
          iconColor: Colors.white,
          icon: Icons.menu,
          onTap: () => print('algo'),
        ),
        bodyContent: const _Body(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, 'formulario', arguments: {"tipo": "crear"}), child: const Icon(Icons.add, size: 30)),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  // getPartidas
  // List<Partida> tempPartidas = [
  //   Partida(id: 1, activo: true, nombre: "Domino", jugadores: [
  //     Jugador(nombre: "Victor", puntuacion: 20),
  //     Jugador(nombre: "Juan", puntuacion: 20),
  //   ]),
  //   Partida(id: 2, activo: true, nombre: "Uno", jugadores: [
  //     Jugador(id: 1, nombre: "Victor", puntuacion: 1),
  //     Jugador(id: 1, nombre: "Manuel", puntuacion: 6),
  //     Jugador(id: 4, nombre: "Alex", puntuacion: 2),
  //     Jugador(id: 5, nombre: "Ropert", puntuacion: 3),
  //   ]),
  //   Partida(id: 2, activo: true, nombre: "Coño no voy", jugadores: [
  //     Jugador(id: 1, nombre: "Victor", puntuacion: 5),
  //     Jugador(id: 2, nombre: "Jean Marcos", puntuacion: 2),
  //     Jugador(id: 3, nombre: "Saul", puntuacion: 4),
  //     Jugador(id: 4, nombre: "Alex", puntuacion: 2),
  //     Jugador(id: 5, nombre: "Ropert", puntuacion: 3),
  //   ]),
  // ];
  @override
  Widget build(BuildContext context) {
    final PartidasProvider partidaProvider = context.read<PartidasProvider>();
    print(">>>>> HomeScreen _Body <<<<<");
    print(" ");

    return FutureBuilder(
      future: partidaProvider.getPartidas(context, isLoading: false),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppThemes.colorPrimero),
          );
        } else {
          return const ListPartidas();
        }
      },
    );
  }

  getPartida(PartidasProvider partidaProvider, context) async {
    final partida = await partidaProvider.getPartidaById(5, context);

    if (partida == null) {
      Fun.toast(type: ToasType.error, context: context, message: "Partida buscada no existe");
    } else {}
  }
}

class ListPartidas extends StatelessWidget {
  const ListPartidas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final partidaProvider = context.watch<PartidasProvider>();
    final List<Partida> partidas = partidaProvider.partidas;

    if (partidas.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.gamepad, size: 50, color: Colors.grey.withOpacity(0.7)),
          Text('No hay partidas iniciadas', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.grey[500]))
        ],
      ));
    } else {
      return ListView.separated(
          separatorBuilder: (_, __) => const SizedBox(height: 30),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: partidas.length,
          itemBuilder: (_, index) {
            return PartidaCard(
              partida: partidas[index],
              onTap: () => partidaProvider.navigateToPartida(context: context, partida: partidas[index]),
              functionBorrar: () async => partidas.remove(partidas[index]),
              functionEditar: () async => partidaProvider.newPartida(partidas[index], context),
              index: index,
            );
          });
    }
  }
}
