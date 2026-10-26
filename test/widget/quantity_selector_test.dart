import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokalny_koszyk/widgets/common/quantity_selector.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows quantity and invokes callbacks', (WidgetTester tester) async {
    var quantity = 2;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return QuantitySelector(
                quantity: quantity,
                onIncrease: () => setState(() => quantity++),
                onDecrease: () => setState(() => quantity--),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('disables decrease at minQuantity', (WidgetTester tester) async {
    var decreased = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantitySelector(
            quantity: 1,
            minQuantity: 1,
            onIncrease: () {},
            onDecrease: () => decreased = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(decreased, isFalse);
  });
}
