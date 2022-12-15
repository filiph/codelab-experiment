import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:namer_app/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('A random idea:'), findsOneWidget);
  });

  testWidgets('Tapping button changes word pair', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final wordPairWidget = find.byType(BigCard);
    expect(wordPairWidget, findsOneWidget);

    String? findWordPair() {
      final wordPairTextWidget = tester.widget<Text>(find.descendant(
        of: find.byType(BigCard),
        matching: find.byType(Text),
      ));
      return wordPairTextWidget.data;
    }

    final firstPair = findWordPair();

    // Sanity check. Finding the word pair twice will have the same result.
    final firstPairDuplicate = findWordPair();
    expect(firstPair, equals(firstPairDuplicate));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    final nextPair = findWordPair();

    expect(nextPair, isNot(firstPair));
  });
}
