import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokalny_koszyk/widgets/common/segmented_toggle.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('calls onChanged when another option is tapped', (
    WidgetTester tester,
  ) async {
    var selected = 'pickup';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SegmentedToggle<String>(
                value: selected,
                onChanged: (String value) => setState(() => selected = value),
                options: const <SegmentedToggleOption<String>>[
                  SegmentedToggleOption<String>(
                    value: 'pickup',
                    label: 'Odbiór',
                  ),
                  SegmentedToggleOption<String>(
                    value: 'delivery',
                    label: 'Dostawa',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Odbiór'), findsOneWidget);
    expect(find.text('Dostawa'), findsOneWidget);

    await tester.tap(find.text('Dostawa'));
    await tester.pump();
    expect(selected, 'delivery');
  });
}
