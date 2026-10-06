// Smoke test: verifica que la app arranca y, sin sesion guardada, muestra
// la pantalla de login (que es la puerta de entrada obligatoria a la app).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_mobile_test/main.dart';

void main() {
  // flutter_secure_storage usa un MethodChannel nativo que no existe en el
  // entorno de test; se simula para que AuthProvider.restaurarSesion()
  // resuelva "sin sesion guardada" en vez de lanzar una excepcion.
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'readAll':
          return <String, String>{};
        case 'read':
          return null;
        default:
          return null;
      }
    });
  });

  testWidgets('Sin sesion guardada, la app muestra el login', (tester) async {
    await tester.pumpWidget(const AppMobileTest());
    await tester.pumpAndSettle();

    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Crear una cuenta'), findsOneWidget);
  });
}
