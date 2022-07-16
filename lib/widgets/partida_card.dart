import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';

class PartidaCard extends StatelessWidget {
  const PartidaCard({Key? key, required this.partida, required this.function, required this.index}) : super(key: key);
  final int index;
  final Partida partida;
  final Function function;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: AppThemes.Cards[AppThemes.currentTheme],
      borderRadius: BorderRadius.circular(12),
      shadowColor: AppThemes.colorSegundo.withOpacity(0.3),
      elevation: 7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SwipeActionCell(
          backgroundColor: Colors.transparent,
          key: UniqueKey(),
          trailingActions: <SwipeAction>[
            SwipeAction(
              nestedAction: SwipeNestedAction(title: "Confirmar"),
              title: "Borrar",
              onTap: (CompletionHandler handler) async {
                await handler(true);
                function();
              },
              color: Colors.red,
            ),
            SwipeAction(
                title: "Editar",
                onTap: (CompletionHandler handler) async {
                  /// false means that you just do nothing,it will close
                  /// action buttons by default
                  handler(false);
                },
                color: Colors.grey),
          ],
          child: InkWell(
            onTap: () => print('aks'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width - 160),
                        child: Text(
                          partida.nombre!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppThemes.colorSegundo),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          LabelWithIcon(icon: FontAwesomeIcons.users, label: "${partida.cantJugadores}"),
                          const SizedBox(width: 30),
                          EstadoPartida(partida: partida)
                        ],
                      )
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Material(
//       color: AppThemes.Cards[AppThemes.currentTheme],
//       borderRadius: BorderRadius.circular(12),
//       shadowColor: AppThemes.secundary.withOpacity(0.3),
//       elevation: 7,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           onTap: () => print('aks'),
//           child: SwipeActionCell(
//             backgroundColor: Colors.transparent,
//             key: UniqueKey(),
//             trailingActions: <SwipeAction>[
//               SwipeAction(
//                 nestedAction: SwipeNestedAction(title: "Confirmar"),
//                 title: "Borrar",
//                 onTap: (CompletionHandler handler) async {
//                   await handler(true);
//                   function(index);
//                 },
//                 color: Colors.red,
//               ),
//               SwipeAction(
//                   title: "Editar",
//                   onTap: (CompletionHandler handler) async {
//                     handler(false);
//                   },
//                   color: Colors.grey),
//             ],
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ConstrainedBox(
//                         constraints: BoxConstraints(maxWidth: size.width - 160),
//                         child: Text(
//                           partida.nombre,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppThemes.secundary),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           LabelWithIcon(icon: FontAwesomeIcons.users, label: "${partida.cantJugadores}"),
//                           const SizedBox(width: 30),
//                           EstadoPartida(partida: partida)
//                         ],
//                       )
//                     ],
//                   ),
//                   const Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     color: Colors.grey,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

class EstadoPartida extends StatelessWidget {
  const EstadoPartida({Key? key, required this.partida}) : super(key: key);

  final Partida partida;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (partida.isEmpate) {
      return LabelWithIcon(
          orden: Orden.primeroIcono,
          maxSize: size.width - 335,
          icon: Icons.swap_horiz_outlined,
          label: 'Empate',
          iconColor: Colors.yellow[800],
          iconBackgroundColor: Colors.yellow[100]);
    } else {
      return GanadorPerdedor(partida: partida);
    }
  }
}

class GanadorPerdedor extends StatelessWidget {
  const GanadorPerdedor({Key? key, required this.partida}) : super(key: key);
  final Partida partida;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        //
        LabelWithIcon(
            orden: Orden.primeroIcono,
            maxSize: size.width - 335,
            icon: Icons.arrow_upward,
            label: partida.getGandorOrPerdedor(Estado.ganador),
            iconColor: Colors.green[500],
            iconBackgroundColor: const Color(0xFFDDF2DE)),
        //
        const SizedBox(width: 10),
        //
        LabelWithIcon(
            orden: Orden.primeroIcono,
            maxSize: size.width - 335,
            icon: Icons.arrow_downward,
            label: partida.getGandorOrPerdedor(Estado.perdedor),
            iconColor: Colors.red[300],
            iconBackgroundColor: const Color(0xFFF2DDDD)),
      ],
    );
  }
}
