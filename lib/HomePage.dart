import 'package:flutter/material.dart';
import 'MyProfile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

DateTime? currentBackPressTime;

class HomePage extends StatefulWidget {
  final String id;
  final bool isHomemaker;

  HomePage({required this.id, required this.isHomemaker});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Chef>> _futureChefs;
  double userRating = 0;
  List<String> ratedChefIds = [];

  @override
  void initState() {
    print(widget.id);
    super.initState();
    _futureChefs = getChefs();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureChefs = getChefs(); // Refresh chefs data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        title: Text('House Of Food'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyProfilePage(userId: widget.id),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (currentBackPressTime == null ||
              DateTime.now().difference(currentBackPressTime!) >
                  Duration(seconds: 2)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Press back again to exit'),
              ),
            );
            currentBackPressTime = DateTime.now();
            return false;
          }
          currentBackPressTime = null;
          return true;
        },
        child: RefreshIndicator(
          onRefresh: _refresh, // Call _refresh function when pulled down
          child: FutureBuilder(
            future: _futureChefs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<Chef> chefs = snapshot.data as List<Chef>;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: chefs.length,
                  itemBuilder: (context, index) {
                    Chef chef = chefs[index];
                    return GestureDetector(
                      onTap: () {},
                      child: Card(
                        color: Color.fromARGB(255, 162, 156, 156),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 50,
                              color: Color.fromARGB(255, 113, 21, 15),
                            ),
                            SizedBox(height: 10),
                            Text(
                              chef.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            SizedBox(width: 5),
                            Icon(
                              chef.isAvailable
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  chef.isAvailable ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<Chef>> getChefs() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.7:3000/register'));

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Chef> chefs = data.map((item) => Chef.fromJson(item)).toList();
      return chefs;
    } else {
      throw Exception('Failed to load chefs');
    }
  }

  // Fetch and show rating dialog
}

class Chef {
  final String id;
  final String name;
  final bool isAvailable;
  double averageRating;

  Chef({
    required this.id,
    required this.name,
    required this.isAvailable,
    this.averageRating = 0.0,
  });

  factory Chef.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Invalid JSON: json is null');
    }

    final String id = json['_id']?.toString() ?? '';
    final String firstName = json['firstName'] as String? ?? '';
    final String lastName = json['lastName'] as String? ?? '';
    final bool isAvailable = json['isAvailable'] as bool? ?? false;

    final String name = (firstName.isNotEmpty && lastName.isNotEmpty)
        ? '$firstName $lastName'
        : 'Unknown Chef';

    return Chef(
      id: id,
      name: name,
      isAvailable: isAvailable,
    );
  }
}
