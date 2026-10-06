import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/producto.dart';
import '../../state/producto_provider.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/module_scaffold.dart';
import 'producto_form_screen.dart';

/// Listado del modulo Productos. Consume GET /api/productos y muestra la
/// imagen (si existe), precio formateado y stock. Permite crear/editar
/// (formulario con subida de imagen) y eliminar.
class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final _formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: r'$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductoProvider>().cargar();
    });
  }

  Future<void> _eliminar(Producto producto) async {
    final confirmar = await confirmarAccion(
      context,
      titulo: 'Eliminar producto',
      mensaje: '¿Eliminar "${producto.nombre}"? Esta accion no se puede deshacer.',
    );
    if (!confirmar) return;

    final error = await context.read<ProductoProvider>().eliminar(producto.id!);
    if (!mounted) return;
    if (error == null) {
      mostrarSnack(context, 'Producto eliminado');
    } else {
      mostrarSnack(context, error, esError: true);
    }
  }

  Future<void> _abrirFormulario({Producto? producto}) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProductoFormScreen(producto: producto)),
    );
    if (guardado == true && mounted) {
      mostrarSnack(context, producto == null ? 'Producto creado' : 'Producto actualizado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductoProvider>();

    Widget body;
    if (provider.cargando && provider.productos.isEmpty) {
      body = const AppLoading();
    } else if (provider.error != null && provider.productos.isEmpty) {
      body = AppErrorView(
        mensaje: provider.error!,
        onRetry: () => context.read<ProductoProvider>().cargar(),
      );
    } else if (provider.productos.isEmpty) {
      body = AppEmptyState(
        mensaje: 'Aun no hay productos en el catalogo.\nUsa el boton + para crear el primero.',
        icon: Icons.inventory_2_outlined,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => context.read<ProductoProvider>().cargar(),
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.72,
          ),
          itemCount: provider.productos.length,
          itemBuilder: (context, index) {
            final producto = provider.productos[index];
            return _ProductoCard(
              producto: producto,
              formatoMoneda: _formatoMoneda,
              onTap: () => _abrirFormulario(producto: producto),
              onEliminar: () => _eliminar(producto),
            );
          },
        ),
      );
    }

    return ModuleScaffold(
      title: 'Productos',
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final NumberFormat formatoMoneda;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const _ProductoCard({
    required this.producto,
    required this.formatoMoneda,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: producto.imagen != null
                    ? Image.network(
                        producto.imagen!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image_outlined, size: 40),
                      )
                    : const Icon(Icons.inventory_2_outlined, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (producto.marca != null && producto.marca!.isNotEmpty)
                          Text(
                            producto.marca!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        Text(formatoMoneda.format(producto.precio)),
                        Text(
                          'Stock: ${producto.stock}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onEliminar,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
