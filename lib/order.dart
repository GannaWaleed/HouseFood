import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderPage extends StatefulWidget {
  final String chefId;

  const OrderPage({Key? key, required this.chefId}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse('http://192.168.1.9:3000/orders/${widget.chefId}/pending'));
    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      // Handle error
      print('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Orders'),
      ),
      body: orders.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Details:'),
                        Text('Name: ${order['userId']['firstName']} ${order['userId']['lastName']}'),
                        Text('Phone: ${order['userId']['phone']}'),
                        Text('Address: ${order['userId']['address']}'),
                        SizedBox(height: 8.0),
                        Text('Ordered Items:'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order['foodItems'].map<Widget>((foodItem) {
                            return Text(
                                '${foodItem['foodItemId']['name']} - Price: ${foodItem['foodItemId']['price']}, Quantity: ${foodItem['quantity']}');
                          }).toList(),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => acceptOrder(order['_id']),
                          child: Text('Accept'),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () => declineOrder(order['_id']),
                          child: Text('Decline'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> acceptOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.9:3000/orders/$orderId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'status': 'accepted',
      }),
    );
    if (response.statusCode == 200) {
      // Order accepted successfully, you can display a message or update UI as needed
      fetchOrders();
    } else {
      // Handle error
      print('Failed to accept order');
    }
  }

  Future<void> declineOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.9:3000/orders/$orderId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'status': 'declined',
      }),
    );
    if (response.statusCode == 200) {
      // Order declined successfully, you can display a message or update UI as needed
      fetchOrders();
    } else {
      // Handle error
      print('Failed to decline order');
    }
  }
}
