import 'package:flutter/material.dart';
import 'package:flutter_application_final/TextToSpeech.dart';

class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavbar({super.key, 
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Get the width of the screen
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive icon size based on the screen width
    final double iconSize = screenWidth * 0.07;

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              // Announce the tap action for Profile
              TextToSpeech.speak('Profile tapped');
              onItemTapped(0);
            },
            onDoubleTap: () {
              // Navigate to Profile screen on double tap
              onItemTapped(0);
            },
            child: Icon(
              Icons.person_2_outlined,
              size: iconSize,
            ),
          ),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              // Announce the tap action for Notifications
              TextToSpeech.speak('Notifications tapped');
              //onItemTapped(1);
            },
            onDoubleTap: () {
              TextToSpeech.speak('Notifications screen');
              onItemTapped(1);
            },
            child: Icon(
              Icons.notifications_none,
              size: iconSize,
            ),
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              // Announce the tap action for Add
              TextToSpeech.speak('Add tapped');
              onItemTapped(2);
            },
            onDoubleTap: () {
              TextToSpeech.speak('Add screen');
              onItemTapped(2);
            },
            child: Icon(
              Icons.add,
              size: iconSize,
            ),
          ),
          label: 'Add',
        ),
      ],
      currentIndex: selectedIndex,
      unselectedItemColor: Colors.blueGrey,
      onTap: onItemTapped,
    );
  }
}
