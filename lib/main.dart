import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'features/auth/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
    textTheme: GoogleFonts.fredokaTextTheme(),
  ),

      debugShowCheckedModeBanner: false,
      title: 'LOFA', 
      home: SplashScreen(),
    );
  }
}
