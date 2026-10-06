import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../storage/session_storage.dart';
import 'api_exception.dart';

/// Un archivo generico a subir en un request multipart. Se modela asi (en vez
/// de usar `dart:io File` directamente) para que el mismo codigo funcione en
/// Flutter Web, donde no existe sistema de archivos: solo se necesitan los
/// bytes, el nombre y el campo del formulario.
class ApiFile {
  final String fieldName;
  final String filename;
  final List<int> bytes;

  const ApiFile({
    required this.fieldName,
    required this.filename,
    required this.bytes,
  });
}

/// Cliente HTTP unico y reutilizable para toda la app.
///
/// Responsabilidades centralizadas aqui para que ningun servicio tenga que
/// repetirlas:
///  - Resolver la URL base configurada (persistida en [SessionStorage]).
///  - Adjuntar automaticamente el header `Authorization: Bearer <token>` en
///    cada request cuando exista una sesion activa.
///  - Decodificar JSON y traducir respuestas de error (`{ "mensaje": "" }`)
///    en [ApiException].
///  - Notificar (via [onUnauthorized]) cuando el backend responde 401, para
///    que la app pueda cerrar la sesion automaticamente.
class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  final http.Client _http = http.Client();
  String? _cachedBaseUrl;

  /// Callback opcional que se dispara cuando cualquier request recibe 401.
  /// [AuthProvider] se suscribe a esto para forzar el logout global.
  void Function()? onUnauthorized;

  Future<String> get _baseUrl async {
    return _cachedBaseUrl ??= await SessionStorage.instance.readBaseUrl();
  }

  /// Permite cambiar la URL base en caliente (por ejemplo desde la pantalla
  /// de login, si el usuario quiere apuntar a otro servidor) y la persiste.
  Future<void> setBaseUrl(String baseUrl) async {
    _cachedBaseUrl = baseUrl;
    await SessionStorage.instance.saveBaseUrl(baseUrl);
  }

  Future<Uri> _uri(String path, [Map<String, String>? query]) async {
    final base = await _baseUrl;
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await SessionStorage.instance.readToken();
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await _http
        .get(await _uri(path, query), headers: await _headers())
        .timeout(AppConstants.requestTimeout);
    return _procesarRespuesta(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await _http
        .post(
          await _uri(path),
          headers: await _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(AppConstants.requestTimeout);
    return _procesarRespuesta(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await _http
        .put(
          await _uri(path),
          headers: await _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(AppConstants.requestTimeout);
    return _procesarRespuesta(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await _http
        .delete(await _uri(path), headers: await _headers())
        .timeout(AppConstants.requestTimeout);
    return _procesarRespuesta(res);
  }

  /// POST/PUT multipart (form-data). Usado por el modulo de productos para
  /// enviar los campos junto con el archivo de imagen (campo "imagen").
  Future<dynamic> multipart(
    String path, {
    required String method, // 'POST' o 'PUT'
    Map<String, String> fields = const {},
    ApiFile? file,
  }) async {
    final request = http.MultipartRequest(method, await _uri(path));
    request.headers.addAll(await _headers(json: false));
    request.fields.addAll(fields);

    if (file != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          file.fieldName,
          file.bytes,
          filename: file.filename,
        ),
      );
    }

    final streamed = await _http.send(request).timeout(AppConstants.requestTimeout);
    final res = await http.Response.fromStream(streamed);
    return _procesarRespuesta(res);
  }

  dynamic _procesarRespuesta(http.Response res) {
    final bodyText = res.body.isEmpty ? null : res.body;
    dynamic decoded;
    if (bodyText != null) {
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        decoded = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    if (res.statusCode == 401) {
      onUnauthorized?.call();
    }

    final mensaje = (decoded is Map && decoded['mensaje'] != null)
        ? decoded['mensaje'].toString()
        : 'Error de red (${res.statusCode})';

    throw ApiException(mensaje, statusCode: res.statusCode);
  }
}
