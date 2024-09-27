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
    WeatherCard(
      city: "Meeting Room",
      temperature: "22°C",
      weather: "Rainy",
      sunrise: "5:00 AM",
      sunset: "6:45 PM",
      maxTemp: "26°C",
      minTemp: "19°C",
      humidity: "80%",
      windSpeed: "20 km/h",
      isDayTime: true,
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
          // Container(
          //   width: size.width,
          //   padding: const EdgeInsets.all(12.0),
          //   decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
          //   child: Center(
          //     child: SmoothPageIndicator(
          //       controller: _pageController,
          //       count: weatherCards.length,
          //       effect: WormEffect(
          //         dotWidth: 12.0,
          //         dotHeight: 12.0,
          //         spacing: 16.0,
          //         dotColor: Colors.white.withOpacity(0.8),
          //         activeDotColor: Colors.greenAccent,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
