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
    _cartItems.clear();
  }

  void clearCart() {
    setState(() {
      _cartItems.clear(); // Clear the cart items list
    });
  }

  Future<void> fetchCartItems() async {
    try {
      if (widget.userId == null) {
        print('User ID is null');
        return;
      }

      final url =
          Uri.parse('http://192.168.1.4:3000/cart?userId=${widget.userId}');
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
      final url = Uri.parse('http://192.168.1.4:3000/food-items/$foodItemId');
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

  void increaseQuantity(String id) async {
    try {
      final url = Uri.parse('http://192.168.1.4:3000/cart/increase/$id');
      final response = await http.patch(url);
      if (response.statusCode == 200) {
        // Quantity increased successfully, refresh cart items
        fetchCartItems();
      } else {
        throw Exception('Failed to increase quantity');
      }
    } catch (e) {
      print('Error increasing quantity: $e');
    }
  }

  void decreaseQuantity(String id) async {
    try {
      final url = Uri.parse('http://192.168.1.4:3000/cart/decrease/$id');
      final response = await http.patch(url);
      if (response.statusCode == 200) {
        // Quantity decreased successfully, refresh cart items
        fetchCartItems();
      } else if (response.statusCode == 404) {
        // Cart item not found, remove it from the local list
        setState(() {
          _cartItems.removeWhere((item) => item.id == id);
        });
      } else {
        throw Exception('Failed to decrease quantity');
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
    }
  }

  Future<void> deleteCartItem(String id) async {
    try {
      print('iam in deletcartitem');
      final url = Uri.parse('http://192.168.1.4:3000/cart/$id');
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print('Item deleted successfully');
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error deleting item: $e');
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

  Future<void> placeOrder() async {
    final orderData = {
      'chefId': _cartItems.first.foodItem.chefId,
      'userId': widget.userId,
      'foodItems': _cartItems.map((item) {
        return {
          'foodItemId': item.foodItem.id,
          'quantity': item.quantity,
        };
      }).toList(),
    };

    final response = await http.post(
      Uri.parse('http://192.168.1.4:3000/orders'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final orderId =
          responseData['_id']; // Assuming orderId is stored in the response
      final chefId =
          _cartItems.isNotEmpty ? _cartItems.first.foodItem.chefId : '';
      clearCart();
      print('Order placed successfully'); // Print success message
      print(
        'chefId : ',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed! The Chef Will Contact You'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Handle error
      print('Failed to place order. Status code: ${response.statusCode}');
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
         backgroundColor: Color.fromARGB(255, 127, 37, 12),
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchCartItems(), // Refresh when pulled down
        child: Column(
          children: [
            // Display cart items here
            Expanded(
              child: ListView.builder(
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  CartItem cartItem = _cartItems[index];
                  FoodItem item = cartItem.foodItem;
                 return Dismissible(
      key: Key(cartItem.id), // Unique key for each item
      direction: DismissDirection.endToStart, // Swipe direction
      background: Container(
        color: Colors.red, // Background color when swiping
         alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        // Remove the item from the cart when swiped
        deleteCartItem(cartItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item removed from cart'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child:ListTile(
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
                                  int newQuantity = cartItem.quantity -
                                      1; // Decrease the quantity by 1
                                  decreaseQuantity(cartItem
                                      .id); // Call the function to decrease the quantity
                                } else {
                                  // If the quantity is already 1, you can choose to remove the item from the cart entirely
                                  // Remove the selected item from the cart
                                  // Cart.removeFromCart(cartItem.chefId, item);
                                  deleteCartItem(cartItem
                                      .id); // Call the function to delete the item from the cart
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Item removeddd from cart'), // Display the message
                                      duration: Duration(
                                          seconds:
                                              1), // Set the duration of the SnackBar
                                    ),
                                  );
                                  setState(() {
                                    // Update the UI to reflect the changes
                                  });
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
                                //  int newQuantity = cartItem.quantity + 1; // Increase the quantity by 1
                                // Increase the quantity of the item in the cart
                                increaseQuantity(cartItem
                                    .id); // Call the function to increase the quantity// Call the function to update the quantity
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
                  //  primary:Color.fromARGB(255, 127, 37, 12),
                  ),
              onPressed: () {
                // Implement logic to place the order
                placeOrder();
                // This can involve sending an order to the backend, showing a confirmation dialog, etc.
               
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
