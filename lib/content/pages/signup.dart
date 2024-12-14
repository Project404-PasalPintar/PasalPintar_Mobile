import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey, width: 1)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Daftar Akun',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Daftar dan Dapatkan Jawaban Hukum.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Nama Depan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Nama Belakang',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.visibility_off),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.visibility_off),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Daftar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          //Isi nanti
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 230, 230, 230),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: Image.asset(
                          "assets/logo/google.png",
                          width: 25,
                          height: 25,
                        ),
                        label: Text(
                          'Masuk dengan Google',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Sudah punya akun? ',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'Masuk',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                //   recognizer: TapGestureRecognizer()
                                //     ..onTap = () {
                                //       // Navigasi ke halaman Login
                                //       Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (context) => LoginPage(),
                                //         ),
                                //       );
                                //     },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
