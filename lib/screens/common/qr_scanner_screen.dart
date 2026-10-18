import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  final String title;

  const QrScannerScreen({super.key, this.title = 'Scan QR Code'});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,

      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
      ),

      body: MobileScanner(
        onDetect: (capture) {
          // Prevent processing the same QR multiple times.
          if (_hasScanned) return;

          for (final barcode in capture.barcodes) {
            final value = barcode.rawValue;

            if (value == null || value.trim().isEmpty) {
              continue;
            }

            _hasScanned = true;

            // Return scanned QR value to the previous screen.
            Navigator.pop(context, value);
            break;
          }
        },
      ),
    );
  }
}
