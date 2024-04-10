import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather/weather.dart';
import 'package:weather_app_tutorial/Components/CountryProvider.dart';
import 'package:weather_app_tutorial/Components/app_bottom_navigation_bar.dart';
import 'package:weather_app_tutorial/Components/buildbackground.dart';
import 'package:weather_app_tutorial/consts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:weather_app_tutorial/pages/countries_page.dart';
import 'package:weather_app_tutorial/pages/home_page.dart';

class ForecastPage extends StatefulWidget {
  final String selectedCity;
  final String selectedTimezone;

  ForecastPage({required this.selectedCity, required this.selectedTimezone});

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  List<Weather>? _forecastWeather;
  Weather? _weather;
  String _selectedCity = "";
  String _selectedCountryCode = "";
  String _selectedTimezone = "";
  int _selectedDayIndex = 0;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _fetchForecastWeatherData();
  }

  void _fetchForecastWeatherData() {
    _wf.fiveDayForecastByCityName(widget.selectedCity).then((forecast) {
      setState(() {
        _forecastWeather = forecast;
      });
    });
  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
  }

  void _onCountrySelected(
    String selectedCountry,
    String selectedFlagCode,
    String selectedTimezone,
  ) async {
    final countryProvider =
        Provider.of<CountryProvider>(context, listen: false);
    countryProvider.setSelectedCountry(
      selectedCountry,
      selectedFlagCode,
      selectedTimezone,
    );
    setState(() {
      _selectedCity = selectedCountry;
      _selectedCountryCode = selectedFlagCode;
      _selectedTimezone = selectedTimezone;
    });
    _fetchWeatherData();
  }

  void _fetchWeatherData() {
    _wf.currentWeatherByCityName(_selectedCity).then((w) {
      setState(() {
        _weather = w;
      });
    });
    _wf.fiveDayForecastByCityName(_selectedCity).then((forecast) {
      setState(() {
        _forecastWeather = forecast;
      });
    });
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CountriesScreen(
              onCountrySelected: _onCountrySelected,
            ),
          ),
        ).then((value) {
          if (value != null) {
            _onCountrySelected(
              value.selectedCountry,
              value.selectedFlagCode,
              value.selectedTimezone,
            );
          }
        });
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildBackground(context),
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  _buildSelectedDayInfo(),
                  SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.3),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: _buildForecastList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

 Widget _buildSelectedDayInfo() {
  if (_forecastWeather == null ||
      _selectedDayIndex >= _forecastWeather!.length) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  final countryProvider = Provider.of<CountryProvider>(context);
  Weather selectedDayWeather = _forecastWeather![_selectedDayIndex];
  DateTime selectedDayDateTime = tz.TZDateTime.from(
    selectedDayWeather.date?? DateTime.now(),
    tz.getLocation(widget.selectedTimezone),
  );
  final selectedCountry = countryProvider.selectedCountry;
  final selectedFlagCode = countryProvider.selectedFlagCode;
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Flag.fromString(
                selectedFlagCode,
                width: 32,
                height: 32,
              ),  
            ),
            SizedBox(height: 8),
                Text(
                  selectedCountry,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            Spacer(),
            Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat("EEEE").format(selectedDayDateTime),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    DateFormat("d MMM y").format(selectedDayDateTime),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat("HH:MM a").format(selectedDayDateTime),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    "http://openweathermap.org/img/wn/${selectedDayWeather.weatherIcon}@4x.png",
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.thermostat,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Temperature: ${selectedDayWeather.temperature?.celsius?.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Lowest Temperature: ${selectedDayWeather.tempMin?.celsius?.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wind_power,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Wind: ${selectedDayWeather.windSpeed} m/s',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Highest Temperature: ${selectedDayWeather.tempMax?.celsius?.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                     ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Humidity: ${selectedDayWeather.humidity}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildForecastList() {
    if (_forecastWeather == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: _forecastWeather!.length,
      itemBuilder: (context, index) {
        Weather forecastWeather = _forecastWeather![index];
        DateTime forecastDateTime = tz.TZDateTime.from(
          forecastWeather.date ?? DateTime.now(),
          tz.getLocation(widget.selectedTimezone),
        );
        String forecastDate = DateFormat('EEE, MMM d').format(forecastDateTime);
        String forecastTime = DateFormat('h:mm a').format(forecastDateTime);

        return GestureDetector(
          onTap: () => _onDaySelected(index),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(forecastDate, style: TextStyle(color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Time: $forecastTime',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(
                        "http://openweathermap.org/img/wn/${forecastWeather.weatherIcon}@4x.png",
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Temperature: ${forecastWeather.temperature?.celsius?.toStringAsFixed(1)}°C',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
