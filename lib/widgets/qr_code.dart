import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';

/// [data] as a QR code: dark modules on white with the quiet zone scanners
/// need around them, whatever the theme.
class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key, required this.data, this.size = 240});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(
      QrCode(
        payload: QrPayload.fromString(data),
        errorCorrectLevel: QrErrorCorrectLevel.low,
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _QrPainter(image)),
    );
  }
}

/// Modules of white border on each side, as the QR standard asks.
const _quietZone = 4;

class _QrPainter extends CustomPainter {
  const _QrPainter(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final count = image.moduleCount;
    final module = size.shortestSide / (count + _quietZone * 2);
    final dark = Paint()
      ..color = Colors.black
      ..isAntiAlias = false;
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (image.isDark(row, col)) {
          canvas.drawRect(
            Rect.fromLTWH(
              (col + _quietZone) * module,
              (row + _quietZone) * module,
              module,
              module,
            ),
            dark,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.image != image;
}
