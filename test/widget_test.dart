import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('login screen renders the LOOTSWAP branding', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('LOOTSWAP'), findsAtLeastNWidgets(1));
    expect(find.text('Log In'), findsOneWidget);
  });
}
