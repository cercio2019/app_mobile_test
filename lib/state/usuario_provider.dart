import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';

/// Estado del modulo de usuarios: registro de nuevas cuentas y
/// administracion (listar/eliminar) de las ya existentes. El registro es el
/// unico endpoint publico ademas del login; el resto exige sesion.
class UsuarioProvider extends ChangeNotifier {
  final UsuarioService _service = UsuarioService();

  List<Usuario> _usuarios = [];
  bool _cargando = false;
  String? _error;

  List<Usuario> get usuarios => _usuarios;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _usuarios = await _service.listar();
    } on ApiException catch (e) {
      _error = e.mensaje;
    } catch (_) {
      _error = 'No se pudo cargar la lista de usuarios.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Consulta el detalle de un usuario directamente en la API
  /// (GET /api/usuarios/:id), usado en la vista de detalle del listado.
  Future<Usuario?> obtenerDetalle(int id) async {
    try {
      return await _service.obtener(id);
    } catch (_) {
      return null;
    }
  }

  Future<String?> registrar({required String username, required String password}) async {
    try {
      await _service.registrar(username: username, password: password);
      return null; // sin error
    } on ApiException catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo registrar el usuario.';
    }
  }

  Future<String?> eliminar(int id) async {
    try {
      await _service.eliminar(id);
      _usuarios.removeWhere((u) => u.id == id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo eliminar el usuario.';
    }
  }
}
