import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:game_score/themes/app_themes.dart';

class ListPartidas extends StatelessWidget {
  const ListPartidas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 5,
        shadowColor: AppThemes.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Domino',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppThemes.primary),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Text('2', style: TextStyle(color: Colors.grey, fontSize: 17)),
                  SizedBox(width: 3),
                  Icon(FontAwesomeIcons.users, size: 15, color: Colors.grey)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
