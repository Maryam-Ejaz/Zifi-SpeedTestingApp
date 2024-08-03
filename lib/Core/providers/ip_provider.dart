import 'package:flutter/material.dart';

class IpProvider with ChangeNotifier {
  String _internalIP = 'Unknown';
  String _externalIP = 'Unknown';
  String _mac = 'Unknown';
  String _ping = 'Unknown';
  String? _wifiName = 'Unknown';

  String get internalIP => _internalIP;
  String get externalIP => _externalIP;
  String get mac => _mac;
  String get ping => _ping;
  String? get wifiName => _wifiName;

  // Method to update the internal IP address
  void updateInternalIP({required String internalIP}) {
    _internalIP = internalIP;
    notifyListeners();
  }

  // Method to update the external IP address
  void updateExternalIP({required String externalIP}) {
    _externalIP = externalIP;
    notifyListeners();
  }

  // Method to update the mac
  void updateMac({required String mac}) {
    _mac = mac;
    notifyListeners();
  }

  void updatePing(String ping) {
    _ping = ping;
    notifyListeners();
  }

  void updateWifiName(String wifiName) {
    _wifiName = wifiName;
    notifyListeners();
  }

}
