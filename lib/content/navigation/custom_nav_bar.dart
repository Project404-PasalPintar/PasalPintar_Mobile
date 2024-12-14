import 'package:flutter/material.dart';
import '../pages/home.dart'; // Pastikan path sesuai jika Anda memindahkan file
import '../pages/lawlist.dart';
import '../pages/lawyer.dart';
import '../pages/forum.dart';
import '../pages/profile.dart';

class CustomNavBar extends StatefulWidget {
  final int currentIndex;

  const CustomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex; // Mulai dengan indeks yang diberikan
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi berdasarkan item yang dipilih
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Lawlist()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Lawyer()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Forum()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
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
    );
  }
}
