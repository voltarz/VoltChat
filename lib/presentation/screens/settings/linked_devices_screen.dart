import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/di/locator.dart';
import '../../../domain/models/linked_device.dart';
import 'package:intl/intl.dart';

class LinkedDevicesScreen extends StatefulWidget {
  const LinkedDevicesScreen({super.key});

  @override
  State<LinkedDevicesScreen> createState() => _LinkedDevicesScreenState();
}

class _LinkedDevicesScreenState extends State<LinkedDevicesScreen> {
  bool _isLoading = true;
  List<LinkedDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      final devices = await locator.deviceLinkRepository.getLinkedDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load devices: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeDevice(String id) async {
    try {
      await locator.deviceLinkRepository.removeLinkedDevice(id);
      await _loadDevices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove device: $e')),
      );
    }
  }

  void _showRemoveConfirmation(LinkedDevice device) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove device?'),
        content: Text('Are you sure you want to remove ${device.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _removeDevice(device.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linked Devices')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_link),
                    label: const Text('Link a Device'),
                    onPressed: () async {
                      await Navigator.of(context).pushNamed(AppRouter.qrScanner);
                      // Reload devices when returning in case a new device was linked
                      _loadDevices();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: _devices.isEmpty
                      ? const Center(child: Text('No devices linked.'))
                      : ListView.builder(
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            return ListTile(
                              leading: Icon(
                                device.platform.toLowerCase().contains('windows') || device.platform.toLowerCase().contains('mac') || device.platform.toLowerCase().contains('linux') || device.platform.toLowerCase().contains('web')
                                    ? Icons.computer
                                    : Icons.phone_android,
                              ),
                              title: Text(device.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(device.platform),
                                  Text('Active: ${DateFormat.yMMMd().add_jm().format(device.lastActive)}'),
                                  if (device.isCurrentDevice)
                                    const Text('This device', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: device.isCurrentDevice
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.logout, color: Colors.red),
                                      onPressed: () => _showRemoveConfirmation(device),
                                    ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
