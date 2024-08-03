import 'package:flutter/foundation.dart';
import '../others/location_service.dart';

class LocationProvider with ChangeNotifier {
  // Default values
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _country = 'Unknown';
  String _city = 'Unknown';
  String _code = 'Unknown';

  double get latitude => _latitude;
  double get longitude => _longitude;
  String get country => _country;
  String get city => _city;
  String get code => _code;

  Future<void> updateLocation() async {
    LocationService locationService = LocationService();

    try {
      final locationData = await locationService.determinePosition();
      _latitude = locationData['latitude'] ?? _latitude;
      _longitude = locationData['longitude'] ?? _longitude;
      _country = locationData['country'] ?? _country;
      _city = locationData['city'] ?? _city;
      _code = locationData['countryCode'] ?? _code;

      notifyListeners();
    } catch (e) {
      print('Error updating location: $e');
    }
  }
}
