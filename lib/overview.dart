import 'package:flutter/material.dart';
import 'package:flutter_application_final/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Navbar.dart'; // Import CustomNavbar component
import 'ProfilePage.dart';
import 'mqttservice.dart';
import 'notification.dart';
import 'setting.dart';

class TentPage extends StatefulWidget {
  final String name;  // Device ID passed to this page

  // Constructor to accept deviceId
  const TentPage({super.key, required this.name});

  @override
  _TentPageState createState() => _TentPageState();
}

class _TentPageState extends State<TentPage> {
  double? temperature;
  double? humidity;
  int? lightState;

  late MqttService mqttService;

  @override
  void initState() {
    super.initState();

    // Initialize MqttService with the specific deviceId
    mqttService = MqttService(onDataReceived: (temp, hum, light) {
      setState(() {
        temperature = temp;
        humidity = hum;
        lightState = light;
      });
    }, onDeviceConnectionStatusChange: (String , bool ) { 

      
     });

    // Setup MQTT client based on the deviceId
   // mqttService.setupMqttClient(deviceId: widget.deviceId);
  }

  @override
  void dispose() {
    mqttService.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProfilePage(),
    const notification(),
    const MyApp(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boxSize = screenWidth * 0.46;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Settings Icon
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        0.09,
                        screenHeight * 0.06,
                        screenWidth * 0.045,
                        screenHeight * 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.settings_sharp,
                            color: Theme.of(context).primaryColor,
                            size: screenWidth * 0.1,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
    builder: (context) => TentSettingsWidget(name: widget.name), // Pass deviceId
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Title Text
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0.5, 0, screenHeight * 0.05),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
  'Overview (${widget.name})',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: screenWidth * 0.08,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Humidity and Light Intensity Boxes
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBox(
                          context,
                          boxSize: boxSize,
                          icon: Icons.water_drop,
                          iconColor: Colors.blue,
                          title: 'Humidity',
                          value: '${humidity ?? 'Loading...'} %',
                        ),
                        SizedBox(width: mediaQuery.size.width * 0.02),
                        _buildBox(
                          context,
                          boxSize: boxSize,
                          icon: Icons.lightbulb_outline,
                          iconColor: Colors.yellow,
                          title: 'Light Intensity',
                          value: '${lightState == 1 ? 'High' : 'Low'} ',
                        ),
                      ],
                    ),
                  ),
                  // Temperature and Water Level Boxes
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyApp(),
                              ),
                            );
                          },
                          child: _buildBox(
                            context,
                            boxSize: boxSize,
                            icon: FontAwesomeIcons.temperatureFull,
                            iconColor: const Color.fromARGB(255, 221, 161, 76),
                            title: 'Temperature',
                            value: '${temperature ?? 'Loading...'} °C',
                          ),
                        ),
                        SizedBox(width: mediaQuery.size.width * 0.02),
                        _buildBox(
                          context,
                          boxSize: boxSize,
                          icon: Icons.water_sharp,
                          iconColor: Theme.of(context).colorScheme.error,
                          title: 'Water Level',
                          value: '50%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Method to build a box with an icon and text
  Widget _buildBox(BuildContext context,
      {required double boxSize,
      required IconData icon,
      required Color iconColor,
      required String title,
      required String value}) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 6, 94, 135),
            Color.fromARGB(255, 84, 90, 95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Align(
            alignment: const AlignmentDirectional(0, -0.5),
            child: Icon(
              icon,
              color: iconColor,
              size: boxSize * 0.35,
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.85),
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: boxSize * 0.12,
                    fontFamily: 'Outfit',
                    color: Colors.white,
                  ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.4),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: boxSize * 0.14,
                    fontFamily: 'Outfit',
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}