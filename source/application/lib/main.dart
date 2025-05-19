import 'package:application/calculator/page_calculator.dart';
import 'package:application/dashboard/page_dashboard.dart';
import 'package:application/splash/page_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: PageSplash()),
  );
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
          return MaterialPageRoute(builder: (context) => PageCalculator());
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
