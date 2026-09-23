import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/di/locator.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  final TextEditingController _mockInputController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _mockInputController.dispose();
    super.dispose();
  }

  Future<void> _handleScanResult(String? result) async {
    if (result == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    // Stop scanning while we process
    _controller.stop();

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Link this device?'),
        content: const Text('Do you want to link the device that generated this QR code?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Link Device'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      try {
        final success = await locator.deviceLinkRepository.validateAndPairDevice(
          result,
          'VoltChat Desktop', // In a real app, payload would contain device info or backend lookup
          'Windows',
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device linked successfully!')),
          );
          Navigator.of(context).pop(); // Go back to linked devices
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to link device. QR code may be expired or invalid.')),
          );
          // Resume scanning on failure
          _controller.start();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        _controller.start();
      }
    } else {
      if (!mounted) return;
      // Invalidate if cancelled as per requirements
      try {
        await locator.deviceLinkRepository.invalidateChallenge(result);
      } catch (_) {}

      _controller.start();
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  bool _isDesktopOrWeb() {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktopOrWeb()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan QR Code')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Camera not supported on this platform.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                const Text('Enter mock pairing challenge ID to simulate scanning:'),
                const SizedBox(height: 16),
                TextField(
                  controller: _mockInputController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Challenge ID',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _handleScanResult(_mockInputController.text.trim()),
                  child: const Text('Simulate Scan'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                  case TorchState.auto:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                  case CameraFacing.unknown:
                  case CameraFacing.external:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _handleScanResult(barcodes.first.rawValue);
              }
            },
          ),
          // A simple scanner overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
