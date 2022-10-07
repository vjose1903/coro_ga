import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/utils/utils.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseHelper {
  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);

    PurchasesConfiguration configuration;

    if (StoreConfig.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..observerMode = false;
    } else {
      Fun.logColor(color: Colores.magenta, body: "ANDO AQUII");
      configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..observerMode = false;
      Fun.logColor(color: Colores.yellow, body: "$configuration");
    }
      Fun.logColor(color: Colores.red, body: "bla bla");
    await Purchases.configure(configuration);
      Fun.logColor(color: Colores.blue, body: "bla bla");

    appData.appUserID = await Purchases.appUserID;

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      appData.appUserID = await Purchases.appUserID;

      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      Fun.logColor(color: Colores.yellow, body: "$customerInfo");

      (customerInfo.entitlements.all[entitlementID] != null && customerInfo.entitlements.all[entitlementID]!.isActive)
          ? appData.entitlementIsActive = true
          : appData.entitlementIsActive = false;
    });
  }


  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } catch (e) {
      return [];
    }
  }
}
