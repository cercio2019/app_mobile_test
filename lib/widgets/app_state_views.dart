import 'package:flutter/material.dart';

/// Indicador de carga centrado, usado como placeholder mientras cualquier
/// provider esta cargando datos.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Vista de error generica con boton de reintentar. Reutilizada por todos
/// los modulos (clientes, productos, usuarios) cuando falla la carga.
class AppErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.mensaje, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado vacio generico (sin resultados), reutilizado por los listados de
/// clientes, productos y usuarios.
class AppEmptyState extends StatelessWidget {
  final String mensaje;
  final IconData icon;

  const AppEmptyState({super.key, required this.mensaje, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
