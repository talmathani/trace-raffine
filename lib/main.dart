import 'package:flutter/material.dart';

import 'app.dart';
import 'core/appwrite/appwrite_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppwriteService.initialize();

  runApp(const TRApp());
}
