import 'package:flutter/material.dart';
import 'myaccount.dart';
import 'security.dart';
import 'about.dart';

void main() {
  runApp(const Profile());
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Color.fromARGB(221, 10, 96, 128),
        ),
        body: const ProfilePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // Function to exit
  Future<bool> _onBackPressed(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar dari aplikasi'),
            content: const Text('Apakah kamu ingin keluar dari aplikasi ini?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ya'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        // Image Profile
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black12,
          child: const Icon(
            Icons.person,
            size: 60,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileImagePage()),
            );
          },
          child: const Text(
            'Lihat Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        // Menu List
        Expanded(
          child: ListView(
            children: [
              MenuTile(
                title: 'Akun Saya',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
              ),
              MenuTile(
                title: 'Keamanan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PasswordChangeScreen()),
                  );
                },
              ),
              MenuTile(
                title: 'Tentang Kami',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
              MenuTile(
                title: 'Keluar',
                onTap: () async {
                  bool shouldExit = await _onBackPressed(context);
                  if (shouldExit) {
                    Navigator.of(context).pop(); // Keluar dari aplikasi
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Show Image Profile
class ProfileImagePage extends StatelessWidget {
  const ProfileImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Back Navigation
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Gambar Profil",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image Profile
            Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.black12,
                border: Border.all(color: Colors.black54, width: 2),
              ),
              child: const Icon(
                Icons.person,
                size: 120,
                color: Colors.black54,
              ),
            ),
            // Edit Image
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  // Action to change image profile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ganti gambar diimplementasikan di sini'),
                    ),
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget list menu
class MenuTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const MenuTile({Key? key, required this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
