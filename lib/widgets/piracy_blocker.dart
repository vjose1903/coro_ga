import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget que bloquea toda la app si se detecta piratería
class PiracyBlocker extends StatelessWidget {
  const PiracyBlocker({Key? key}) : super(key: key);

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
                  const Text(
                    'Versión No Autorizada',
                    style: TextStyle(
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
                    'Esta copia de la aplicación no es legítima.\n\n'
                    'Por favor, descarga la versión oficial desde Google Play Store para disfrutar de todas las funciones.',
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
                    child: const Text(
                      'Cerrar aplicación',
                      style: TextStyle(
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

