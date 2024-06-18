import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = "London";
  String temperature = "";
  String description = "";
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      final apiKey = dotenv.env['API_KEY'];
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['main']['temp'].toString();
          description = data['weather'][0]['description'];
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : hasError
                ? const Text(
                    'Failed to load weather data. Please try again later.',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'City: $city',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Temperature: $temperature°C',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Description: $description',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
      ),
    );
  }
}
