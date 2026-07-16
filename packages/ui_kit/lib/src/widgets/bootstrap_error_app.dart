/// Purpose: Shown when the app cannot even start (bad config, init failure).
/// Responsibilities: Friendly, brand-consistent, trilingual message with NO
/// technical details (UX rule). The real error goes to the developer console.
/// Dependencies: flutter material.
/// Usage: runApp(const BootstrapErrorApp()) from main()'s catch block.
library;

import 'package:flutter/material.dart';

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Deliberately trilingual & hardcoded: translations may not have loaded.
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.build_circle_outlined, size: 48),
              SizedBox(height: 16),
              Text('Hanti ERP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text("The application isn't ready to start.\nPlease contact your administrator.",
                  textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text('Abka wali diyaar ma aha. Fadlan la xiriir maamulaha.',
                  textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text('التطبيق غير جاهز للتشغيل. يرجى التواصل مع المسؤول.',
                  textAlign: TextAlign.center, textDirection: TextDirection.rtl),
            ]),
          ),
        ),
      ),
    );
  }
}
