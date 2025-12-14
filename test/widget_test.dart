import 'package:flutter_test/flutter_test.dart';
import 'package:poker_game/main.dart';

void main() {
  testWidgets('Poker app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PokerApp());
    expect(find.text('Texas Hold\'em'), findsOneWidget);
  });
}
