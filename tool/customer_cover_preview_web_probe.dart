import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as enums;
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaterialApp(
      home: _PreviewProbe(),
    ),
  );
}

class _PreviewProbe extends StatefulWidget {
  const _PreviewProbe();

  @override
  State<_PreviewProbe> createState() => _PreviewProbeState();
}

class _PreviewProbeState extends State<_PreviewProbe> {
  String status = 'STARTING';
  int? byteCount;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final client = Client()
          .setEndpoint('https://fra.cloud.appwrite.io/v1')
          .setProject('trace-raffine');

      final storage = Storage(client);

      final bytes = await storage.getFilePreview(
        bucketId: 'design-files',
        fileId: '6a8955e5537f092f3892',
        width: 480,
        height: 480,
        output: enums.ImageFormat.webp,
        quality: 82,
      );

      if (bytes.isEmpty) {
        throw StateError('Appwrite returned empty preview bytes.');
      }

      debugPrint('TR_RUNTIME_SUCCESS');
      debugPrint('TR_RUNTIME_BYTES:${bytes.length}');

      if (!mounted) {
        return;
      }

      setState(() {
        status = 'SUCCESS';
        byteCount = bytes.length;
      });
    } catch (error, stackTrace) {
      debugPrint('TR_RUNTIME_ERROR:$error');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      setState(() {
        status = 'ERROR: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status),
            if (byteCount != null)
              Text('BYTES: $byteCount'),
          ],
        ),
      ),
    );
  }
}
