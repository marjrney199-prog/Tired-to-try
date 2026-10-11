import 'package:ea_language_hub/widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SurfaceCard displays its child in a responsive container', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SurfaceCard(child: Text('Conteúdo local')))));
    expect(find.text('Conteúdo local'), findsOneWidget);
  });
}
