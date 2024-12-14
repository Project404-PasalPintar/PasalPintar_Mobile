import 'package:flutter/material.dart';
import 'dart:convert';

class Lawlist extends StatefulWidget {
  @override
  _LawlistState createState() => _LawlistState();
}

class _LawlistState extends State<Lawlist> {
  List<Map<String, String>> _pasals = [];
  String _searchQuery = '';
  String? _expandedPasal; // Track expanded pasal

  @override
  void initState() {
    super.initState();
    _loadPasals();
  }

  Future<void> _loadPasals() async {
    final String jsonData = await DefaultAssetBundle.of(context)
        .loadString('lib/data/datapasal.json');
    Map<String, dynamic> parsedData = jsonDecode(jsonData);
    setState(() {
      _pasals = List<Map<String, String>>.from(
        parsedData['pasals'].map((pasal) => Map<String, String>.from(pasal)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredPasals = _pasals
        .where((pasal) => pasal['namePasal']!
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    String? previousHeader;

    return Scaffold(
      appBar: AppBar(
        title: Text("UUD 1945"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPasals.length,
              itemBuilder: (context, index) {
                final pasal = filteredPasals[index];
                final currentHeader = pasal['namaUUD'];

                // Periksa apakah header berubah
                bool showHeader = currentHeader != previousHeader;
                previousHeader = currentHeader;

                final isExpanded = _expandedPasal == pasal['nomorPasal'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          currentHeader!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Column(
                        children: [
                          ListTile(
                            //Memberikan padding pada kolom dropdown
                            // title: Padding(
                            //   padding: EdgeInsets.only(
                            //     top: 16.0, // Jarak atas
                            //     bottom: 8.0, // Jarak bawah
                            //     left: 12.0, // Jarak kiri
                            //     right: 20.0, // Jarak kanan
                            //   ),
                            //   child: Text(
                            //     pasal['namePasal']!,
                            //     style: TextStyle(fontWeight: FontWeight.bold),
                            //   ),
                            // ),
                            //Tanpa atur pading
                            title: Text(
                              pasal['namePasal']!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down),
                            onTap: () {
                              setState(() {
                                _expandedPasal =
                                    isExpanded ? null : pasal['nomorPasal'];
                              });
                            },
                          ),
                          if (isExpanded)
                            Padding(
                              // padding: const EdgeInsets.all(16.0), //Semua sisi
                              padding: EdgeInsets.only(
                                top: 0.0, // Jarak atas
                                bottom: 8.0, // Jarak bawah
                                left: 12.0, // Jarak kiri
                                right: 12.0, // Jarak kanan
                              ),
                              child: Text(pasal['isiPasal']!),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
