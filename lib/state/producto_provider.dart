import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

/// Estado del modulo de Productos: expone la lista, el estado de carga/error
/// y las operaciones CRUD completas contra /api/productos (incluye subida
/// de imagen opcional).
class ProductoProvider extends ChangeNotifier {
  final ProductoService _service = ProductoService();

  List<Producto> _productos = [];
  bool _cargando = false;
  String? _error;

  List<Producto> get productos => _productos;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _productos = await _service.listar();
    } on ApiException catch (e) {
      _error = e.mensaje;
    } catch (_) {
      _error = 'No se pudo cargar la lista de productos.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Trae la version mas actualizada de un producto directamente desde la
  /// API (GET /api/productos/:id), usado al abrir el formulario de edicion.
  Future<Producto?> obtenerDetalle(int id) async {
    try {
      return await _service.obtener(id);
    } catch (_) {
      return null;
    }
  }

  Future<String?> crear(Producto producto, {ApiFile? imagen}) async {
    try {
      final creado = await _service.crear(producto, imagen: imagen);
      _productos = [..._productos, creado];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo crear el producto.';
    }
  }

  Future<String?> actualizar(int id, Producto producto, {ApiFile? imagen}) async {
    try {
      final actualizado = await _service.actualizar(id, producto, imagen: imagen);
      _productos = _productos.map((p) => p.id == id ? actualizado : p).toList();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo actualizar el producto.';
    }
  }

  Future<String?> eliminar(int id) async {
    try {
      await _service.eliminar(id);
      _productos = _productos.where((p) => p.id != id).toList();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo eliminar el producto.';
    }
  }
}
