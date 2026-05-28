import 'package:flutter_test/flutter_test.dart';

import 'package:deeproots/main.dart';

void main() {
  testWidgets('Renders feed screen with title and first post', (tester) async {
    await tester.pumpWidget(const DeeprootsApp());
    await tester.pump();

    expect(find.text('Deeproots'), findsOneWidget);
    expect(find.text('Fresh Clay Tacos'), findsOneWidget);
    expect(find.text('Ranil'), findsOneWidget);
  });
}
