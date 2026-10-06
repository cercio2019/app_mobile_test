import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/usuario.dart';

/// Consume los endpoints de /api/usuarios:
///  - POST   /api/usuarios      (publico, registro)
///  - GET    /api/usuarios      (requiere token)
///  - GET    /api/usuarios/:id  (requiere token)
///  - DELETE /api/usuarios/:id  (requiere token)
class UsuarioService {
  final ApiClient _client = ApiClient.instance;

  Future<Usuario> registrar({
    required String username,
    required String password,
  }) async {
    final data = await _client.post(
      AppConstants.apiUsuarios,
      body: {'username': username, 'password': password},
    ) as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }

  Future<List<Usuario>> listar() async {
    final data = await _client.get(AppConstants.apiUsuarios) as List;
    return data
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Usuario> obtener(int id) async {
    final data = await _client.get('${AppConstants.apiUsuarios}/$id')
        as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }

  Future<void> eliminar(int id) async {
    await _client.delete('${AppConstants.apiUsuarios}/$id');
  }
}
