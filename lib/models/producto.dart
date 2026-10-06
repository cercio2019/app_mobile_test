/// Modelo de Producto (tabla `productos`), mapea 1:1 con lo que expone
/// /api/productos en api-mobile. El campo [imagen] es la URL publica
/// (`/uploads/productos/<archivo>`) que arma el backend al subir el archivo.
class Producto {
  final int? id;
  final String nombre;
  final String? marca;
  final int stock;
  final double precio;
  final String? imagen;
  final DateTime? creadoEn;

  const Producto({
    this.id,
    required this.nombre,
    this.marca,
    required this.stock,
    required this.precio,
    this.imagen,
    this.creadoEn,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      marca: json['marca'] as String?,
      stock: json['stock'] is String
          ? int.tryParse(json['stock']) ?? 0
          : (json['stock'] as num?)?.toInt() ?? 0,
      precio: json['precio'] is String
          ? double.tryParse(json['precio']) ?? 0
          : (json['precio'] as num?)?.toDouble() ?? 0,
      imagen: json['imagen'] as String?,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'].toString())
          : null,
    );
  }

  Map<String, String> toFormFields() {
    return {
      'nombre': nombre,
      if (marca != null) 'marca': marca!,
      'stock': stock.toString(),
      'precio': precio.toString(),
    };
  }
}
