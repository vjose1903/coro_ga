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

    final Map<String, dynamic> pantallas = {
      "crear": {"title": "Crear nueva partida", "btnLabel": "Crear"},
      "editar": {"title": "Editar partida", "btnLabel": "Editar"}
    };

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Layout(
        appBarTitle: pantallas[tipo]["title"],
        appBarLeading: CustomIconButtom(
          iconSize: 25,
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),
        bodyContent: _Body(id: id, pantallas: pantallas, tipo: tipo),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, this.id, required this.pantallas, this.tipo}) : super(key: key);

  final int? id;
  final Map<String, dynamic> pantallas;
  final dynamic tipo;

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
    return FutureBuilder(
      future: formPartidaProvider.getPartida(id, context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppThemes.colorPrimero),
          );
        } else {
          // return SingleChildScrollView(child: Formulario());
          return Formulario(pantallas: pantallas, tipo: tipo);
        }
      },
    );
  }
}

class Formulario extends StatelessWidget {
  Formulario({Key? key, this.id, required this.pantallas, this.tipo}) : super(key: key) {
    myFormKey = GlobalKey<FormState>();
  }

  final int? id;
  late GlobalKey<FormState> myFormKey;
  final Map<String, dynamic> pantallas;
  final dynamic tipo;

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
    final Partida partida = formPartidaProvider.partida!;

    print('BUILD FORMULARIO');
    print("===> pantallas: $pantallas");
    print("===> tipo: $tipo");
    return Container(
      margin: const EdgeInsets.only(top: 40, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Form(
        key: myFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: CustomInputField(
                key: UniqueKey(),
                initialValueFn: () => partida.nombre,
                onChanged: (value) => partida.nombre = value,
                labelText: 'Nombre',
                validators: (value) {
                  print('VALIDANDO Nombre');
                  if (value == null) return 'Este campo es requerido';
                  return value.length < 3 ? 'Mínimo de 3 letras' : null;
                },
              ),
            ),

            const SizedBox(height: 20),

            const Titulo(),

            // Flexible(child: child),
            const SizedBox(height: 10),

            Flexible(
              flex: 5,
              child: Material(
                  color: AppThemes.Cards[AppThemes.currentTheme],
                  borderRadius: BorderRadius.circular(12),
                  shadowColor: AppThemes.colorTercero.withOpacity(0.3),
                  elevation: 7,
                  child: const _Inputs()),
            ),

            const SizedBox(height: 15),
            Flexible(
              flex: 1,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (validateAndSave()) {
                      Fun.logColor(color: Colores.red, body: partida.toString(), pretty: true);
                      final PartidasProvider partidaProvider = context.read<PartidasProvider>();
                      if (tipo == 'crear') {
                        partidaProvider.newPartida(partida);
                        Navigator.pop(context);
                      } else {}
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(pantallas[tipo]["btnLabel"], style: const TextStyle(fontSize: 20, fontFamily: 'Poppins')),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = myFormKey.currentState;

    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}

class Titulo extends StatelessWidget {
  const Titulo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();

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
  const _Inputs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();

    List<Jugador> jugadores = formPartidaProvider.partida!.jugadores!;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemCount: jugadores.length,
      itemBuilder: (BuildContext context, int index) {
        return _JugadorInput(jugador: jugadores[index], index: index);
      },
    );
  }
}

class _JugadorInput extends StatelessWidget {
  const _JugadorInput({Key? key, required this.jugador, required this.index}) : super(key: key);

  final Jugador jugador;

  final int index;

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            flex: 6,
            fit: FlexFit.tight,
            child: CustomInputField(
              key: UniqueKey(),
              initialValueFn: () => jugador.nombre,
              onChanged: (value) => jugador.nombre = value,
              labelText: 'Nombre',
              validators: (value) {
                if (value == null) return 'Este campo es requerido';
                return value.length < 3 ? 'Mínimo de 3 letras' : null;
              },
            )),
        Flexible(
            flex: 1,
            child: Visibility(
              visible: index >= 2,
              child: CustomIconButtom(
                  onTap: () => formPartidaProvider.removeJugadorToList(jugador),
                  icon: Icons.remove,
                  size: IconSize.min,
                  iconSize: 25,
                  backgroundColor: const Color(0xFFAF4C4C),
                  splashColor: const Color(0xFF7A2E2E)),
            ))
      ],
    );
  }
}
