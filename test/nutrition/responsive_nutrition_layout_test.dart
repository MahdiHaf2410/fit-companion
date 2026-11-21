import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_companion/core/widgets/macro_progress_bar.dart';

void main() {
  testWidgets('MacroProgressBar compact layout does not overflow in 95px width', (tester) async {
    // Test on constrained width (3-column on narrow screen: ~95-100dp)
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: const [
              SizedBox(
                width: 95,
                child: MacroProgressBar(
                  label: 'Carbohydrates',
                  current: 245.5,
                  target: 300.0,
                  unit: 'g',
                  color: Colors.orange,
                  isCompact: true,
                ),
              ),
              SizedBox(
                width: 95,
                child: MacroProgressBar(
                  label: 'كربوهيدرات',
                  current: 180.0,
                  target: 220.0,
                  unit: 'غ',
                  color: Colors.amber,
                  isCompact: true,
                ),
              ),
              SizedBox(
                width: 95,
                child: MacroProgressBar(
                  label: 'Protein',
                  current: 160.0,
                  target: 180.0,
                  unit: 'g',
                  color: Colors.blue,
                  isCompact: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify no RenderFlex overflow exception occurred
    expect(tester.takeException(), isNull);
    expect(find.text('Carbohydrates'), findsOneWidget);
    expect(find.text('كربوهيدرات'), findsOneWidget);
  });
}
