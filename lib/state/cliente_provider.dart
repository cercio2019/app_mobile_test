import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';

/// Estado del modulo de Clientes: expone la lista, el estado de carga/error
/// y las operaciones CRUD completas contra /api/clientes.
class ClienteProvider extends ChangeNotifier {
  final ClienteService _service = ClienteService();

  List<Cliente> _clientes = [];
  bool _cargando = false;
  String? _error;

  List<Cliente> get clientes => _clientes;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _clientes = await _service.listar();
    } on ApiException catch (e) {
      _error = e.mensaje;
    } catch (_) {
      _error = 'No se pudo cargar la lista de clientes.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Trae la version mas actualizada de un cliente directamente desde la API
  /// (GET /api/clientes/:id). Se usa al abrir el formulario de edicion para
  /// no editar sobre datos potencialmente desactualizados de la lista local.
  Future<Cliente?> obtenerDetalle(int id) async {
    try {
      return await _service.obtener(id);
    } catch (_) {
      return null;
    }
  }

  Future<String?> crear(Cliente cliente) async {
    try {
      final creado = await _service.crear(cliente);
      _clientes = [..._clientes, creado];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo crear el cliente.';
    }
  }

  Future<String?> actualizar(int id, Cliente cliente) async {
    try {
      final actualizado = await _service.actualizar(id, cliente);
      _clientes = _clientes.map((c) => c.id == id ? actualizado : c).toList();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo actualizar el cliente.';
    }
  }

  Future<String?> eliminar(int id) async {
    try {
      await _service.eliminar(id);
      _clientes = _clientes.where((c) => c.id != id).toList();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo eliminar el cliente.';
    }
  }
}
