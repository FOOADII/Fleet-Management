import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/tracking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoreBinding extends Bindings {
  @override
  void dependencies() async {
    // Register services
    Get.put<AuthService>(FirebaseAuthService(), permanent: true);
    Get.put<TrackingService>(TrackingService(), permanent: true);

    // Register instance of SharedPreferences for settings and preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
  }
}
