import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app_tutorial/Components/buildbackground.dart';
import 'package:weather_app_tutorial/consts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:weather_app_tutorial/pages/Forecast_page.dart';
import 'package:weather_app_tutorial/pages/countries_page.dart';
import 'package:weather_app_tutorial/Components/app_bottom_navigation_bar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'package:weather_app_tutorial/Components/CountryProvider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  String _selectedCity = "HongKong";
  String _selectedCountryCode = "HK";
  String _selectedTimezone = "Asia/Hong_Kong";
  List<Weather>? _upcomingWeather;
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    final countryProvider =
        Provider.of<CountryProvider>(context, listen: false);
    _selectedTimezone = countryProvider.selectedTimezone;
    _selectedCity = countryProvider.selectedCountry;
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
        _upcomingWeather = forecast;
      });
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == 0 && index == 0) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
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
    } else if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForecastPage(
            selectedCity: _selectedCity,
            selectedTimezone: _selectedTimezone,
          ),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildBackground(context),
          SafeArea(
            child: _buildUI(),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null || _upcomingWeather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.3),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dateTimeInfo(),
                    SizedBox(height: 16),
                    _buildContent(),
                    SizedBox(height: 16),
                    _extraInfo(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.3),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Forecast",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    buildTemperatureList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final countryProvider = Provider.of<CountryProvider>(context);
    final selectedTimezone = countryProvider.selectedTimezone;
    String lastUpdated = _weather != null
        ? DateFormat('hh:mm a').format(tz.TZDateTime.from(
            _weather!.date!, tz.getLocation(selectedTimezone)))
        : '';
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _weatherIcon(),
            SizedBox(height: 16),
            _currentTemp(),
            SizedBox(height: 16),
            Text(
              'Last Updated at: $lastUpdated',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeInfo() {
    final countryProvider = Provider.of<CountryProvider>(context);
    final selectedTimezone = countryProvider.selectedTimezone;
    final selectedCountry = countryProvider.selectedCountry;
    final selectedFlagCode = countryProvider.selectedFlagCode;
    final currentTime = tz.TZDateTime.now(tz.getLocation(selectedTimezone));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              child: Flag.fromString(
                selectedFlagCode,
                width: 32,
                height: 32,
              ),
            ),
            SizedBox(width: 8),
            Text(
              selectedCountry,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Current Temperature",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat("EEEE").format(currentTime),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat("d MMM y").format(currentTime),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              DateFormat("HH:MM a").format(currentTime),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                    "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentTemp() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${_weather?.temperature?.celsius?.toStringAsFixed(1)}°C",
            style: TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _weather?.weatherMain ?? "",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _extraInfo() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildExtraInfoItem("Lowest Temperature",
                  "${_weather?.tempMin?.celsius?.toStringAsFixed(1)}°C", "Low"),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildExtraInfoItem("Wind",
                  "${_weather?.windSpeed?.toStringAsFixed(1)} m/s", "wind"),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildExtraInfoItem(
                  "Highest Temperature",
                  "${_weather?.tempMax?.celsius?.toStringAsFixed(1)}°C",
                  "High"),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildExtraInfoItem("Humidity",
                  "${_weather?.humidity?.toStringAsFixed(1)}%", "humidity"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExtraInfoItem(String title, String value, String iconName) {
    IconData iconData;
    switch (iconName) {
      case "Low":
        iconData = Icons.arrow_downward;
        break;
      case "wind":
        iconData = Icons.wind_power;
        break;
      case "humidity":
        iconData = Icons.water_drop;
        break;
      case "High":
        iconData = Icons.arrow_upward;
        break;
      default:
        iconData = Icons.warning;
    }
    return Wrap(spacing: 8, children: [
      Icon(
        iconData,
        color: Colors.white,
        size: 24,
      ),
      SizedBox(height: 4),
      Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      Wrap(
        spacing: 4,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
    ]);
  }

  Widget buildTemperatureList(BuildContext context) {
    final countryProvider = Provider.of<CountryProvider>(context);
    final selectedTimezone = countryProvider.selectedTimezone;
    if (_upcomingWeather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    tz.TZDateTime currentDateTime =
        tz.TZDateTime.now(tz.getLocation(selectedTimezone));
    List<Weather> forecastsForCurrentDate = _upcomingWeather!
        .where((forecast) =>
            forecast.date!.year == currentDateTime.year &&
            forecast.date!.month == currentDateTime.month &&
            forecast.date!.day == currentDateTime.day)
        .toList();
    return Container(
      height: MediaQuery.of(context).size.height * 0.30,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: forecastsForCurrentDate.length,
          itemBuilder: (context, index) {
            Weather forecast = forecastsForCurrentDate[index];
            tz.TZDateTime forecastDateTime = tz.TZDateTime.from(
                forecast.date!, tz.getLocation(selectedTimezone));
            String forecastIcon = forecast.weatherIcon!;
            String forecastTemp =
                "${forecast.temperature?.celsius?.toStringAsFixed(0)}°";
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                color: Colors.white.withOpacity(0.8),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat("EEE HH:mm").format(forecastDateTime),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.15,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "http://openweathermap.org/img/wn/$forecastIcon@2x.png",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          forecastTemp,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          DateFormat("MMM d").format(forecastDateTime),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
