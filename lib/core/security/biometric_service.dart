import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  static Future<bool> authenticate() async {
    if (!await canAuthenticate()) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock Kuku Fiti',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allows PIN fallback
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
