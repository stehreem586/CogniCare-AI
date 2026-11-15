import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/adaptive_therapy/adaptive_therapy_module.dart';

void main() {
  testWidgets('therapy frame adapts between phone, tablet, and desktop widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpAt(Size size) async {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size),
          child: const TherapyPhoneFrame(
            child: SizedBox.expand(key: ValueKey('therapy-content')),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpAt(const Size(390, 844));
    expect(find.byKey(const ValueKey('therapy-responsive-frame')), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('therapy-content'))).width, 390);
    expect(tester.getSize(find.byKey(const ValueKey('therapy-content'))).height, 844);

    await pumpAt(const Size(768, 1024));
    expect(tester.getSize(find.byKey(const ValueKey('therapy-responsive-frame'))).width, 768);
    expect(tester.getSize(find.byKey(const ValueKey('therapy-responsive-frame'))).height, 1024);

    await pumpAt(const Size(1440, 1000));
    expect(tester.getSize(find.byKey(const ValueKey('therapy-responsive-frame'))).width, 1440);
    expect(tester.getSize(find.byKey(const ValueKey('therapy-responsive-frame'))).height, 1000);

    await pumpAt(const Size(2560, 1440));
    expect(tester.getSize(find.byKey(const ValueKey('therapy-responsive-frame'))).width, 2560);
    expect(tester.getSize(find.byKey(const ValueKey('therapy-responsive-frame'))).height, 1440);
  });
}
