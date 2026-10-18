import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../screens/common/qr_scanner_screen.dart';

class QrScanButton extends StatelessWidget {
  final ValueChanged<String> onScanned;
  final String scannerTitle;

  const QrScanButton({
    super.key,
    required this.onScanned,
    this.scannerTitle = 'Scan QR Code',
  });

  Future<void> _openScanner(BuildContext context) async {
    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => QrScannerScreen(title: scannerTitle)),
    );

    if (!context.mounted) return;

    if (scannedValue != null && scannedValue.trim().isNotEmpty) {
      onScanned(scannedValue.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Scan QR Code',
      icon: const Icon(
        Icons.qr_code_scanner,
        size: 22,
        color: AppColors.primary,
      ),
      onPressed: () => _openScanner(context),
    );
  }
}
