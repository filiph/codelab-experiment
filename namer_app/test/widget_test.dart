import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:namer_app/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Next'), findsOneWidget);
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

  testWidgets('Tapping "Like" changes icon', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    Finder findElevatedButtonByIcon(IconData icon) {
      return find.descendant(
        of: find.bySubtype<ElevatedButton>(),
        matching: find.byIcon(icon),
      );
    }

    // At start: an outlined heart icon.
    expect(findElevatedButtonByIcon(Icons.favorite_border), findsOneWidget);
    expect(findElevatedButtonByIcon(Icons.favorite), findsNothing);

    await tester.tap(find.text('Like'));
    await tester.pumpAndSettle();

    // After tap: a full heart icon.
    expect(findElevatedButtonByIcon(Icons.favorite_border), findsNothing);
    expect(findElevatedButtonByIcon(Icons.favorite), findsOneWidget);
  });
}
