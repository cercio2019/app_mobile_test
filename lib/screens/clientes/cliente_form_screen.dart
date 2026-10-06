import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../models/cliente.dart';
import '../../state/cliente_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/module_scaffold.dart';

/// Formulario reutilizado tanto para crear (POST) como para editar (PUT) un
/// cliente. Si [cliente] es null se asume creacion.
class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormScreen({super.key, this.cliente});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _identificacionController;
  late final TextEditingController _telefonoController;
  bool _guardando = false;

  bool get _esEdicion => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nombreController = TextEditingController(text: c?.nombre ?? '');
    _apellidoController = TextEditingController(text: c?.apellido ?? '');
    _identificacionController =
        TextEditingController(text: c?.numeroIdentificacion ?? '');
    _telefonoController = TextEditingController(text: c?.telefono ?? '');

    if (_esEdicion) {
      // Trae la version mas reciente del cliente (GET /api/clientes/:id) en
      // vez de confiar unicamente en la copia local del listado.
      context.read<ClienteProvider>().obtenerDetalle(widget.cliente!.id!).then((fresco) {
        if (fresco != null && mounted) {
          setState(() {
            _nombreController.text = fresco.nombre;
            _apellidoController.text = fresco.apellido;
            _identificacionController.text = fresco.numeroIdentificacion;
            _telefonoController.text = fresco.telefono ?? '';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _identificacionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final provider = context.read<ClienteProvider>();
    final cliente = Cliente(
      id: widget.cliente?.id,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      numeroIdentificacion: _identificacionController.text.trim(),
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
    );

    final error = _esEdicion
        ? await provider.actualizar(widget.cliente!.id!, cliente)
        : await provider.crear(cliente);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      mostrarSnack(context, error, esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar cliente' : 'Nuevo cliente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nombreController,
                  label: 'Nombre',
                  icon: Icons.badge_outlined,
                  validator: (v) => Validators.requerido(v, campo: 'El nombre'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _apellidoController,
                  label: 'Apellido',
                  icon: Icons.badge_outlined,
                  validator: (v) => Validators.requerido(v, campo: 'El apellido'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _identificacionController,
                  label: 'Numero de identificacion',
                  icon: Icons.badge,
                  validator: (v) =>
                      Validators.requerido(v, campo: 'La identificacion'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _telefonoController,
                  label: 'Telefono (opcional)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: _esEdicion ? 'Guardar cambios' : 'Crear cliente',
                  icon: Icons.save_outlined,
                  cargando: _guardando,
                  onPressed: _guardar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
