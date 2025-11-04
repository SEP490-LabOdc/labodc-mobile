import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// 🔹 Khởi tạo Google Sign-In (chạy khi app start)
  static Future<void> initialize({
    String? clientId,
    String? serverClientId,
  }) async {
    try {
      await _googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );

      // Log các sự kiện đăng nhập
      _googleSignIn.authenticationEvents.listen((event) {
        debugPrint("📢 [GoogleAuthService] Authentication Event: $event");
      });

      await _googleSignIn.attemptLightweightAuthentication();
      debugPrint("✅ [GoogleAuthService] Initialized successfully.");
    } catch (e) {
      debugPrint("❌ [GoogleAuthService] Init failed: $e");
    }
  }

  /// 🔹 Đăng nhập Google → Trả về idToken để gửi lên BE
  static Future<String?> signInWithGoogle() async {
    try {
      // 1️⃣ Thực hiện đăng nhập (authenticate) – trả về user
      final user = await _googleSignIn.authenticate();
      if (user == null) {
        debugPrint("⚠️ [GoogleAuthService] No user found after authenticate()");
        return null;
      }

      // 2️⃣ Lấy idToken từ authorizationClient
      final authorization = await user.authentication;
      final idToken = authorization.idToken;

      if (idToken == null) {
        debugPrint("⚠️ [GoogleAuthService] No idToken found.");
        return null;
      }

      debugPrint("✅ [GoogleAuthService] Got idToken successfully.");
      return idToken;
    } catch (e) {
      debugPrint("❌ [GoogleAuthService] Sign-in failed: $e");
      return null;
    }
  }


  /// 🔹 Đăng xuất
  static Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      debugPrint("👋 [GoogleAuthService] Signed out.");
    } catch (e) {
      debugPrint("⚠️ [GoogleAuthService] Sign-out error: $e");
    }
  }
}
