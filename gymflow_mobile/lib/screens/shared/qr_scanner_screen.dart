import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _flashOn = false;
  bool _cameraReady = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue == null) continue;

      setState(() => _isProcessing = true);

      try {
        final result = await _api.checkIn('', method: 'qr');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(result['message'] ?? 'Checked in successfully!'),
                ],
              ),
              backgroundColor: GymFlowColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: GymFlowColors.error,
            ),
          );
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _manualCheckIn() async {
    setState(() => _isProcessing = true);
    try {
      final result = await _api.checkIn('', method: 'manual');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Checked in!'),
            backgroundColor: GymFlowColors.success,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: GymFlowColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final gymName = authState.selectedGymName ?? 'Gym';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR to Check In'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() => _flashOn = !_flashOn);
              _scannerController?.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController!,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return Container(
                color: GymFlowColors.background,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: GymFlowColors.error),
                      const SizedBox(height: 16),
                      Text('Camera error', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _manualCheckIn, child: const Text('Use Manual Check-in')),
                    ],
                  ),
                ),
              );
            },
          ),
          // Scanner overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
          // Scanning frame
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: GymFlowColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner,
                            size: 64, color: GymFlowColors.primary.withOpacity(0.4)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Point camera at the QR code at $gymName entrance',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GymFlowColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  const Text('OR', style: TextStyle(color: GymFlowColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _manualCheckIn,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.touch_app),
                      label: Text(_isProcessing ? 'Checking in...' : 'Manual Check In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: GymFlowColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
