/// Validadores reutilizables para los `TextFormField` de todos los
/// formularios de la app (login, registro, clientes, productos).
class Validators {
  Validators._();

  static String? requerido(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es obligatorio';
    }
    return null;
  }

  static String? username(String? valor) {
    final requeridoError = requerido(valor, campo: 'El usuario');
    if (requeridoError != null) return requeridoError;
    if (valor!.trim().length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? password(String? valor) {
    final requeridoError = requerido(valor, campo: 'La contrasena');
    if (requeridoError != null) return requeridoError;
    if (valor!.length < 6) {
      return 'La contrasena debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? numeroPositivo(String? valor, {String campo = 'El valor'}) {
    final requeridoError = requerido(valor, campo: campo);
    if (requeridoError != null) return requeridoError;
    final numero = num.tryParse(valor!.replaceAll(',', '.'));
    if (numero == null || numero < 0) {
      return '$campo debe ser un numero valido';
    }
    return null;
  }

  static String? enteroPositivo(String? valor, {String campo = 'El valor'}) {
    final requeridoError = requerido(valor, campo: campo);
    if (requeridoError != null) return requeridoError;
    final numero = int.tryParse(valor!.trim());
    if (numero == null || numero < 0) {
      return '$campo debe ser un numero entero valido';
    }
    return null;
  }
}
