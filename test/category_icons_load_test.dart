import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/presentation/discover_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('all category catalog icons load', (WidgetTester tester) async {
    final failures = <String>[];
    for (final entry in DiscoverBloc.categoryCatalog) {
      await tester.pumpWidget(
        MaterialApp(
          home: SvgPicture.asset(entry.iconAsset, width: 24, height: 24),
        ),
      );
      await tester.pump();
      final Object? exception = tester.takeException();
      if (exception != null) {
        failures.add('${entry.name}: ${entry.iconAsset} -> $exception');
      }
    }
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
