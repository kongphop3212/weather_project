import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather/weather.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CityListPage(),
    );
  }
}

class CityListPage extends StatelessWidget {
  const CityListPage({super.key});

  final List<String> cities = const [
    'Bangkok', 'New York', 'London', 'Tokyo', 'Sydney', 'Paris', 'Berlin', 'Moscow', 
    'Cairo', 'Los Angeles', 'San Francisco', 'Hong Kong', 'Singapore', 'Mumbai', 
    'Dubai', 'Istanbul', 'Toronto', 'Rio de Janeiro', 'Buenos Aires', 'Cape Town', 
    'Seoul', 'Beijing', 'Shanghai', 'Melbourne', 'Rome', 'Madrid', 'Mexico City', 
    'Lima', 'Jakarta', 'Phnom Penh', 'Seoul'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Project',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0099FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3,
          ),
          itemCount: cities.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherDetailPage(city: cities[index]),
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    cities[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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

class WeatherDetailPage extends StatefulWidget {
  final String city;

  const WeatherDetailPage({super.key, required this.city});

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  late Future<WeatherResponse> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getData(widget.city);
  }

  Future<WeatherResponse> getData(String city) async {
    var client = http.Client();
    try {
      var apiKey = dotenv.env['API_KEY']; // ดึง API Key จาก .env
      var response = await client.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey'));
      if (response.statusCode == 200) {
        return WeatherResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception("Failed to load data");
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city),
        backgroundColor: const Color(0xFF0099FF),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"), // Your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: FutureBuilder<WeatherResponse>(
              future: weatherData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading weather data', style: TextStyle(color: Colors.white, fontSize: 16));
                } else if (snapshot.hasData) {
                  var data = snapshot.data!;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8), // Slightly transparent background
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.name ?? "",
                          style: const TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Current Temp: ${data.main?.temp?.toStringAsFixed(2) ?? "0.00"} °C',
                          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        Text(
                          'Min Temp: ${data.main?.tempMin?.toStringAsFixed(2) ?? "0.00"} °C',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Max Temp: ${data.main?.tempMax?.toStringAsFixed(2) ?? "0.00"} °C',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Pressure: ${data.main?.pressure?.toString() ?? "N/A"} hPa',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Humidity: ${data.main?.humidity?.toString() ?? "N/A"} %',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Sea Level: ${data.main?.seaLevel?.toString() ?? "N/A"} hPa',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Clouds: ${data.clouds?.all?.toString() ?? "N/A"} %',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Rain (1h): ${data.rain?.d1h?.toString() ?? "N/A"} mm',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Sunset: ${data.sys?.sunset != null ? DateTime.fromMillisecondsSinceEpoch(data.sys!.sunset! * 1000).toLocal().toString() : "N/A"}',
                          style: const TextStyle(color: Colors.black),
                        ),
                        if (data.weather != null && data.weather!.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2), // Slightly transparent background
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.network(
                              'http://openweathermap.org/img/wn/${data.weather![0].icon}@2x.png',
                              width: 100,
                              height: 100,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  );
                } else {
                  return const Text('No data available', style: TextStyle(color: Colors.white, fontSize: 16));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
