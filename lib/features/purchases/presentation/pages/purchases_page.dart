import 'package:flutter/material.dart';

class PurchasesPage extends StatelessWidget {
  final bool embedded;

  const PurchasesPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
        ),
      ),
      child: const Center(
        child: Text(
          "Purchases UI is ready.\nBackend integration will be added later.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text("Purchases")),
      body: body,
    );
  }
}
