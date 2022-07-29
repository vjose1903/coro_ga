import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';

class EditarEntidad extends StatelessWidget {
  const EditarEntidad({Key? key, this.jugador, this.partida, required this.pageController}) : super(key: key);

  final Jugador? jugador;
  final Partida? partida;
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    late String tipo;
    dynamic entidad;

    if (partida != null) {
      tipo = "Partida";
      entidad = partida;
    } else {
      tipo = "Jugador";
      entidad = jugador;
    }

    final Color titleColor = AppThemes.currentTheme == "dark" ? Colors.grey.withOpacity(0.9) : AppThemes.colorCuarto.withOpacity(0.7);
    final Color subTitleColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.8) : AppThemes.colorCuarto.withOpacity(0.9);

    return Container(
      height: double.infinity,
      color: Colors.red,
      child: Column(
        children: [
          Row(
            children: [
              Text("Editar $tipo:", style: TextStyle(fontFamily: "Poppins", fontSize: 18, color: titleColor)),
              const SizedBox(width: 7),
              Text(entidad.nombre, style: TextStyle(fontFamily: "Poppins", fontSize: 17, color: subTitleColor, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // CANCELAR ==========================================
              ExpandedButtom(backgroundColor: Colors.red[400], label: "Cancelar", textColor: Colors.white, onTap: () => previusPage(pageController)),

              const SizedBox(width: 10),
              // ACEPTAR ==========================================
              ExpandedButtom(backgroundColor: Colors.green[400], label: "Aceptar", textColor: Colors.white, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  previusPage(pageController) {
    pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }
}
