import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Servicio para manejar el consentimiento de usuario (GDPR/UMP)
class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  bool _isInitialized = false;
  bool _canRequestAds = false;

  bool get canRequestAds => _canRequestAds;

  /// Inicializa el sistema de consentimiento UMP
  /// Debe llamarse antes de cargar cualquier anuncio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar parámetros de consentimiento
      final params = ConsentRequestParameters();

      // Solicitar actualización de información de consentimiento
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          // Verificar si se puede mostrar el formulario de consentimiento
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await _loadAndShowConsentFormIfRequired();
          }
          _updateCanRequestAds();
        },
        (FormError error) {
          // En caso de error, permitir anuncios (mejor UX)
          debugPrint('ConsentService: Error updating consent info: ${error.message}');
          _canRequestAds = true;
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('ConsentService: Exception during initialization: $e');
      _canRequestAds = true;
    }
  }

  /// Carga y muestra el formulario de consentimiento si es requerido
  Future<void> _loadAndShowConsentFormIfRequired() async {
    final status = await ConsentInformation.instance.getConsentStatus();

    if (status == ConsentStatus.required) {
      ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
        if (error != null) {
          debugPrint('ConsentService: Error showing consent form: ${error.message}');
        }
        _updateCanRequestAds();
      });
    }
  }

  /// Actualiza el estado de si se pueden solicitar anuncios
  Future<void> _updateCanRequestAds() async {
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
  }

  /// Permite al usuario cambiar sus preferencias de consentimiento manualmente
  /// Útil para agregar en ajustes de la app
  Future<void> showPrivacyOptionsForm() async {
    final status = await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();

    if (status == PrivacyOptionsRequirementStatus.required) {
      ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (error != null) {
          debugPrint('ConsentService: Error showing privacy options: ${error.message}');
        }
      });
    }
  }

  /// Resetea el estado de consentimiento (útil para testing)
  void reset() {
    ConsentInformation.instance.reset();
    _isInitialized = false;
    _canRequestAds = false;
  }
}

