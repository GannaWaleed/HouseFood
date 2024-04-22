import 'package:flutter/material.dart';
import 'FoodPage.dart';
import 'HomePage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartPageold extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPageold> {
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
      ),
      body: Column(
        children: [
          // Display cart items here
          Expanded(
            child: ListView.builder(
              itemCount: Cart.items.length,
              itemBuilder: (context, index) {
                CartItem cartItem = Cart.items[index];
                FoodItem item = cartItem.foodItem;
                return ListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${item.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              // Remove the selected item from the cart
                            //  Cart.removeFromCart(cartItem.chefId, item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Item removed from cart'),
                                      duration: Duration(seconds: 1)));
                              setState(() {});
                            },
                          ),
                          Text(
                            'Quantity: ${cartItem.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              // Increase the quantity of the selected item
                              Cart.addToCart(context, cartItem.chefId, item);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Label to display the total price
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Price: ${calculateTotalPrice()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          // Button to place the order
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 113, 21, 15),
            ),
            onPressed: () {
              // Implement logic to place the order
              // This can involve sending an order to the backend, showing a confirmation dialog, etc.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order placed! , The Chef Will Contact You'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Place Order',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: const Color.fromARGB(255, 249, 249, 249),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchCartItems() async {
    final response = await http.get(Uri.parse('http://192.168.1.8:3000/cart'));
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        cartItems =
            responseData.map((item) => CartItem.fromJson(item)).toList();
      });
    } else {
      // If the server did not return a 200 OK response, throw an error.
      throw Exception('Failed to load cart items');
    }
  }

  // Future<void> addToCart(String chefId, int foodItemId) async {
  //   final response = await http.post(
  //     Uri.parse('http://192.168.1.8:3000/cart'),
  //     body: jsonEncode({
  //       'chefId': chefId,
  //       'foodItemId': foodItemId,
  //       'quantity': 1, // Default quantity
  //     }),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //   if (response.statusCode == 201) {
  //     // If the server returns a 201 Created response, fetch updated cart items
  //     fetchCartItems();
  //   } else {
  //     // If the server did not return a 201 Created response, show an error.
  //     throw Exception('Failed to add item to cart');
  //   }
  // }

  Future<void> removeFromCart(String chefId, int foodItemId) async {
    final response =
        await http.delete(Uri.parse('http://192.168.1.8:3000/$foodItemId'));
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, fetch updated cart items
      fetchCartItems();
    } else {
      // If the server did not return a 200 OK response, show an error.
      throw Exception('Failed to remove item from cart');
    }
  }

  Future<void> placeOrder() async {
    // Implement logic to place the order
    final response = await http.post(
      Uri.parse('http://192.168.1.8:3000/place-order'),
      // You can pass any necessary data for placing the order in the request body
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed! The Chef Will Contact You'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      throw Exception('Failed to place order');
    }
  }

  double calculateTotalPrice() {
    // Calculate the total price based on the prices of items in the cart
    double totalPrice = 0.0;
    for (CartItem cartItem in Cart.items) {
      totalPrice += double.parse(cartItem.foodItem.price) * cartItem.quantity;
    }
    return totalPrice;
  }
}

class Cart {
  static List<CartItem> items = [];

  static void addToCart(
      BuildContext context, String chefId, FoodItem foodItem) {
    // Get the current user's chefId (you need to obtain this from your authentication or user management system)
    //String currentUserChefId = getCurrentUserChefId(); // Replace this with your actual logic

    // Check if the cart is empty or if the items in the cart belong to the same chef
    if (items.isEmpty || items.every((item) => item.chefId == chefId)) {
      // Check if the current user is trying to add an item from their own food page
      if (chefId == chefId) {
        // Show an error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chefs cannot order from their own food page'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Check if the item is already in the cart
        CartItem existingItem = items.firstWhere(
          (item) =>
              item.chefId == chefId && item.foodItem.name == foodItem.name,
          orElse: () => CartItem(chefId: chefId, foodItem: foodItem),
        );

        if (items.contains(existingItem)) {
          // If the item is already in the cart, increment the quantity
          existingItem.quantity++;
        } else {
          // If the item is not in the cart, add it
          items.add(existingItem);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item added to cart'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Display an error or prevent adding items from different chefs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add items from different chefs to the cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 
}

class CartItem {
  final String chefId;
  final FoodItem foodItem;
  int quantity;

  CartItem({required this.chefId, required this.foodItem, this.quantity = 1});
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      chefId: json['chefId'],
      foodItem: FoodItem.fromJson(json['foodItem']),
      quantity: json['quantity'],
    );
  }
}
