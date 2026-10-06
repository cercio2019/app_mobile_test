/// Modelo del usuario del sistema (tabla `usuarios`). Se usa tanto para el
/// usuario autenticado (devuelto por /api/auth/login) como para el listado
/// administrativo (/api/usuarios).
class Usuario {
  final int id;
  final String username;
  final DateTime? creadoEn;

  const Usuario({
    required this.id,
    required this.username,
    this.creadoEn,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      username: json['username'] as String,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'].toString())
          : null,
    );
  }
}
