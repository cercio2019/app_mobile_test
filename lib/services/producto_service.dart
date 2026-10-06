import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/producto.dart';

/// Consume los endpoints de /api/productos (todos requieren token). Estos
/// endpoints son multipart/form-data porque aceptan un archivo de imagen
/// opcional en el campo "imagen".
///  - POST   /api/productos
///  - GET    /api/productos
///  - GET    /api/productos/:id
///  - PUT    /api/productos/:id
///  - DELETE /api/productos/:id
class ProductoService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Producto>> listar() async {
    final data = await _client.get(AppConstants.apiProductos) as List;
    return data
        .map((e) => Producto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Producto> obtener(int id) async {
    final data = await _client.get('${AppConstants.apiProductos}/$id')
        as Map<String, dynamic>;
    return Producto.fromJson(data);
  }

  Future<Producto> crear(Producto producto, {ApiFile? imagen}) async {
    final data = await _client.multipart(
      AppConstants.apiProductos,
      method: 'POST',
      fields: producto.toFormFields(),
      file: imagen,
    ) as Map<String, dynamic>;
    return Producto.fromJson(data);
  }

  Future<Producto> actualizar(int id, Producto producto, {ApiFile? imagen}) async {
    final data = await _client.multipart(
      '${AppConstants.apiProductos}/$id',
      method: 'PUT',
      fields: producto.toFormFields(),
      file: imagen,
    ) as Map<String, dynamic>;
    return Producto.fromJson(data);
  }

  Future<void> eliminar(int id) async {
    await _client.delete('${AppConstants.apiProductos}/$id');
  }
}
