import 'package:flutter/material.dart';

/// Boton principal reutilizable con estado de carga integrado: cuando
/// [cargando] es true, se deshabilita y muestra un spinner en vez del texto.
/// Usado en login, registro y todos los formularios de guardar/eliminar.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icon;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.cargando = false,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = cargando
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    if (outlined) {
      return OutlinedButton(
        onPressed: cargando ? null : onPressed,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: cargando ? null : onPressed,
      child: child,
    );
  }
}
