import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class WeatherCard extends StatefulWidget {
  final String city;
  final String temperature;
  final String weather;
  final String sunrise;
  final String sunset;
  final String maxTemp;
  final String minTemp;
  final String humidity;
  final String windSpeed;
  final bool isDayTime;

  const WeatherCard({
    Key? key,
    required this.city,
    required this.temperature,
    required this.weather,
    required this.sunrise,
    required this.sunset,
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
    required this.windSpeed,
    required this.isDayTime,
  }) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String _uartData = "No data";
  String _temperature = "";
  String _humidity = "";
  Timer? _timer;
  bool whiteLed = false;
  bool redLed = false;
  bool blueLed = false;
  bool greenLed = false;

  Future<void> _sendRequest(String path) async {
    final response = await http.get(Uri.parse('http://192.168.4.1$path'));

    if (response.statusCode == 200) {
      setState(() {
        if (path == '/uartData') {
          _uartData = response.body;
          _parseData(_uartData);
        }
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _parseData(String data) {
    final tempMatch = RegExp(r'Temperature:\s*([\d.]+)\s*\*C').firstMatch(data);
    final humMatch = RegExp(r'Humidity:\s*([\d.]+)\s*%RH').firstMatch(data);

    if (tempMatch != null && humMatch != null) {
      _temperature = tempMatch.group(1) ?? "N/A";
      _humidity = humMatch.group(1) ?? "N/A";
    }
  }

  @override
  void initState() {
    super.initState();
    _sendRequest('/uartData');
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _sendRequest('/uartData');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height * 1,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage(
                  widget.isDayTime
                      ? 'assets/images/5.jpg'
                      : 'assets/images/6.jpg',
                ))),
        padding: EdgeInsets.only(
            top: size.height * 0.175, bottom: size.height * 0.05),
        child: Container(
          height: size.height * 0.7,
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.city,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'Temperature: $_temperature °C',
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'Humidity: $_humidity %RH',
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
              Text(
                "Features",
                style: TextStyle(fontSize: 24.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteLed == false
                          ? Colors.transparent
                          : Colors.pinkAccent,
                      elevation: 5,
                      shadowColor: Colors.black,
                    ),
                    onPressed: () {
                      _sendRequest('/toggleColdLight');
                      setState(() {
                        whiteLed = !whiteLed;
                      });
                    },
                    child: Text(
                      whiteLed == false ? 'AI' : 'AI Active',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  buildSizedBox(),
                  Icon(
                    FontAwesomeIcons.brain,
                    size: 24.0,
                    color: whiteLed == false
                        ? Colors.transparent
                        : Colors.pinkAccent,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redLed == false
                          ? Colors.transparent
                          : Colors.redAccent,
                      elevation: 5,
                      shadowColor: Colors.black,
                    ),
                    onPressed: () {
                      _sendRequest('/toggleRed');
                      setState(() {
                        redLed = !redLed;
                      });
                    },
                    child: Text(
                      redLed == false
                          ? 'Increase Temperature'
                          : 'Temperature Increasing...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  buildSizedBox(),
                  Icon(
                    FontAwesomeIcons.lightbulb,
                    size: 24.0,
                    color: redLed == false ? Colors.transparent : Colors.red,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          blueLed == false ? Colors.transparent : Colors.blue,
                      elevation: 5,
                      shadowColor: Colors.black,
                    ),
                    onPressed: () {
                      _sendRequest('/toggleBlue');
                      setState(() {
                        blueLed = !blueLed;
                      });
                    },
                    child: Text(
                      blueLed == false
                          ? 'Lower Temperature'
                          : 'Lowering Temperature...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  buildSizedBox(),
                  Icon(
                    FontAwesomeIcons.snowflake,
                    size: 24.0,
                    color: blueLed == false ? Colors.transparent : Colors.blue,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenLed == false
                          ? Colors.transparent
                          : Colors.greenAccent,
                      elevation: 5,
                      shadowColor: Colors.black,
                    ),
                    onPressed: () {
                      _sendRequest('/toggleGreen');
                      setState(() {
                        greenLed = !greenLed;
                      });
                    },
                    child: Text(
                      greenLed == false
                          ? 'Clean the Room'
                          : 'Cleaning the Room...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  buildSizedBox(),
                  Icon(
                    FontAwesomeIcons.wind,
                    size: 24.0,
                    color:
                        greenLed == false ? Colors.transparent : Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox buildSizedBox() {
    return SizedBox(
      width: 50,
    );
  }
}
