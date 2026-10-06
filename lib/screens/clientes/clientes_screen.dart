import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cliente.dart';
import '../../state/cliente_provider.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/module_scaffold.dart';
import 'cliente_form_screen.dart';

/// Listado del modulo Clientes. Consume GET /api/clientes y permite navegar
/// a crear/editar (formulario reutilizable) o eliminar (DELETE).
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClienteProvider>().cargar();
    });
  }

  Future<void> _eliminar(Cliente cliente) async {
    final confirmar = await confirmarAccion(
      context,
      titulo: 'Eliminar cliente',
      mensaje: '¿Eliminar a ${cliente.nombreCompleto}? Esta accion no se puede deshacer.',
    );
    if (!confirmar) return;

    final error = await context.read<ClienteProvider>().eliminar(cliente.id!);
    if (!mounted) return;
    if (error == null) {
      mostrarSnack(context, 'Cliente eliminado');
    } else {
      mostrarSnack(context, error, esError: true);
    }
  }

  Future<void> _abrirFormulario({Cliente? cliente}) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ClienteFormScreen(cliente: cliente)),
    );
    if (guardado == true && mounted) {
      mostrarSnack(context, cliente == null ? 'Cliente creado' : 'Cliente actualizado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();

    Widget body;
    if (provider.cargando && provider.clientes.isEmpty) {
      body = const AppLoading();
    } else if (provider.error != null && provider.clientes.isEmpty) {
      body = AppErrorView(
        mensaje: provider.error!,
        onRetry: () => context.read<ClienteProvider>().cargar(),
      );
    } else if (provider.clientes.isEmpty) {
      body = AppEmptyState(
        mensaje: 'Aun no hay clientes registrados.\nUsa el boton + para crear el primero.',
        icon: Icons.groups_outlined,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => context.read<ClienteProvider>().cargar(),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: provider.clientes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final cliente = provider.clientes[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(cliente.nombre.isNotEmpty ? cliente.nombre[0].toUpperCase() : '?'),
                ),
                title: Text(cliente.nombreCompleto),
                subtitle: Text(
                  'ID: ${cliente.numeroIdentificacion}'
                  '${cliente.telefono != null && cliente.telefono!.isNotEmpty ? ' · Tel: ${cliente.telefono}' : ''}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (accion) {
                    if (accion == 'editar') {
                      _abrirFormulario(cliente: cliente);
                    } else if (accion == 'eliminar') {
                      _eliminar(cliente);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
                onTap: () => _abrirFormulario(cliente: cliente),
              ),
            );
          },
        ),
      );
    }

    return ModuleScaffold(
      title: 'Clientes',
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
