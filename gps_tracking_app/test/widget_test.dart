import 'package:flutter_test/flutter_test.dart';
import 'package:gps_tracking_app/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GPSTrackingApp());
  });
}