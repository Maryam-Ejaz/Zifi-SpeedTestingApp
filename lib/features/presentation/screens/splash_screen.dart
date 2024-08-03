import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'speed_test_screen.dart'; // Replace with your actual path
import '../../../Core/providers/location_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward(); // Start the animation

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _fadeOutAnimation = Tween<double>(begin: 2.0, end: 2.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Check for internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Show an error message or handle the lack of internet connectivity
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Close the app
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Proceed with location update if internet is available
    await _updateLocation();

    // Wait for fade-out animation to complete before navigating
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SpeedTestScreen()),
    );
  }

  Future<void> _updateLocation() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.updateLocation();
      print(locationProvider.country);

      if (locationProvider.country != "Unknown") {
        // Store updated values to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('country', locationProvider.country);
        prefs.setString('city', locationProvider.city);
        prefs.setString('countryCode', locationProvider.code);
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: FadeTransition(
            opacity: _fadeOutAnimation,
            child: SvgPicture.asset(
              'assets/icons/Zifi W.svg',
              color: Colors.white,
              width: 50, // Set size of the SVG
              height: 50,
            ),
          ),
        ),
      ),
    );
  }
}
