import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../navigation/custom_nav_bar.dart';
import 'profile/myaccount.dart';
import 'profile/security.dart';
import 'profile/about.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: const ProfilePage(),
      bottomNavigationBar: const CustomNavBar(currentIndex: 4),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<String?> fetchProfilePic() async {
    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final storage = const FlutterSecureStorage();

    try {
      final refreshToken = await storage.read(key: 'refreshToken');
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Token tidak ditemukan.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/users/profile'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['profilePic']; // Return URL gambar profil
      } else {
        throw Exception(
            'Gagal memuat profil. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return null; // Return null jika terjadi kesalahan
    }
  }

  Future<void> _logout(BuildContext context) async {
    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refreshToken');

    print('RefreshToken sebelum logout: $refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      _navigateToLogin(context);
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/v1/users/auth/sign-out'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        await storage
            .deleteAll(); // Hapus semua token (refreshToken & accessToken)
        _navigateToLogin(context); // Panggil fungsi navigasi
      } else if (response.statusCode == 401) {
        // Tangani token tidak valid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Token tidak valid. Silakan login ulang.')),
        );
        await storage.deleteAll(); // Hapus token jika tidak valid
        _navigateToLogin(context); // Panggil fungsi navigasi
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Logout gagal. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat logout: $e')),
      );
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/signin', // Pastikan route ini sesuai dengan definisi di main.dart
      (route) => false,
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    return (await showDialog(
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
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Ya'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        FutureBuilder<String?>(
          future: fetchProfilePic(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black12,
                child: CircularProgressIndicator(),
              );
            }

            // Jika ada error atau data kosong, tampilkan ikon default
            if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileImagePage(),
                    ),
                  );
                },
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black12,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.black54,
                  ),
                ),
              );
            }

            // Jika data gambar ada, tampilkan gambar
            final profilePicUrl = snapshot.data;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileImagePage(profilePicUrl: profilePicUrl),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black12,
                backgroundImage: NetworkImage(profilePicUrl!),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileImagePage(),
              ),
            );
          },
          child: const Text(
            'Lihat Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              MenuTile(
                title: 'Akun Saya',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyAccount()),
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
                  final shouldLogout = await _onBackPressed(context);
                  if (shouldLogout) {
                    await _logout(context);
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

// Show Image Profile

class ProfileImagePage extends StatefulWidget {
  final String? profilePicUrl;
  const ProfileImagePage({Key? key, this.profilePicUrl}) : super(key: key);

  @override
  State<ProfileImagePage> createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends State<ProfileImagePage> {
  final String baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? profilePicUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.profilePicUrl != null && widget.profilePicUrl!.isNotEmpty) {
      profilePicUrl = widget.profilePicUrl; // Gunakan URL dari argumen
      isLoading = false; // Tidak perlu memuat ulang data
    } else {
      setState(() {
        isLoading = false; // Tidak ada data untuk dimuat ulang
      });
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      setState(() {
        isLoading = true;
      });

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        setState(() {
          isLoading = false;
        });
        return; // Jika pengguna tidak memilih gambar
      }

      final File file = File(image.path);
      final refreshToken = await storage.read(key: 'refreshToken');

      // Dapatkan Signed URL
      final signedUrlResponse = await http.post(
        Uri.parse('$baseUrl/v1/users/profile/file/profile-pic/upload-url'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"fileName": "profile-pic.jpg"}),
      );

      if (signedUrlResponse.statusCode != 200) {
        throw Exception(
            'Gagal mendapatkan Signed URL. Status code: ${signedUrlResponse.statusCode}');
      }

      final signedUrl = jsonDecode(signedUrlResponse.body)['data']['signedUrl'];

      // Upload gambar ke Signed URL
      final uploadResponse = await http.put(
        Uri.parse(signedUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: file.readAsBytesSync(),
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception(
            'Gagal mengunggah gambar. Status code: ${uploadResponse.statusCode}');
      }

      // Simpan URL gambar di server
      final saveUrlResponse = await http.post(
        Uri.parse('$baseUrl/v1/users/profile/file/profile-pic/save-url'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"fileName": "profile-pic.jpg"}),
      );

      if (saveUrlResponse.statusCode == 200) {
        final newUrl = jsonDecode(saveUrlResponse.body)['data']['url'];

        // Perbarui state dengan URL baru
        setState(() {
          profilePicUrl = newUrl;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil diunggah!')),
        );
      } else {
        throw Exception('Gagal menyimpan URL gambar.');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah gambar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Gambar Profil",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(color: Colors.black54, width: 2),
                    ),
                    child: profilePicUrl != null && profilePicUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: CachedNetworkImage(
                              imageUrl: profilePicUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.person,
                                size: 120,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 120,
                            color: Colors.black54,
                          ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: pickAndUploadImage,
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
