import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(
      fileName: ".env"); // Load the .env file from the root directory
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double? temperature;
  String? cityName;
  String? weatherDescription;
  String? weatherIcon;
  int _counter = 0;

  void _incrementCounter() async {
    double latitude = 0;
    double longitude = 0;

    Position position = await _determinePosition();
    print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    latitude = position.latitude;
    longitude = position.longitude;

    getInformation(latitude, longitude);
  }

  void getInformation(double latitude, double longitude) async {
    String apiKey = dotenv.env['API_KEY'] ?? ''; // Fetch API key

    if (apiKey.isEmpty) {
      print("API Key is missing");
      return;
    }

    var url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey");
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      String data = response.body;
      print(data);

      var decodedData = jsonDecode(data);
      double temp = decodedData['main']['temp'];
      cityName = decodedData['name'];
      weatherDescription = decodedData['weather'][0]['description'];
      weatherIcon = decodedData['weather'][0]['icon'];
      print("temperature $temp");
      print("City Name :$cityName:");
      print(" Weather :$weatherDescription");
      print("Icon :$weatherIcon");
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
