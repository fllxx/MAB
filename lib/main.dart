import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_application_final/Navbar.dart';
import 'package:flutter_application_final/mqttTests/MQTT.dart';
import 'package:flutter_application_final/one.dart';
import 'package:flutter_application_final/overview.dart';
import 'package:flutter_application_final/registerFour.dart';
import 'package:flutter_application_final/three.dart';
import 'package:flutter_application_final/two.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'aTent.dart';
import 'test.dart';

void main() async{

  
  // Initialize Hive
  await Hive.initFlutter();

  // Open the Hive box before using it
  await Hive.openBox('deviceBox');  // Open your box here
  runApp(
    DevicePreview(
      enabled: true, // Enable the device preview for testing
      builder: (context) => ChangeNotifierProvider(
        create: (_) => DeviceManager(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true, // Enable media query for responsiveness
      builder: DevicePreview.appBuilder, // Wraps the app with DevicePreview
      locale: DevicePreview.locale(context), // Supports locale changes in DevicePreview
      title: 'PlantCare Hubs',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Track the selected index

  // Define pages to navigate to
  final List<Widget> _pages = [
    Register4Widget(),
    TentPage(name: 'deviceId'),
    AddDevicePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context); // Get screen dimensions

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: const AlignmentDirectional(0, -0.9),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  0,
                  mediaQuery.size.height * 0.06, // Responsive top padding
                  0,
                  0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PlantCare Hubs',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: mediaQuery.size.width * 0.07, // Responsive font size
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              10, mediaQuery.size.height * 0.15, 0, 5),
            child: Consumer<DeviceManager>(
              builder: (context, deviceManager, child) {
                // Ensure that the device box is loaded and available
                if (deviceManager.deviceBox == null) {
                  return Center(child: CircularProgressIndicator()); // Wait for initialization
                }

                if (deviceManager.devices.isEmpty) {
                  return Center(child: Text('Please add a device.'));
                }

                return GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two columns
                    crossAxisSpacing: mediaQuery.size.width * 0.01, // Horizontal spacing
                    mainAxisSpacing: mediaQuery.size.height * 0.001, // Vertical spacing
                  ),
                  itemCount: deviceManager.devices.length,
                  itemBuilder: (context, index) {
                    var device = deviceManager.devices[index];
                    return Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, mediaQuery.size.height * 0.02, 10, 0),
                      child: TentCard(
                        tentName: device['name'],
                        icon: Icons.portable_wifi_off,
                        iconColor: Colors.green,
                        status: device['id'],
                        name: device['name'],
                
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TentPage(name: device['name'] ?? ''),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class DeviceManager extends ChangeNotifier {
  Box? _deviceBox;  // Use nullable type for _deviceBox

  Box? get deviceBox => _deviceBox;

  List<Map<String, dynamic>> get devices {
    if (_deviceBox != null && _deviceBox!.isOpen) {
      return _deviceBox!.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  DeviceManager() {
    _initHive();
  }

  Future<void> _initHive() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Open the box for dynamic type storage
    _deviceBox = await Hive.openBox('devices');
    notifyListeners();
  }

  void onDeviceConnectionStatusChange(String deviceId, bool isOnline) {
    final device = _deviceBox?.get(deviceId);

    if (device != null) {
      // Update the status based on the connection state
      device['status'] = isOnline ? 'online' : 'offline';

      // Save the updated device status
      _deviceBox?.put(device['id'], device);
      notifyListeners();
    }
  }
 // Retrieve the ID for a given device name
  String? getDeviceIdByName(String name) {
    final device = _deviceBox?.get(name); // Lookup by name
    return device != null ? device['id'] as String? : null; // Return the ID if found
  }
  void addDevice(String name) {
    // Create a device object
    final device = {
      'id': DateTime.now().toString(),
      'name': name,
      'status': 'offline',
    };

    // Save the device into the Hive box
    _deviceBox?.put(device['name'], device);
    notifyListeners();
  }

  void removeDevice(String id) {
    // Remove the device by its ID
    _deviceBox?.delete(id);
    notifyListeners();
  }
}



class TentCard extends StatelessWidget {
  final String tentName;
  final IconData icon;
  final Color iconColor;
  final String status;
  //final String id;
  final String name;
  final VoidCallback onTap;

  const TentCard({
    Key? key,
    required this.tentName,
    required this.icon,
    required this.iconColor,
    required this.status,
    //required this.id,
    required this.name,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: mediaQuery.size.width * 0.46,
        height: mediaQuery.size.width * 0.46,
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
              alignment: const AlignmentDirectional(-0.40, -0.5),
              child: Text(
                tentName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: mediaQuery.size.width * 0.06,
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-0.09, 0.11),
              child: Icon(
                icon,
                color: iconColor,
                size: mediaQuery.size.width * 0.09,
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-0.09, 0.63),
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: mediaQuery.size.width * 0.06,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
