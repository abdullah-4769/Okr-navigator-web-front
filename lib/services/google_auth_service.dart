import 'dart:developer';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static const String webClientId =
      "1016249703708-muc5a4jujc06930ir01kc6mg5rrlniop.apps.googleusercontent.com";

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: webClientId,
    scopes: ['email', 'profile'],
  );

  Future<String?> signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();

      if (user == null) return null;

      final auth = await user.authentication;

      return auth.idToken;
    } catch (e) {
      log("error: $e");
      return null;
    }
  }
}
