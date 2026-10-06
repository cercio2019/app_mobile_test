import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/cliente.dart';

/// Consume los endpoints de /api/clientes (todos requieren token):
///  - POST   /api/clientes
///  - GET    /api/clientes
///  - GET    /api/clientes/:id
///  - PUT    /api/clientes/:id
///  - DELETE /api/clientes/:id
class ClienteService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Cliente>> listar() async {
    final data = await _client.get(AppConstants.apiClientes) as List;
    return data
        .map((e) => Cliente.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Cliente> obtener(int id) async {
    final data = await _client.get('${AppConstants.apiClientes}/$id')
        as Map<String, dynamic>;
    return Cliente.fromJson(data);
  }

  Future<Cliente> crear(Cliente cliente) async {
    final data = await _client.post(
      AppConstants.apiClientes,
      body: cliente.toJson(),
    ) as Map<String, dynamic>;
    return Cliente.fromJson(data);
  }

  Future<Cliente> actualizar(int id, Cliente cliente) async {
    final data = await _client.put(
      '${AppConstants.apiClientes}/$id',
      body: cliente.toJson(),
    ) as Map<String, dynamic>;
    return Cliente.fromJson(data);
  }

  Future<void> eliminar(int id) async {
    await _client.delete('${AppConstants.apiClientes}/$id');
  }
}
