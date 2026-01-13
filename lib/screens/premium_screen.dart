import 'package:flutter/material.dart';
import 'package:game_score/providers/premium_provider.dart';
import 'package:game_score/services/purchase_service.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    CustomIconButtom(
                      iconSize: 25,
                      iconColor: AppThemes.colorTercero,
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _restorePurchases(context),
                      child: const Text(
                        'Restaurar compras',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Logo Premium
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.colorTercero, AppThemes.colorSegundo],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    'Coro Games Premium',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Desbloquea todas las funciones',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Features
                _FeatureItem(
                  icon: Icons.people,
                  title: 'Jugadores ilimitados',
                  description: 'Sin límite de jugadores por partida',
                  delay: 400,
                ),
                _FeatureItem(
                  icon: Icons.games,
                  title: 'Partidas ilimitadas',
                  description: 'Crea todas las partidas que quieras',
                  delay: 500,
                ),
                _FeatureItem(
                  icon: Icons.save,
                  title: 'Partidas predefinidas',
                  description: 'Guarda configuraciones ilimitadas',
                  delay: 600,
                ),
                _FeatureItem(
                  icon: Icons.history,
                  title: 'Historial completo',
                  description: 'Accede a todo el historial de jugadas',
                  delay: 700,
                ),
                _FeatureItem(
                  icon: Icons.block,
                  title: 'Sin anuncios',
                  description: 'Disfruta sin interrupciones',
                  delay: 800,
                ),
                
                const SizedBox(height: 40),
                
                // Buy Button
                Consumer<PremiumProvider>(
                  builder: (context, premiumProvider, child) {
                    if (premiumProvider.isPremium) {
                      return FadeInUp(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 30),
                              SizedBox(width: 10),
                              Text(
                                '¡Ya eres Premium!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return FadeInUp(
                      delay: const Duration(milliseconds: 900),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _buyPremium(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppThemes.colorTercero,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Obtener Premium',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                PurchaseService.instance.premiumPrice,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 15),
                
                FadeInUp(
                  delay: const Duration(milliseconds: 1000),
                  child: Text(
                    'Pago único • Sin suscripción',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _buyPremium(BuildContext context) async {
    final success = await PurchaseService.instance.buyPremium();
    if (!success) {
      Fun.toast(
        type: ToasType.error,
        context: context,
        message: 'No se pudo completar la compra. Intenta de nuevo.',
      );
    }
  }

  void _restorePurchases(BuildContext context) async {
    final premiumProvider = context.read<PremiumProvider>();
    await premiumProvider.checkAndRestorePurchases();
    
    if (premiumProvider.isPremium) {
      Fun.toast(
        type: ToasType.success,
        context: context,
        message: '¡Compras restauradas! Ya eres Premium.',
      );
    } else {
      Fun.toast(
        type: ToasType.info,
        context: context,
        message: 'No se encontraron compras anteriores.',
      );
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int delay;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppThemes.themeColor_2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppThemes.colorTercero.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppThemes.colorTercero, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

