import 'package:flutter/material.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/models/models.dart';
import 'package:provider/provider.dart';

class FormularioScreen extends StatelessWidget {
  const FormularioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map;
    final tipo = routeArgs['tipo'];
    final id = routeArgs['id'];
    final size = MediaQuery.of(context).size;

    final formPartidaProvider = Provider.of<FormPartidaProvider>(context, listen: false);
    formPartidaProvider.getPartida(id);

    final Map<String, dynamic> pantallas = {
      "crear": {"title": "Crear nueva partida"}
    };

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Layout(
        appBarTitle: pantallas[tipo]["title"],
        appBarLeading: CustomIconButtom(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),
        bodyContent: _Body(id: id, size: size),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  _Body({Key? key, required this.size, this.id}) : super(key: key);

  final int? id;
  final Size size;
  bool isLoad = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final formPartidaProvider = Provider.of<FormPartidaProvider>(context);

    if (formPartidaProvider.partida == null) {
      return SizedBox(
        width: double.infinity,
        height: size.height,
        child: const Center(child: CircularProgressIndicator(color: AppThemes.colorPrimero)),
      );
    } else {
      return const SingleChildScrollView(child: Formulario());
    }
  }
}

class Formulario extends StatelessWidget {
  const Formulario({Key? key, this.id}) : super(key: key);

  final int? id;

  @override
  Widget build(BuildContext context) {
    final formPartidaProvider = Provider.of<FormPartidaProvider>(context);
    formPartidaProvider.partidaMap = formPartidaProvider.partida!.toMap();

    print('BUILD FORMULARIO');
    final Size size = MediaQuery.of(context).size;
    final GlobalKey<FormState> myFormKey = GlobalKey<FormState>();

    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: myFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CustomInputField(formProperty: 'nombre', formValues: formPartidaProvider.partidaMap, labelText: 'Nombre'),
            TextFormField(
              autofocus: false,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              obscureText: false,
              decoration: const InputDecoration(
                hintText: null,
                labelText: 'nombre',
                helperText: null,
                suffixIcon: Icon(Icons.abc_outlined),
              ),
            ),

            // const SizedBox(height: 30),
            // const Titulo(),
            // const SizedBox(height: 10),
            // SizedBox(
            //   height: size.height * 0.4,
            //   child: Material(
            //       color: AppThemes.Cards[AppThemes.currentTheme],
            //       borderRadius: BorderRadius.circular(12),
            //       shadowColor: AppThemes.colorTercero.withOpacity(0.3),
            //       elevation: 7,
            //       child: _Inputs(size: size)),
            // ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Crear', style: TextStyle(fontSize: 20, fontFamily: 'Poppins')),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Titulo extends StatelessWidget {
  const Titulo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formPartidaProvider = Provider.of<FormPartidaProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Jugadores', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w100)),
        CustomIconButtom(
          onTap: () => formPartidaProvider.addJugadorToList(Jugador()),
          icon: Icons.add,
          size: IconSize.min,
          iconSize: 25,
          backgroundColor: const Color(0xFF4CAF50),
          splashColor: const Color(0xFF2E7A31),
        )
      ],
    );
  }
}

class _Inputs extends StatelessWidget {
  const _Inputs({Key? key, required this.size}) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    final formPartidaProvider = Provider.of<FormPartidaProvider>(context);
    List<Jugador> jugadores = formPartidaProvider.partida!.jugadores!;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemCount: jugadores.length,
      itemBuilder: (BuildContext context, int index) {
        return _JugadorInput(jugador: jugadores[index], size: size, index: index);
      },
    );
  }
}

class _JugadorInput extends StatelessWidget {
  const _JugadorInput({Key? key, required this.jugador, required this.size, required this.index}) : super(key: key);

  final Jugador jugador;
  final Size size;
  final int index;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> jugadorMap = jugador.toMap();
    final formPartidaProvider = Provider.of<FormPartidaProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size.width - 120),
          child: CustomInputField(formProperty: 'nombre', formValues: jugadorMap, labelText: 'Nombre'),
        ),
        if (index >= 2)
          CustomIconButtom(
              onTap: () => formPartidaProvider.removeJugadorToList(jugador),
              icon: Icons.remove,
              size: IconSize.min,
              iconSize: 25,
              backgroundColor: const Color(0xFFAF4C4C),
              splashColor: const Color(0xFF7A2E2E)),
      ],
    );
  }
}
