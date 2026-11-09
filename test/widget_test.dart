import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pripack_seller/app/app.dart';
import 'package:pripack_seller/core/network/dio_client.dart';
import 'package:pripack_seller/core/storage/session_storage.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    GetStorage.init();
    Get.put(SessionStorage());
    Get.put(DioClient());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const PripackSellerApp());
    expect(find.text('Pripack Partner Portal'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
