import 'package:flutter/material.dart';
import 'package:gad_fly_partner/auth/register_screen.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GadFly Partner',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const RegisterScreen(),
    );
  }
}
