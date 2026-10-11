import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ea_language_hub/widgets/app_logo.dart';

void main() {
  testWidgets('renders the branded logo with accessible semantics', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(child: AppLogo(width: 240)))));
    await tester.pumpAndSettle();
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.bySemanticsLabel('EA Language Hub. Aprenda. Traduza. Comunique.'), findsOneWidget);
  });
}
