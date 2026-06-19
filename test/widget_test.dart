import 'package:flutter_test/flutter_test.dart';
import 'package:tourismapp/main.dart';

void main() {
  testWidgets('QuestMY app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuestMYApp());

    expect(find.text('QuestMY'), findsWidgets);
  });
}
