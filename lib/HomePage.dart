import 'package:flutter/material.dart';
import 'MyProfile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';
import 'FoodPage.dart';
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
      backgroundColor:Color.fromARGB(255, 113, 21, 15),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        title: Text('House Of Food'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () async {
              // Navigate to MyProfilePage and wait for result
              final updatedAvailability = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyProfilePage(userId: widget.id),
                ),
              );

              // Update the availability status of the corresponding Chef object
              if (updatedAvailability != null) {
                setState(() {
                  _futureChefs = getChefs(); // Refresh chefs data
                });
              }
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
                      onTap: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodPage(chef: chef, userId: widget.id ),
                          ),
                        );
                      },
                      child: ClipRRect(
        borderRadius: BorderRadius.circular(55),
                      child: Card(
                        color: Color.fromARGB(255, 235, 228, 228),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ignore: prefer_const_constructors
                            CircleAvatar( radius: 45,
  backgroundImage: Image.network(
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRi7bONcsBP6Q-6agm1uixCp6YT62CKyYdMRA&usqp=CAU').image,
),
                            SizedBox(height: 50),
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
                      )  );
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
    await http.get(Uri.parse('http://192.168.1.2:3000/register'));

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
}

class Chef {
  final String id;
  final String name;
  final bool isAvailable;

  Chef({
    required this.id,
    required this.name,
    required this.isAvailable,
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