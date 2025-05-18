import 'package:application/calculator/page_calculator.dart';
import 'package:application/index.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final jsonSecrets = await rootBundle.loadString('assets/secrets.json');
  final secrets = json.decode(jsonSecrets);

  await Supabase.initialize(
    url: secrets["supabase_url"],
    anonKey: secrets["supabase_key"],
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageDashboard(),
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF040C15)),
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      routes: {'/dashboard': (context) => const PageDashboard()},
      onGenerateRoute: (settings) {
        if (settings.name == '/calculator') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (context) => PageCalculator(
                  networth: args['networth'],
                  euroFormat: args['euroFormat'],
                ),
          );
        }
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
    );
  }
}
