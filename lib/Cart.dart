import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FoodPage.dart';

class CartPage extends StatefulWidget {
  final String userId;

  CartPage({required this.userId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    // Fetch cart items when the page loads
    fetchCartItems();
  }

 Future<void> fetchCartItems() async {
  try {
    if (widget.userId == null) {
      print('User ID is null');
      return;
    }
    
    final url = Uri.parse('http://192.168.1.2:3000/cart?userId=${widget.userId}');
    final response = await http.get(url);
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      // Ensure responseData is not null and is a List
      if (responseData != null && responseData is List) {
        print('Received data: $responseData');
        List<CartItem> cartItems = [];
        for (var item in responseData) {
          // Fetch the food item details based on the ID
          FoodItem foodItem = await fetchFoodItem(item['foodItemId']);
          // Create the cart item using _id as cartItemId
          cartItems.add(CartItem.fromJson(item, foodItem));
        }
        setState(() {
          _cartItems = cartItems;
        });
      } else {
        print('Invalid response format');
      }
    } else {
      throw Exception('Failed to fetch cart items');
    }
  } catch (e) {
    print('Error fetching cart items: $e');
  }
}


  Future<FoodItem> fetchFoodItem(String foodItemId) async {
    try {
      final url = Uri.parse('http://192.168.1.2:3000/food-items/$foodItemId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> foodJson = json.decode(response.body);
        return FoodItem.fromJson(foodJson);
      } else {
        throw Exception('Failed to fetch food item');
      }
    } catch (e) {
      print('Error fetching food item: $e');
      return FoodItem(
        id: '', // Provide default value for id
        chefId: '', // Provide default value for userId
        name: '', // Provide default value for name
        description: '', // Provide default value for description
        price: '', // Provide default value for price
        photo: '', // Provide default value for photo
      );
    }
  }

  void updateQuantity(String id, int newQuantity) async {
    try {
      final url = Uri.parse('http://192.168.1.2:3000/cart/$id');
      final response = await http.put(
        url,
        body: {'quantity': newQuantity.toString()},
      );
      if (response.statusCode == 200) {
        // Quantity updated successfully, refresh cart items
        fetchCartItems();
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var item in _cartItems) {
      try {
        totalPrice += double.parse(item.foodItem.price) * item.quantity;
      } catch (e) {
        // Handle the case where the price cannot be parsed
        print('Error parsing price for item: ${item.foodItem.name}');
        print('Price value: ${item.foodItem.price}');
        // You can choose to ignore this item or handle it differently based on your requirements
      }
    }
    return totalPrice;
  }

  void placeOrder() {
    // Implement placing order logic here
    // This could involve sending the cart items to the backend and clearing the cart
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
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                CartItem cartItem = _cartItems[index]; 
                FoodItem item = cartItem.foodItem;
                return ListTile(
                  leading: Image.network(
                    item.photo, 
                    width: 50, 
                    height: 50,
                    fit: BoxFit.cover, 
                       ),
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
                      if (cartItem.quantity > 1) {
                            // Decrease the quantity of the item in the cart if it's greater than 1
                            int newQuantity = cartItem.quantity - 1; // Decrease the quantity by 1
                            updateQuantity(cartItem.id, newQuantity); // Call the function to update the quantity
                          } else {
                            // If the quantity is already 1, you can choose to remove the item from the cart entirely
                            // Remove the selected item from the cart
                            // Cart.removeFromCart(cartItem.chefId, item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Item removed from cart'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            setState(() {});
                          }
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
                              // Increase the quantity of the item in the cart
    int newQuantity = cartItem.quantity + 1; // Increase the quantity by 1
    updateQuantity(cartItem.id, newQuantity); // Call the function to update the quantity
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
}

class CartItem {
  final String id;
  final String userId;
  final FoodItem foodItem;
  final int quantity;

  CartItem(
      {required this.id,
      required this.userId,
      required this.foodItem,
      required this.quantity});

 factory CartItem.fromJson(Map<String, dynamic> json, FoodItem foodItem) {
  return CartItem(
    id: json['_id'], // Assuming the ID is stored under the key '_id'
    userId: json['userId'],
    foodItem: foodItem,
    quantity: json['quantity'], // Assuming 'quantity' is a numeric value
  );
}
}

class FoodItem {
  final String id;
  final String chefId;
  final String name;
  final String description;
  final String price;
  final String photo;

  FoodItem({
    required this.id,
    required this.chefId,
    required this.name,
    required this.description,
    required this.price,
    required this.photo,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['_id'],
      chefId: json['chefId'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      photo: json['photo'],
    );
  }
}
