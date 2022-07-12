import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';

class ListPartidas extends StatelessWidget {
  const ListPartidas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 5,
        shadowColor: AppThemes.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
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
                    child: const Text(
                      'Domino',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppThemes.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const LabelWithIcon(icon: FontAwesomeIcons.users, label: '2'),
                      const SizedBox(width: 30),
                      //
                      LabelWithIcon(
                          orden: Orden.primeroIcono,
                          maxSize: size.width - 335,
                          icon: Icons.arrow_upward,
                          label: 'Pedros dfkjnsdkf',
                          iconColor: Colors.green[300]),
                      //
                      const SizedBox(width: 10),
                      //
                      LabelWithIcon(
                          orden: Orden.primeroIcono,
                          maxSize: size.width - 335,
                          icon: Icons.arrow_downward,
                          label: 'Ramon sdkbdfkjsd',
                          iconColor: Colors.red[200]),
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
    );
  }
}
