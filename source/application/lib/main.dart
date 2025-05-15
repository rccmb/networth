import 'package:application/index.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      debugShowCheckedModeBanner: false,
    );
  }
}
