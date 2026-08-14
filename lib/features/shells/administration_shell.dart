import 'package:flutter/material.dart';

import '../home/shared_home_screen.dart';

class AdministrationShell extends StatelessWidget {
  const AdministrationShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: SharedHomeScreen()));
  }
}
