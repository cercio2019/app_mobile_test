import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../state/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/module_scaffold.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

/// Pantalla de login. Es la puerta de entrada obligatoria a la app: ningun
/// modulo (clientes, productos, usuarios) es accesible sin pasar por aqui,
/// ya que todos requieren el token JWT que se obtiene al autenticarse.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _ocultarPassword = true;
  bool _mostrarConfigApi = false;
  late final TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _baseUrlController = TextEditingController(text: auth.baseUrl);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    if (_baseUrlController.text.trim().isNotEmpty &&
        _baseUrlController.text.trim() != auth.baseUrl) {
      await auth.actualizarBaseUrl(_baseUrlController.text.trim());
    }

    final ok = await auth.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (auth.error != null) {
      mostrarSnack(context, auth.error!, esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_person_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inicia sesion para continuar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.outline),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      controller: _usernameController,
                      label: 'Usuario',
                      icon: Icons.person_outline,
                      validator: Validators.username,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Contrasena',
                      icon: Icons.lock_outline,
                      obscureText: _ocultarPassword,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        icon: Icon(_ocultarPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _ocultarPassword = !_ocultarPassword),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Ingresar',
                      icon: Icons.login,
                      cargando: auth.cargando,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Crear una cuenta',
                      outlined: true,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _mostrarConfigApi = !_mostrarConfigApi),
                      icon: const Icon(Icons.settings_ethernet, size: 18),
                      label: Text(_mostrarConfigApi
                          ? 'Ocultar configuracion de servidor'
                          : 'Configurar URL del servidor'),
                    ),
                    if (_mostrarConfigApi)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: AppTextField(
                          controller: _baseUrlController,
                          label: 'URL base de la API',
                          icon: Icons.dns_outlined,
                          keyboardType: TextInputType.url,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
