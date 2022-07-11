import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Layout(
      appBarTitle: 'Mis Partidas',
      appBarTrailing: CustomIconButtom(
        icon: Icons.menu,
        function: () => print('algo'),
      ),
      bodyContent: const _Body(),
    ));
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (false) {
      return Expanded(
          child: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.gamepad,
            size: 50,
            color: Colors.grey.withOpacity(0.7),
          ),
          Text(
            'No hay partidas iniciadas',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.grey[500]),
          )
        ],
      )));
    } else {
      return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: 1,
          itemBuilder: (_, index) {
            return const ListPartidas();
          });
    }
  }
}
