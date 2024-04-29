import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class finishedOrdersPage extends StatefulWidget {
  final String chefId;

  const finishedOrdersPage({Key? key, required this.chefId}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<finishedOrdersPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.4:3000/orders/${widget.chefId}/finished'));
    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      // Handle error
      print('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    final response =
        await http.get(Uri.parse('http://192.168.1.4:3000/register/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Handle error
      print('Failed to load user details: ${response.statusCode}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchFoodItemDetails(
      dynamic foodItemId) async {
    final response = await http
        .get(Uri.parse('http://192.168.1.4:3000/food-items/$foodItemId'));
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      if (jsonResponse is List) {
        // If jsonResponse is already a list, return it directly
        return jsonResponse.cast<Map<String, dynamic>>();
      } else {
        // If jsonResponse is not a list, wrap it in a list
        return [jsonResponse].cast<Map<String, dynamic>>();
      }
    } else {
      // Handle error
      print('Failed to load food item details: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 127, 37, 12),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Finished Orders',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshOrders,
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return FutureBuilder(
              future: fetchUserDetails(order['userId']),
              builder:
                  (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final userDetails = snapshot.data;
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User Details:',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w600),
                              ),
                              if (userDetails != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name: ${userDetails['firstName']} ${userDetails['lastName']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Phone: ${userDetails['phone']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Address: ${userDetails['address']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 8.0),
                              Text('Ordered Items:',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var foodItem in order['foodItems'])
                                    FutureBuilder(
                                      future: fetchFoodItemDetails(
                                          foodItem['foodItemId']),
                                      builder: (context,
                                          AsyncSnapshot<
                                                  List<Map<String, dynamic>>?>
                                              foodItemSnapshot) {
                                        if (foodItemSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (foodItemSnapshot.hasError) {
                                          return Text(
                                              'Error: ${foodItemSnapshot.error}');
                                        } else {
                                          final foodItemDetails =
                                              foodItemSnapshot.data;
                                          if (foodItemDetails != null &&
                                              foodItemDetails.isNotEmpty) {
                                            final name =
                                                foodItemDetails[0]['name'];
                                            final price =
                                                foodItemDetails[0]['price'];
                                            final quantity =
                                                foodItem['quantity'];
                                            return Text(
                                              '$name - Price: $price, Quantity: $quantity',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                            );
                                          } else {
                                            return Text(
                                                'Food item details not found');
                                          }
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
