import 'package:esp32/DetailPage.dart';
import 'package:flutter/material.dart';

class WeatherPage extends StatelessWidget {
  final PageController _pageController = PageController();

  final List<WeatherCard> weatherCards = [
    WeatherCard(
      city: "Living Room",
      temperature: "20°C",
      weather: "Sunny",
      sunrise: "6:00 AM",
      sunset: "7:30 PM",
      maxTemp: "25°C",
      minTemp: "15°C",
      humidity: "60%",
      windSpeed: "15 km/h",
      isDayTime: true,
    ),
    WeatherCard(
      city: "Kitchen",
      temperature: "25°C",
      weather: "Cloudy",
      sunrise: "5:30 AM",
      sunset: "8:00 PM",
      maxTemp: "18°C",
      minTemp: "10°C",
      humidity: "70%",
      windSpeed: "10 km/h",
      isDayTime: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: weatherCards,
            ),
          ),
        ],
      ),
    );
  }
}
