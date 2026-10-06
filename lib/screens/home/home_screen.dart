import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../widgets/module_menu_card.dart';
import '../../widgets/module_scaffold.dart';
import '../clientes/clientes_screen.dart';
import '../productos/productos_screen.dart';
import '../usuarios/usuarios_screen.dart';

/// Pantalla principal despues del login. Funciona como menu hacia los tres
/// modulos que consumen la API (clientes, productos y usuarios), todos
/// protegidos por la sesion activa.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return ModuleScaffold(
      title: 'Inicio',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(Icons.person,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sesion activa'),
                        Text(
                          auth.usuario?.username ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Modulos disponibles', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ModuleMenuCard(
            title: 'Clientes',
            subtitle: 'Crear, listar, editar y eliminar clientes',
            icon: Icons.groups_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClientesScreen()),
            ),
          ),
          const SizedBox(height: 12),
          ModuleMenuCard(
            title: 'Productos',
            subtitle: 'Catalogo con imagenes, stock y precio',
            icon: Icons.inventory_2_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductosScreen()),
            ),
          ),
          const SizedBox(height: 12),
          ModuleMenuCard(
            title: 'Usuarios',
            subtitle: 'Administracion de cuentas del sistema',
            icon: Icons.admin_panel_settings_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UsuariosScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
