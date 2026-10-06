/// Modelo de Cliente (tabla `clientes`), mapea 1:1 con lo que expone
/// /api/clientes en api-mobile.
class Cliente {
  final int? id;
  final String nombre;
  final String apellido;
  final String numeroIdentificacion;
  final String? telefono;
  final DateTime? creadoEn;

  const Cliente({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.numeroIdentificacion,
    this.telefono,
    this.creadoEn,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      numeroIdentificacion: json['numero_identificacion'] as String? ?? '',
      telefono: json['telefono'] as String?,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'numero_identificacion': numeroIdentificacion,
      'telefono': telefono,
    };
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? numeroIdentificacion,
    String? telefono,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      numeroIdentificacion: numeroIdentificacion ?? this.numeroIdentificacion,
      telefono: telefono ?? this.telefono,
      creadoEn: creadoEn,
    );
  }
}
