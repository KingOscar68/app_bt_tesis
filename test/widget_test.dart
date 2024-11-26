import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bluetooth_serial_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Cambia MyApp() a BluetoothApp()
    await tester.pumpWidget(MyApp());

    // Verifica que el texto inicial sea "0".
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Simula un toque en el ícono de suma.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica que el contador haya incrementado.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
