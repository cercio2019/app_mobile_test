import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'state/auth_provider.dart';
import 'state/cliente_provider.dart';
import 'state/producto_provider.dart';
import 'state/usuario_provider.dart';
import 'widgets/app_state_views.dart';

void main() {
  runApp(const AppMobileTest());
}

/// Raiz de la aplicacion. Declara todos los providers de estado una sola vez
/// (auth + los 3 modulos) para que cualquier pantalla pueda consumirlos sin
/// tener que crearlos de nuevo, y define el tema global.
class AppMobileTest extends StatelessWidget {
  const AppMobileTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..restaurarSesion()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

/// Punto de entrada que decide, segun el estado de [AuthProvider], si se
/// muestra el login o la app autenticada (Home). Es la pieza que garantiza
/// que ningun modulo sea alcanzable sin haber iniciado sesion: mientras no
/// haya sesion valida, siempre se renderiza [LoginScreen].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.desconocido:
        return const Scaffold(body: AppLoading());
      case AuthStatus.autenticado:
        return const HomeScreen();
      case AuthStatus.noAutenticado:
        return const LoginScreen();
    }
  }
}
