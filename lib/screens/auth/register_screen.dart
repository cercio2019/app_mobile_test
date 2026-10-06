import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../state/usuario_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/module_scaffold.dart';

/// Pantalla de registro de un nuevo usuario. Consume POST /api/usuarios,
/// que en el backend es el unico endpoint publico ademas del login (permite
/// crear el primer usuario del sistema).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    final provider = context.read<UsuarioProvider>();
    final error = await provider.registrar(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    if (error == null) {
      mostrarSnack(context, 'Usuario creado correctamente. Ahora puedes iniciar sesion.');
      Navigator.of(context).pop();
    } else {
      mostrarSnack(context, error, esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      obscureText: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _confirmarController,
                      label: 'Confirmar contrasena',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (valor) {
                        if (valor != _passwordController.text) {
                          return 'Las contrasenas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Registrarme',
                      icon: Icons.person_add_alt,
                      cargando: _cargando,
                      onPressed: _submit,
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
