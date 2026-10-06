import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/validators.dart';
import '../../models/producto.dart';
import '../../state/producto_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/module_scaffold.dart';

/// Formulario reutilizado tanto para crear (POST multipart) como para editar
/// (PUT multipart) un producto, incluyendo seleccion opcional de imagen.
class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _marcaController;
  late final TextEditingController _stockController;
  late final TextEditingController _precioController;
  bool _guardando = false;

  Uint8List? _imagenBytes;
  String? _imagenNombre;
  String? _imagenUrlActual;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _marcaController = TextEditingController(text: p?.marca ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '0');
    _precioController = TextEditingController(text: p?.precio.toString() ?? '');
    _imagenUrlActual = p?.imagen;

    if (_esEdicion) {
      // Trae la version mas reciente del producto (GET /api/productos/:id)
      // en vez de confiar unicamente en la copia local del listado.
      context.read<ProductoProvider>().obtenerDetalle(widget.producto!.id!).then((fresco) {
        if (fresco != null && mounted) {
          setState(() {
            _nombreController.text = fresco.nombre;
            _marcaController.text = fresco.marca ?? '';
            _stockController.text = fresco.stock.toString();
            _precioController.text = fresco.precio.toString();
            _imagenUrlActual = fresco.imagen;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _stockController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final XFile? archivo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    setState(() {
      _imagenBytes = bytes;
      _imagenNombre = archivo.name;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final provider = context.read<ProductoProvider>();
    final producto = Producto(
      id: widget.producto?.id,
      nombre: _nombreController.text.trim(),
      marca: _marcaController.text.trim().isEmpty ? null : _marcaController.text.trim(),
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      precio: double.tryParse(_precioController.text.trim().replaceAll(',', '.')) ?? 0,
    );

    final imagen = _imagenBytes != null
        ? ApiFile(
            fieldName: 'imagen',
            filename: _imagenNombre ?? 'imagen.jpg',
            bytes: _imagenBytes!,
          )
        : null;

    final error = _esEdicion
        ? await provider.actualizar(widget.producto!.id!, producto, imagen: imagen)
        : await provider.crear(producto, imagen: imagen);

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
      appBar: AppBar(title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _seleccionarImagen,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imagenBytes != null
                        ? Image.memory(_imagenBytes!, fit: BoxFit.cover)
                        : (_imagenUrlActual != null
                            ? Image.network(_imagenUrlActual!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined, size: 36),
                                  SizedBox(height: 8),
                                  Text('Toca para elegir una imagen (opcional)'),
                                ],
                              )),
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _nombreController,
                  label: 'Nombre',
                  icon: Icons.label_outline,
                  validator: (v) => Validators.requerido(v, campo: 'El nombre'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _marcaController,
                  label: 'Marca (opcional)',
                  icon: Icons.branding_watermark_outlined,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _stockController,
                        label: 'Stock',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.enteroPositivo(v, campo: 'El stock'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _precioController,
                        label: 'Precio',
                        icon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => Validators.numeroPositivo(v, campo: 'El precio'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: _esEdicion ? 'Guardar cambios' : 'Crear producto',
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
