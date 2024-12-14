import 'package:flutter/material.dart';
import '../pages/home.dart';
import '../pages/lawlist.dart';
import '../pages/lawyer.dart';
import '../pages/forum.dart';
import '../pages/profile.dart';

class NavBar extends StatefulWidget {
  final String firstName;

  const NavBar({required this.firstName});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    Home(),
    Lawlist(),
    Lawyer(),
    Forum(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //Panggil icons dengan assets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.firstName}'),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icons/icons8-home-50.png",
              width: 25,
              height: 25,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icons/icons8-literature-50.png",
              width: 25,
              height: 25,
            ),
            label: 'Laws',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icons/icons8-lawyer-50.png",
              width: 25,
              height: 25,
            ),
            label: 'Lawyers',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icons/icons8-forum-50.png",
              width: 25,
              height: 25,
            ),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icons/icons8-male-user-48.png",
              width: 25,
              height: 25,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Update the index
      ),
    );
  }
}
