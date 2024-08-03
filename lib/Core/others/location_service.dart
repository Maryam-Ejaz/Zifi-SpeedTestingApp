import 'package:geolocator/geolocator.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  final String _googleMapApiKey = "AIzaSyAldHoLIEml0fpIRMRCkBTamXtIE8YAEFo";

  Future<Map<String, dynamic>> determinePosition() async {
    print("Starting determinePosition...");

    if (!await _isLocationServiceEnabled()) {
      print("Location services are disabled.");
      return Future.error('Location services are disabled.');
    }
    print("Location services are enabled.");

    final permission = await _requestLocationPermission();
    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    print("Location permission status: $permission");

    final position = await Geolocator.getCurrentPosition();
    print("Current position: Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    if (position.latitude.toString().isEmpty){
      _fetchFromSharedPreferences();
    }

    try {
      final data = await _getGeoData(position.latitude, position.longitude);
      print("GeoData: ${data.address}, City: ${data.city}, Country: ${data.country}, CountryCode: ${data.countryCode}");

      // If country is not available from GeoData, fetch from SharedPreferences
      if (data.country.isEmpty) {
        print("Country data is empty, fetching from SharedPreferences...");
        return await _fetchFromSharedPreferences();
      }

      // Store updated values to SharedPreferences
      print("Updating SharedPreferences with new data...");
      await _updateSharedPreferences(data, position);

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'country': data.country,
        'city': data.city,
        'countryCode': data.countryCode,
      };
    } catch (e) {
      print("Error fetching address: $e");
      return Future.error('Error fetching address: $e');
    }
  }

  Future<bool> _isLocationServiceEnabled() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    print("Is location service enabled: $isEnabled");
    return isEnabled;
  }

  Future<LocationPermission> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print("Initial location permission: $permission");

    if (permission == LocationPermission.denied) {
      print("Requesting location permission...");
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<GeoData> _getGeoData(double latitude, double longitude) async {
    print("Fetching GeoData for Latitude: $latitude, Longitude: $longitude");
    final data = await Geocoder2.getDataFromCoordinates(
      latitude: latitude,
      longitude: longitude,
      googleMapApiKey: _googleMapApiKey,
    );
    print("Received GeoData: Address: ${data.address}, City: ${data.city}, Country: ${data.country}, CountryCode: ${data.countryCode}");
    return data;
  }

  Future<void> _updateSharedPreferences(GeoData data, Position position) async {
    final prefs = await SharedPreferences.getInstance();
    print("Storing data in SharedPreferences - Country: ${data.country}, City: ${data.city}, CountryCode: ${data.countryCode}");
    await prefs.setString('country', data.country);
    await prefs.setString('city', data.city);
    await prefs.setString('countryCode', data.countryCode);
    await prefs.setString('latitude', position.latitude.toString());
    await prefs.setString('longitude', position.longitude.toString());
  }

  Future<Map<String, dynamic>> _fetchFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('country') ?? 'UNKNOWN';
    final city = prefs.getString('city') ?? 'UNKNOWN';
    final countryCode = prefs.getString('countryCode') ?? 'UNKNOWN';
    final latitude = prefs.getString('latitude') ?? 'UNKNOWN';
    final longitude = prefs.getString('longitude') ?? 'UNKNOWN';

    print("Fetched from SharedPreferences - Country: $country, City: $city, CountryCode: $countryCode");

    return {
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'city': city,
      'countryCode': countryCode,
    };
  }
}
