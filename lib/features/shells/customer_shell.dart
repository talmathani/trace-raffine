import 'package:flutter/material.dart';

import '../home/shared_home_screen.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SharedHomeScreen(),
      ),
    );
  }
}
