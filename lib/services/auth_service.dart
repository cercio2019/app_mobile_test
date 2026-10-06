import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/usuario.dart';

/// Resultado de un login exitoso: token + datos basicos del usuario.
class LoginResult {
  final String token;
  final Usuario usuario;

  const LoginResult({required this.token, required this.usuario});
}

/// Consume POST /api/auth/login. Es el unico servicio que no requiere token
/// (es justamente el que lo genera).
class AuthService {
  final ApiClient _client = ApiClient.instance;

  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final data = await _client.post(
      AppConstants.apiAuthLogin,
      body: {'username': username, 'password': password},
    ) as Map<String, dynamic>;

    return LoginResult(
      token: data['token'] as String,
      usuario: Usuario.fromJson(data['usuario'] as Map<String, dynamic>),
    );
  }
}
