import 'package:alegre_mobile/main.dart';
import 'package:alegre_mobile/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:alegre_mobile/providers/theme_provider.dart';

void main() {
  testWidgets('app builds and shows the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const AlegreAdvMobProg(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
