import 'package:flutter/foundation.dart';
import '../models/speed_test_data.dart';

class SpeedTestProvider with ChangeNotifier {
  SpeedTestData? _data;

  SpeedTestData? get data => _data;

  void updateSpeedTestData({
    required double downloadSpeed,
    required double uploadSpeed,
    required String isp,
    required String server
  }) {
    _data = SpeedTestData(
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      isp: isp,
      server: server
    );
    notifyListeners();
  }
}
