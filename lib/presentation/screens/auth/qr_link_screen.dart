import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/di/locator.dart';
import '../../../domain/models/device_pairing_challenge.dart';

class QrLinkScreen extends StatefulWidget {
  const QrLinkScreen({super.key});

  @override
  State<QrLinkScreen> createState() => _QrLinkScreenState();
}

class _QrLinkScreenState extends State<QrLinkScreen> {
  bool _isLoading = true;
  DevicePairingChallenge? _challenge;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateChallenge();
  }

  Future<void> _generateChallenge() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final challenge = await locator.deviceLinkRepository.createPairingChallenge();
      if (!mounted) return;
      setState(() {
        _challenge = challenge;
      });
      // In a real app we'd poll or use websockets to listen for pairing completion
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to generate challenge: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link with Phone')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Use VoltChat on your phone to link this device',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Open VoltChat on your phone\n'
                '2. Go to Settings > Linked Devices > Link a Device\n'
                '3. Scan the QR code below',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_error != null)
                Column(
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generateChallenge,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else if (_challenge != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: _challenge!.id,
                    version: QrVersions.auto,
                    size: 250.0,
                  ),
                ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
