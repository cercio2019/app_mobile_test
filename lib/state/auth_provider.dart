import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/storage/session_storage.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

enum AuthStatus { desconocido, autenticado, noAutenticado }

/// Estado global de autenticacion. Es el corazon de la app: todos los demas
/// modulos (clientes, productos, usuarios) dependen de que exista una sesion
/// valida, y este provider es quien la crea, la restaura al abrir la app y
/// la destruye (logout manual o automatico por token expirado/401).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.desconocido;
  Usuario? _usuario;
  String? _error;
  bool _cargando = false;
  String _baseUrl = '';

  AuthStatus get status => _status;
  Usuario? get usuario => _usuario;
  String? get error => _error;
  bool get cargando => _cargando;
  bool get isAuthenticated => _status == AuthStatus.autenticado;
  String get baseUrl => _baseUrl;

  AuthProvider() {
    // Cualquier request de la app que reciba 401 dispara un logout global.
    ApiClient.instance.onUnauthorized = () {
      if (_status == AuthStatus.autenticado) {
        _error = 'Tu sesion expiro. Por favor inicia sesion de nuevo.';
        _limpiarSesionLocal();
        notifyListeners();
      }
    };
  }

  /// Se llama una vez al iniciar la app: intenta restaurar la sesion
  /// guardada en almacenamiento seguro para no pedir login en cada apertura.
  Future<void> restaurarSesion() async {
    _baseUrl = await SessionStorage.instance.readBaseUrl();
    final token = await SessionStorage.instance.readToken();
    final username = await SessionStorage.instance.readUsername();
    final id = await SessionStorage.instance.readUsuarioId();

    if (token != null && token.isNotEmpty && username != null && id != null) {
      _usuario = Usuario(id: id, username: username);
      _status = AuthStatus.autenticado;
    } else {
      _status = AuthStatus.noAutenticado;
    }
    notifyListeners();
  }

  Future<void> actualizarBaseUrl(String nuevaUrl) async {
    _baseUrl = nuevaUrl;
    await ApiClient.instance.setBaseUrl(nuevaUrl);
    notifyListeners();
  }

  Future<bool> login({required String username, required String password}) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _authService.login(username: username, password: password);
      await SessionStorage.instance.saveSession(
        token: resultado.token,
        usuarioId: resultado.usuario.id,
        username: resultado.usuario.username,
      );
      _usuario = resultado.usuario;
      _status = AuthStatus.autenticado;
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      return false;
    } catch (_) {
      _error = 'No se pudo conectar con el servidor. Verifica la URL de la API.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _limpiarSesionLocal();
    notifyListeners();
  }

  Future<void> _limpiarSesionLocal() async {
    await SessionStorage.instance.clearSession();
    _usuario = null;
    _status = AuthStatus.noAutenticado;
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
