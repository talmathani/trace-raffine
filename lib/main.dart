import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/appwrite/appwrite_service.dart';
import 'core/deep_link/app_deep_link_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppwriteService.initialize();

  // Render Flutter immediately. Deep-link initialization must never block
  // the first frame on Web or on a slow native platform.
  runApp(const ProviderScope(child: TRApp()));

  unawaited(AppDeepLinkService.instance.initialize());
}
