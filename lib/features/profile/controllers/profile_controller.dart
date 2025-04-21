import 'package:get/get.dart';
import '../../../core/services/mock_auth_service.dart';
import '../../../core/models/mock_user.dart';

class ProfileController extends GetxController {
  final MockAuthService _authService = MockAuthService();
  final Rx<MockUser?> currentUser = Rx<MockUser?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _authService.authStateChanges.listen((user) {
      currentUser.value = user;
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      isLoading.value = true;
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      currentUser.value = _authService.currentUser;
    } catch (e) {
      print('Error updating profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _authService.dispose();
    super.onClose();
  }
}
