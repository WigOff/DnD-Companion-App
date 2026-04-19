import 'package:dnd_app/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/services/websocket_client.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ws.connect();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PlayerProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D&D Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.cinzelTextTheme(ThemeData.dark().textTheme)
            .copyWith(
              bodyMedium: GoogleFonts.cinzel(color: Colors.white70),
              bodySmall: GoogleFonts.cinzel(color: Colors.white60),
            ),
      ),
      home: const HomeScreen(),
    );
  }
}
