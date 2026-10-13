import 'package:fl_clash/widgets/qr_code.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('draws a long share link at the size asked for', (tester) async {
    final link = 'vless://${'a' * 600}@example.com:443?security=tls#node';

    await tester.pumpWidget(Center(child: QrCodeView(data: link, size: 200)));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(QrCodeView)), const Size(200, 200));
  });
}
