// lib/auth/auth_service.dart
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String AUTH0_DOMAIN = 'dev-ukaaosck1wcq8dyt.us.auth0.com'; // Replace
  static const String AUTH0_CLIENT_ID = 'XvsypJg9OMoum6BYAVUx3IDtpGz4ChPG'; // Replace
  static const String AUTH0_REDIRECT_URI = 'ink.qbit.app.mobile://login-callback'; // Replace
  static const String AUTH0_ISSUER = 'https://$AUTH0_DOMAIN/'; // Replace YOUR_AUTH0_DOMAIN
  static const String AUTH0_AUDIENCE = 'YOUR_API_IDENTIFIER'; // Replace with the Auth0 API Identifier
  static const String REFRESH_TOKEN_KEY = 'refresh_token';

  Future<bool> isLoggedIn() async {
    final refreshToken = await _secureStorage.read(key: REFRESH_TOKEN_KEY);
    if (refreshToken == null) {
      return false;
    }
    try {
      // Attempt to refresh the token to validate it
      await refreshTokenGrant(refreshToken);
      return true; // Token refreshed successfully, so user is still logged in
    } catch (e) {
      // Refresh failed, token is likely invalid
      if (kDebugMode) {
        print('Refresh token failed: $e');
      }
      await logout(); // Clear storage on refresh failure
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    final refreshToken = await _secureStorage.read(key: REFRESH_TOKEN_KEY);

    if (refreshToken == null) {
      return null; // No refresh token, so no access token
    }

    try {
      final tokenData = await refreshTokenGrant(refreshToken);
      return tokenData.accessToken;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to refresh token: $e');
      }
      // Handle refresh failure - maybe logout the user
      return null;
    }
  }


  Future<TokenData> login() async {
    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: AUTH0_ISSUER,
          scopes: ['openid', 'profile', 'offline_access', 'read:messages'], // Add scopes as needed.  'offline_access' is required for refresh tokens.
          promptValues: ['login'], // Ensure a fresh login
          additionalParameters: {'audience': AUTH0_AUDIENCE},
        ),
      );

      if (result != null) {
        await _secureStorage.write(
            key: REFRESH_TOKEN_KEY, value: result.refreshToken);
        return TokenData(result.accessToken!, result.idToken!);

      } else {
        throw Exception('Login failed: No result returned.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      rethrow;
    }
  }

  Future<TokenData> refreshTokenGrant(String refreshToken) async {
    try {
      final TokenResponse? result = await _appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
        refreshToken: refreshToken,
        grantType: 'refresh_token',
        additionalParameters: {'audience': AUTH0_AUDIENCE},
      ));

      if (result != null) {
        // Update the refresh token, as Auth0 may rotate them
        await _secureStorage.write(
            key: REFRESH_TOKEN_KEY, value: result.refreshToken);
        return TokenData(result.accessToken!, result.idToken!);
      } else {
        throw Exception('Refresh token grant failed: No result returned.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Refresh token grant error: $e');
      }
      await logout(); // Clear credentials on refresh failure
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _appAuth.endSession(EndSessionRequest(
        idTokenHint: JwtDecoder.decode(await _secureStorage.read(key: 'id_token') ?? '')['sub'], // User's ID from ID token
        postLogoutRedirectUrl: AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
      ));
      await _secureStorage.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    //Use the JWT library to extract information from the token,
    // or use the Auth0 /userinfo endpoint
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    return decodedToken;
  }
}

class TokenData {
  final String accessToken;
  final String idToken;

  TokenData(this.accessToken, this.idToken);
}