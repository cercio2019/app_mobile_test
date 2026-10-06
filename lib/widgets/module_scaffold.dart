import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart';

/// Scaffold comun para todas las pantallas "de modulo" (clientes, productos,
/// usuarios): mismo AppBar, mismo boton flotante opcional y el mismo boton
/// de "cerrar sesion". Evita repetir este boilerplate en cada pantalla y
/// garantiza que cualquier modulo pueda cerrar sesion desde cualquier lugar.
class ModuleScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ModuleScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...?actions,
          IconButton(
            tooltip: 'Cerrar sesion',
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
  }
}

/// Helper para mostrar mensajes de error/exito de forma consistente en toda
/// la app.
void mostrarSnack(BuildContext context, String mensaje, {bool esError = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: esError ? Theme.of(context).colorScheme.error : null,
    ),
  );
}
