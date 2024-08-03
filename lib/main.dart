import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zifi/features/presentation/screens/splash_screen.dart';
import 'Core/providers/ip_provider.dart';
import 'Core/providers/location_provider.dart';
import 'Core/providers/speed_test_provider.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IpProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SpeedTestProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Test App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Initialize the SpeedTestScreen
    );
  }
}
