import 'package:local_auth/local_auth.dart';

class AttendanceSecurityService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<void> verifyDeviceOwner() async {
    final supported = await _auth.isDeviceSupported();
    final canCheckBiometrics = await _auth.canCheckBiometrics;

    if (!supported && !canCheckBiometrics) {
      throw Exception(
        'Device authentication is not available. Set a phone passcode or fingerprint first.',
      );
    }

    final verified = await _auth.authenticate(
      localizedReason: 'Confirm your identity to record HR attendance',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
        useErrorDialogs: true,
      ),
    );

    if (!verified) {
      throw Exception('Device verification was cancelled.');
    }
  }
}
