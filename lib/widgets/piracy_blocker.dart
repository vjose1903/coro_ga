import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_score/shared_preferences/preferences.dart';

/// Widget que bloquea toda la app si se detecta piratería
class PiracyBlocker extends StatelessWidget {
  const PiracyBlocker({Key? key}) : super(key: key);

  String get _unauthorizedTitle {
    return Preferences.languageCode == 'en' ? 'Unauthorized Version' : 'Versión No Autorizada';
  }

  String get _illegitimateMessage {
    return Preferences.languageCode == 'en' 
        ? 'This copy of the app is not legitimate.\n\nPlease download the official version from Google Play Store to enjoy all features.'
        : 'Esta copia de la aplicación no es legítima.\n\nPor favor, descarga la versión oficial desde Google Play Store para disfrutar de todas las funciones.';
  }

  String get _closeAppText {
    return Preferences.languageCode == 'en' ? 'Close app' : 'Cerrar aplicación';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de la app
                  Image.asset(
                    'assets/icon/iconCircular.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 32),
                  
                  // Título
                  Text(
                    _unauthorizedTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Mensaje
                  Text(
                    _illegitimateMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Botón para cerrar la app
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _closeAppText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

