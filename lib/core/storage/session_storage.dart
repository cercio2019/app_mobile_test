import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Envoltorio sobre [FlutterSecureStorage] con todo lo relacionado a la
/// sesion del usuario (token JWT, datos basicos del usuario y la URL base
/// de la API configurada). Se usa desde [AuthProvider] y desde el
/// interceptor de [ApiClient], y es el unico punto de la app que sabe como
/// se persiste esta informacion.
class SessionStorage {
  SessionStorage._internal();
  static final SessionStorage instance = SessionStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required int usuarioId,
    required String username,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.storageKeyToken, value: token),
      _storage.write(
        key: AppConstants.storageKeyUsuarioId,
        value: usuarioId.toString(),
      ),
      _storage.write(
        key: AppConstants.storageKeyUsuarioUsername,
        value: username,
      ),
    ]);
  }

  Future<String?> readToken() => _storage.read(key: AppConstants.storageKeyToken);

  Future<String?> readUsername() =>
      _storage.read(key: AppConstants.storageKeyUsuarioUsername);

  Future<int?> readUsuarioId() async {
    final raw = await _storage.read(key: AppConstants.storageKeyUsuarioId);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: AppConstants.storageKeyToken),
      _storage.delete(key: AppConstants.storageKeyUsuarioId),
      _storage.delete(key: AppConstants.storageKeyUsuarioUsername),
    ]);
  }

  Future<String> readBaseUrl() async {
    final saved = await _storage.read(key: AppConstants.storageKeyBaseUrl);
    return saved ?? AppConstants.defaultBaseUrl;
  }

  Future<void> saveBaseUrl(String baseUrl) =>
      _storage.write(key: AppConstants.storageKeyBaseUrl, value: baseUrl);
}
