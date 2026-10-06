import 'package:flutter/material.dart';

/// Dialogo de confirmacion reutilizable para toda accion destructiva
/// (eliminar cliente, producto o usuario). Devuelve `true` si el usuario
/// confirmo.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoConfirmar = 'Eliminar',
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
