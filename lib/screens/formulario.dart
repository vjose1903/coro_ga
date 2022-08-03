import 'package:flutter/material.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/models/models.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:we_slide/we_slide.dart';

class FormularioScreen extends StatelessWidget {
  const FormularioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map;
    final tipo = routeArgs['tipo'];
    final id = routeArgs['id'];

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Layout(
        weSlideController: WeSlideController(),
        appBarTitle: "Crear nueva partida",
        appBarLeading: CustomIconButtom(
          iconSize: 25,
          iconColor: Colors.white,
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context, 'home'),
        ),
        bodyContent: _Body(id: id, tipo: tipo),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, this.id, this.tipo}) : super(key: key);

  final int? id;

  final dynamic tipo;

  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.read<FormPartidaProvider>();
    return FutureBuilder(
      future: formPartidaProvider.getPartida(id, context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppThemes.colorTercero),
          );
        } else {
          return Formulario(tipo: tipo);
        }
      },
    );
  }
}

class Formulario extends StatelessWidget {
  Formulario({Key? key, this.id, this.tipo}) : super(key: key) {
    myFormKey = GlobalKey<FormState>();
  }

  final int? id;
  late GlobalKey<FormState> myFormKey;

  final dynamic tipo;
  final ScrollController jugadoresController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Consumer(builder: (BuildContext context, value, Widget? child) {
      final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();
      final Partida partida = formPartidaProvider.partida!;
      final dynamic tipoPartida = formPartidaProvider.formPartida.control('tipo').value;

      print('tipoPartida: ($tipoPartida)');
      print('width: ${tipoPartida == "Rondas" || tipoPartida == '' ? double.infinity : screenSize.width * 0.4}');

      return Container(
          margin: const EdgeInsets.only(top: 40, bottom: 40),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ReactiveForm(
            key: myFormKey,
            formGroup: formPartidaProvider.formPartida,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomReactiveInput(formControlName: 'nombre', labelText: "Nombre", textCapitalization: TextCapitalization.words),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.none,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          height: 50,
                          width: tipoPartida == "Rondas" || tipoPartida == '' ? screenSize.width - 52 : screenSize.width * 0.42,
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
                      ),
                    ),
                    if (tipoPartida != null && tipoPartida == 'Puntuación')
                      const Flexible(child: CustomReactiveInput(formControlName: 'maxPuntuacion', labelText: "Puntuación Maxima")),
                  ],
                )
              ],
            ),
          )

          // child: Form(
          //   key: myFormKey,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       CustomInputField(
          //         key: UniqueKey(),
          //         initialValueFn: () => partida.nombre,
          //         onChanged: (value) => partida.nombre = value,
          //         labelText: 'Nombre',
          //         validators: (value) {
          //           if (value == null) return 'Este campo es requerido';
          //           return value.length < 3 ? 'Mínimo de 3 letras' : null;
          //         },
          //       ),
          //       const SizedBox(height: 20),
          //       Titulo(jugadoresController: jugadoresController),
          //       const SizedBox(height: 10),
          //       Expanded(
          //           child: Material(
          //         color: AppThemes.themeColor_2,
          //         borderRadius: BorderRadius.circular(12),
          //         shadowColor: AppThemes.colorQuinto.withOpacity(0.3),
          //         elevation: 7,
          //         // child: Container(),
          //         child: _Inputs(jugadoresController: jugadoresController),
          //       )),
          //       const SizedBox(height: 15),
          //       Center(
          //         child: ElevatedButton(
          //           onPressed: () async {
          //             if (validateAndSave()) {
          //               final PartidaProvider partidaProvider = context.read<PartidaProvider>();

          //               final response = await partidaProvider.newPartida(partida, context);

          //               if (!response.hasError!) {
          //                 final newPartida = response.data;
          //                 await Future.delayed(const Duration(milliseconds: 500));
          //                 partidaProvider.navigateToPartida(context: context, partida: newPartida);
          //               } else {
          //                 Fun.toast(type: ToasType.error, context: context, message: "Error registrando partida.");
          //               }
          //             }
          //           },
          //           child: const Padding(
          //             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //             child: Text("Crear", style: TextStyle(fontSize: 15, fontFamily: 'Poppins')),
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          );
    });
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
  const Titulo({Key? key, required this.jugadoresController}) : super(key: key);
  final ScrollController jugadoresController;
  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Jugadores', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w100)),
            Container(
              width: 26,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppThemes.colorTercero, borderRadius: BorderRadius.circular(50)),
              child: Center(
                  child: Text(
                formPartidaProvider.jugadores.length.toString(),
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(color: Colors.white),
              )),
            )
          ],
        ),
        Visibility(
          visible: formPartidaProvider.jugadores.length < 20,
          child: CustomIconButtom(
            onTap: () async {
              formPartidaProvider.addJugadorToList(Jugador());
              await Future.delayed(const Duration(milliseconds: 20));

              jugadoresController.animateTo(jugadoresController.position.maxScrollExtent,
                  duration: const Duration(seconds: 1, milliseconds: 500), curve: Curves.elasticOut);

              if (formPartidaProvider.jugadores.length == 20) {
                Fun.toast(type: ToasType.info, context: context, message: "Máximo de jugadores alcanzados");
              }
            },
            icon: Icons.add,
            size: IconSize.min,
            iconSize: 25,
            backgroundColor: const Color(0xFF4CAF50),
            splashColor: const Color(0xFF2E7A31),
          ),
        )
      ],
    );
  }
}

class _Inputs extends StatelessWidget {
  const _Inputs({Key? key, required this.jugadoresController}) : super(key: key);
  final ScrollController jugadoresController;
  @override
  Widget build(BuildContext context) {
    final FormPartidaProvider formPartidaProvider = context.watch<FormPartidaProvider>();

    List<Jugador> jugadores = formPartidaProvider.jugadores;

    return ListView.separated(
      controller: jugadoresController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      separatorBuilder: (_, __) => const SizedBox(height: 15),
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
      children: [
        Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: SizedBox(
                width: 20,
                child: Text(
                  (index + 1).toString(),
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.withOpacity(0.6)),
                ))),
        const SizedBox(width: 5),
        Flexible(
            flex: 10,
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
        const SizedBox(width: 10),
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
