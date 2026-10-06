import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/usuario.dart';
import '../../state/auth_provider.dart';
import '../../state/usuario_provider.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/module_scaffold.dart';
import '../auth/register_screen.dart';

/// Listado del modulo Usuarios (administracion). Consume GET /api/usuarios,
/// GET /api/usuarios/:id (detalle) y DELETE /api/usuarios/:id. El alta de
/// usuarios reutiliza la misma pantalla de registro (POST /api/usuarios)
/// que se usa desde el login.
class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuarioProvider>().cargar();
    });
  }

  Future<void> _eliminar(Usuario usuario) async {
    final actual = context.read<AuthProvider>().usuario;
    if (actual != null && actual.id == usuario.id) {
      mostrarSnack(context, 'No puedes eliminar tu propio usuario mientras tienes la sesion activa.', esError: true);
      return;
    }

    final confirmar = await confirmarAccion(
      context,
      titulo: 'Eliminar usuario',
      mensaje: '¿Eliminar la cuenta "${usuario.username}"? Esta accion no se puede deshacer.',
    );
    if (!confirmar) return;

    final error = await context.read<UsuarioProvider>().eliminar(usuario.id);
    if (!mounted) return;
    if (error == null) {
      mostrarSnack(context, 'Usuario eliminado');
    } else {
      mostrarSnack(context, error, esError: true);
    }
  }

  Future<void> _abrirRegistro() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (mounted) context.read<UsuarioProvider>().cargar();
  }

  /// Consulta el detalle del usuario directamente en la API
  /// (GET /api/usuarios/:id) y lo muestra en un dialogo.
  Future<void> _verDetalle(Usuario usuario) async {
    final provider = context.read<UsuarioProvider>();
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    final detalle = await provider.obtenerDetalle(usuario.id);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // cierra el spinner

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detalle del usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${detalle?.id ?? usuario.id}'),
            const SizedBox(height: 6),
            Text('Usuario: ${detalle?.username ?? usuario.username}'),
            if (detalle?.creadoEn != null) ...[
              const SizedBox(height: 6),
              Text('Creado: ${_formatoFecha.format(detalle!.creadoEn!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsuarioProvider>();

    Widget body;
    if (provider.cargando && provider.usuarios.isEmpty) {
      body = const AppLoading();
    } else if (provider.error != null && provider.usuarios.isEmpty) {
      body = AppErrorView(
        mensaje: provider.error!,
        onRetry: () => context.read<UsuarioProvider>().cargar(),
      );
    } else if (provider.usuarios.isEmpty) {
      body = AppEmptyState(
        mensaje: 'Aun no hay usuarios registrados.',
        icon: Icons.admin_panel_settings_outlined,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => context.read<UsuarioProvider>().cargar(),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: provider.usuarios.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final usuario = provider.usuarios[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(usuario.username),
                subtitle: usuario.creadoEn != null
                    ? Text('Creado: ${_formatoFecha.format(usuario.creadoEn!)}')
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _eliminar(usuario),
                ),
                onTap: () => _verDetalle(usuario),
              ),
            );
          },
        ),
      );
    }

    return ModuleScaffold(
      title: 'Usuarios',
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirRegistro,
        child: const Icon(Icons.person_add_alt),
      ),
    );
  }
}
