import 'package:flutter/foundation.dart';

class CountryProvider with ChangeNotifier {
  String _selectedCountry = "HongKong";
  String _selectedFlagCode = "HK";
  String _selectedTimezone = "Asia/Hong_Kong";

  String get selectedCountry => _selectedCountry;
  String get selectedFlagCode => _selectedFlagCode;
  String get selectedTimezone => _selectedTimezone;

  CountryProvider() {
    // Set the default values
    _selectedCountry = "HongKong";
    _selectedFlagCode = "HK";
    _selectedTimezone = "Asia/Hong_Kong";
  }

  void setSelectedCountry(
    String country,
    String flagCode,
    String timezone,
  ) {
    _selectedCountry = country;
    _selectedFlagCode = flagCode;
    _selectedTimezone = timezone;
    notifyListeners();
  }
}