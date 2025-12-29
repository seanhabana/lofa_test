import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");


  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
