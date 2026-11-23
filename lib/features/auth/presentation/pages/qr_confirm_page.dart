import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../providers/auth_provider.dart';

/// 桌面扫码登录的手机确认页：扫描桌面二维码 → 解析票据 → 调用 confirm。
/// 二维码内容形如 https://站点/app/qr/<票据>；也兼容直接编码票据的旧版。
class QrConfirmPage extends ConsumerStatefulWidget {
  const QrConfirmPage({super.key});

  @override
  ConsumerState<QrConfirmPage> createState() => _QrConfirmPageState();
}

class _QrConfirmPageState extends ConsumerState<QrConfirmPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 从扫码结果中提取票据：取 URL 最后一段；裸票据原样返回。
  String? _ticketFrom(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return value;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    final ticket = _ticketFrom(raw);
    if (ticket == null || ticket.isEmpty) return;

    _handled = true;
    await _controller.stop();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认桌面登录'),
        content: const Text('是否允许该设备登录你的账号？票据将在 5 分钟后失效。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认登录'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).confirmQrLogin(ticket);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已确认，桌面端即将登录')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _handled = false;
        _error = '确认失败：二维码无效或已过期';
      });
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码确认登录')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('将手机摄像头对准桌面端显示的二维码'),
          ),
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
