import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

DateTime? currentBackPressTime;

class HomePage2 extends StatefulWidget {
  final String id;

  HomePage2({required this.id});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage2> {
  late Future<List<Chef>> _futureChefs;
  double userRating = 0;
  List<String> ratedChefIds = [];

  @override
  void initState() {
    super.initState();
    _futureChefs = getChefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        title: Text('House Of Food'),
        actions: [],
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
                            color: chef.isAvailable ? Colors.green : Colors.red,
                          ),
                          GestureDetector(
                            onTap: () {
                              showRatingDialog(chef.id);
                            },
                            child: Icon(Icons.star, size: 20),
                          ),
                          Text(
                            'Average Rating: ${chef.averageRating}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
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

      // Fetch and set average rating for each chef
      await Future.forEach(chefs, (chef) async {
        try {
          final averageRating = await getAverageRating(chef.id);
          chef.averageRating = averageRating;
        } catch (e) {
          // Handle error when fetching average rating fails
          print('Failed to fetch average rating for chef ${chef.id}: $e');
          chef.averageRating = 0.0; // Set default value for average rating
        }
      });
      return chefs;
    } else {
      throw Exception('Failed to load chefs');
    }
  }

  Future<double> getAverageRating(String chefId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.7:3000/chefAverageRating/$chefId'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final averageRating = jsonResponse['averageRating'];

      if (averageRating is int) {
        return averageRating.toDouble();
      } else if (averageRating is double) {
        return averageRating;
      } else {
        throw Exception('Invalid data type for average rating');
      }
    } else {
      throw Exception('Failed to fetch average rating for chef $chefId');
    }
  }

  Future<void> showRatingDialog(String chefId) async {
    try {
      final averageRating = await getAverageRating(chefId);

      if (chefId == widget.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You cannot rate yourself'),
          ),
        );
        return;
      }
      if (ratedChefIds.contains(chefId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have already rated this chef'),
          ),
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Rate Chef'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: userRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40.0,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      userRating = rating;
                    });
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Average Rating: $averageRating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: userRating == 0
                    ? null
                    : () async {
                        try {
                          await saveRating(chefId, userRating);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Rating saved successfully'),
                            ),
                          );
                          setState(() {
                            ratedChefIds.add(chefId);
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save rating'),
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                child: Text('Submit'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error showing rating dialog: $error');
    }
  }

  Future<void> saveRating(String chefId, double userRating) async {
    Map<String, dynamic> ratingData = {
      'rating': userRating,
      'chefId': chefId,
    };

    final response = await http.post(
      Uri.parse('http://192.168.1.7:3000/rateChef'),
      body: jsonEncode(ratingData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save rating');
    }
  }
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
