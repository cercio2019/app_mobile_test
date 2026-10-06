import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Constantes globales de la aplicacion: URL base de la API y llaves de
/// almacenamiento. Centralizar esto aqui permite que todos los modulos
/// (auth, clientes, productos, usuarios) compartan la misma configuracion.
class AppConstants {
  AppConstants._();

  /// Nombre de la app, usado en el titulo del MaterialApp y en el login.
  static const String appName = 'App Mobile Test';

  /// URL base por defecto de la API segun la plataforma donde corre la app.
  ///
  /// - Web / Windows / macOS / Linux (desktop): la API corre en la misma
  ///   maquina, por lo que "localhost" funciona directamente.
  /// - Emulador de Android: "localhost" del emulador NO es el host, hay que
  ///   usar la IP especial 10.0.2.2 que Android redirige al host.
  /// - iOS (simulador): "localhost" si funciona porque comparte red con el host.
  ///
  /// Esta URL se puede sobrescribir desde la pantalla de login (se guarda en
  /// almacenamiento seguro), asi que este valor es solo el punto de partida.
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {
      // Platform no esta disponible (por ejemplo en tests) -> usar default.
    }
    return 'http://localhost:3000';
  }

  static const String apiAuthLogin = '/api/auth/login';
  static const String apiUsuarios = '/api/usuarios';
  static const String apiClientes = '/api/clientes';
  static const String apiProductos = '/api/productos';

  // Llaves usadas en flutter_secure_storage.
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUsuarioId = 'auth_usuario_id';
  static const String storageKeyUsuarioUsername = 'auth_usuario_username';
  static const String storageKeyBaseUrl = 'api_base_url';

  static const Duration requestTimeout = Duration(seconds: 15);
}
