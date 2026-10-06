/// Excepcion generica usada por toda la capa de servicios para representar
/// errores devueltos por la API (o de red) de forma uniforme.
///
/// El backend (api-mobile) siempre responde los errores con la forma
/// `{ "mensaje": "..." }`, asi que esta excepcion normaliza ese mensaje para
/// que las pantallas puedan mostrarlo directamente.
class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;

  const ApiException(this.mensaje, {this.statusCode});

  /// True cuando el backend respondio 401 (token invalido/expirado o falta).
  /// Los providers usan esto para forzar el logout automatico.
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => mensaje;
}
