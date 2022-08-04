import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerification {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  verifyPhone(String phone) async {
    PhoneVerificationCompleted verficationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      print("Verification completed");
    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException exception) {
      print("Verification failed");
    };
    PhoneCodeSent codeSent =
        (String verificationId, int? forceResendingToken) async {
      print("Code has been sent");
      final pref = await SharedPreferences.getInstance();
      pref.setString('verification_id', verificationId);
      // setState(() {
      //   _verificationCode = verificationId;
      // });
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print("Time out");
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: '+91 ${phone}',
          verificationCompleted: verficationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      print('Catch block');
    }
  }
}
