import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late String _weather = 'Loading...';
  late double _latitude;
  late double _longitude;
  late String _city;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _weather = 'Location permission denied.';
      });
    } else {
      _updateWeather();
    }
  }

  Future<void> _updateWeather() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    final response = await http.get(
        Uri.parse('http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=c36d00a1ade6f97e5f7d9861c3dff92c'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String weather = data['weather'][0]['description'];
      setState(() {
        _weather = weather;
        _latitude = position.latitude;
        _longitude = position.longitude;
        _city = data['name'];
      });
    } else {
      setState(() {
        _weather = 'Failed to load weather data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Weather: $_weather'),
            SizedBox(height: 20),
            Text('Latitude: $_latitude'),
            Text('Longitude: $_longitude'),
            Text('City: $_city'),
            SizedBox(height: 20),
            Image.network(
              'https://maps.googleapis.com/maps/api/staticmap?center=$_latitude,$_longitude&zoom=15&size=400x300&key=AIzaSyDLcwxUggpPZo8lcbH0TB4Crq5SJjtj4ag',
              width: 400,
              height: 300,
            ),
          ],
        ),
      ),
    );
  }
}
