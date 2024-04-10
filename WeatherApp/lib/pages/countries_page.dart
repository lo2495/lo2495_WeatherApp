import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:weather_app_tutorial/Components/app_bottom_navigation_bar.dart';
import 'package:weather_app_tutorial/Components/buildbackground.dart';

class CountriesScreen extends StatelessWidget {
  final Function(String, String, String) onCountrySelected;

  CountriesScreen({Key? key, required this.onCountrySelected})
      : super(key: key);

  final List<Map<String, String>> countryList = [
    {
      'flagCode': 'HK',
      'countryName': 'Hong Kong',
      'value': 'HongKong',
      'timezone': 'Asia/Hong_Kong'
    },
    {
      'flagCode': 'HK',
      'countryName': 'Kowloon',
      'value': 'Kowloon',
      'timezone': 'Asia/Hong_Kong'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Osaka',
      'value': 'Osaka',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Tokyo',
      'value': 'Tokyo',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Yokohama',
      'value': 'Yokohama',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Fukuoka',
      'value': 'Fukuoka',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Kawasaki',
      'value': 'Kawasaki',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Kobe',
      'value': 'Kobe',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Kyoto',
      'value': 'Kyoto',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Nagoya',
      'value': 'Nagoya',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'JP',
      'countryName': 'Sapporo',
      'value': 'Sapporo',
      'timezone': 'Asia/Tokyo'
    },
    {
      'flagCode': 'CN',
      'countryName': 'Wuhan',
      'value': 'Wuhan',
      'timezone': 'Asia/Shanghai'
    },
    {
      'flagCode': 'CN',
      'countryName': 'BeiJing',
      'value': 'BeiJing',
      'timezone': 'Asia/Shanghai'
    },
    {
      'flagCode': 'CN',
      'countryName': 'Chengdu',
      'value': 'Chengdu',
      'timezone': 'Asia/Shanghai'
    },
    {
      'flagCode': 'CN',
      'countryName': 'Chongqing',
      'value': 'Chongqing',
      'timezone': 'Asia/Shanghai'
    },
    {
      'flagCode': 'CN',
      'countryName': 'Dongguan',
      'value': 'Dongguan',
      'timezone': 'Asia/Shanghai'
    },
    {
      'flagCode': 'CN',
      'countryName': 'Nanjing',
      'value': 'Nanjing',
      'timezone': 'Asia/Shanghai'
    },
    {
      'flagCode': 'CN',
      'countryName': 'Shanghai',
      'value': 'Shanghai',
      'timezone': 'Asia/Shanghai'
    },
    {
      'flagCode': 'CN',
      'countryName': 'Shenzhen',
      'value': 'Shenzhen',
      'timezone': 'Asia/Shanghai'
    },
    {
      'flagCode': 'SG',
      'countryName': 'Singapore',
      'value': 'Singapore',
      'timezone': 'Asia/Singapore'
    },
    {
      'flagCode': 'NZ',
      'countryName': 'Wellington',
      'value': 'Wellington',
      'timezone': 'Pacific/Auckland'
    },
    {
      'flagCode': 'NZ',
      'countryName': 'Auckland',
      'value': 'Auckland',
      'timezone': 'Pacific/Auckland'
    },
    // Add more countries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildBackground(context),
          Container(
            color: Colors.white.withOpacity(0.3),
            child: Builder(
              builder: (BuildContext context) {
                return ListView.builder(
                  itemCount: countryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return countryTile(context, countryList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: 0,
        onItemTapped: (index) {
          if (index == 1) {
            Navigator.pop(context);
          } else if (index == 0) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }

  Widget countryTile(BuildContext context, Map<String, String> countryData) {
    return ListTile(
        tileColor: Colors.white.withOpacity(0.5),
        trailing: Container(
          width: 40,
          height: 40,
          child: Flag.fromString(
            countryData['flagCode']!,
            width: 40,
            height: 40,
          ),
        ),
        title: Text(
          countryData['countryName']!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          onCountrySelected(
            countryData['countryName']!,
            countryData['flagCode']!,
            countryData['timezone']!,
          );
          Navigator.pop(context);
        });
  }
}
