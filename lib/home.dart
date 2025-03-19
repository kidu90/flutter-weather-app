import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double? temperature;
  String? cityName;
  String? weatherDescription;
  String? weatherIcon;

  void _fetchWeatherData() async {
    double latitude = 0;
    double longitude = 0;

    Position position = await _determinePosition();
    print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    latitude = position.latitude;
    longitude = position.longitude;

    getInformation(latitude, longitude);
  }

  void getInformation(double latitude, double longitude) async {
    var url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=fe312a74ff8a3c01d62f44c15379d2da");
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      String data = response.body;
      print(data);

      var decodedData = jsonDecode(data);
      double temp = decodedData['main']['temp'];
      cityName = decodedData['name'];
      weatherDescription = decodedData['weather'][0]['description'];

      print("temperature $temp");
      print("City Name :$cityName:");
      print(weatherDescription);
    } else {
      print(response.statusCode);
    }
  }

// Get the user's current location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeatherData,
        tooltip: 'Increment',
        child: const Icon(Icons.add_box),
      ),
    );
  }
}
