import 'package:ea_language_hub/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('abre a aplicação local sem ecrã de carregamento infinito', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.bySemanticsLabel('EA Language Hub. Aprenda. Traduza. Comunique.'), findsWidgets);
  });
}
