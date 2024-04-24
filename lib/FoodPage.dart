import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomePage.dart';
import 'Cart.dart';

class FoodPage extends StatelessWidget {
  final Chef chef;
  final String userId;

  FoodPage({required this.chef, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        title: Text('Food - ${chef.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(userId:userId),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: getFoodItems(chef.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<FoodItem> foodItems = snapshot.data!;
            return buildFoodItemsList(context, foodItems);
          }
        },
      ),
    );
  }

  Widget buildFoodItemsList(BuildContext context, List<FoodItem> foodItems) {
    return ListView.builder(
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        FoodItem foodItem = foodItems[index];
        return ListTile(
          leading: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                content: Image.network(
                  foodItem.photo,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
          child: CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(foodItem.photo),
          ),
        ),
        title: Text(
          foodItem.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
          subtitle: Text(
            'Description: ${foodItem.description}, Price: ${foodItem.price}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          trailing: SizedBox(
            width: 100.0,
            height: 40.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15),
              ),
              onPressed: () {
                addToCart(context, foodItem,userId);
              },
              child: Text('Buy'),
            ),
          ),
        );
      },
    );
  }

 void addToCart(BuildContext context, FoodItem foodItem,String loggedInuserId) async {
  try {
    // Check if the logged-in chef is trying to order their own food
    if (foodItem.chefId == loggedInuserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot order your own food'), backgroundColor: Colors.red,),
      );
      return;
    }
    final url = Uri.parse('http://192.168.1.9:3000/cart');
    final response = await http.post(
      url,
      body: {
        'userId': loggedInuserId,
        'foodItemId': foodItem.id.toString(),
        'quantity': '1', // Assuming initially adding one item
      },
    );
    print(loggedInuserId);
    if (response.statusCode == 201) {
  // Item added to cart successfully
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Item added to cart'),
          backgroundColor: Colors.green,),
  );
    } else {
      throw Exception('Failed to add item to cart');
    }
  } catch (e) {
    print('Error adding item to cart: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add item to cart'),
          backgroundColor: Colors.red,),
    );
  }
}


  Future<List<FoodItem>> getFoodItems(String? userId) async {
    // Update with your actual URL
    if (userId == null) {
      throw Exception('Chef ID is null');
    }
    try {
      final url = Uri.parse('http://192.168.1.9:3000/food?chefId=$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print(data);
        print(userId);
        print('Received food items:');
        for (var item in data) {
          print('ID: ${item['_id']}');
          print('Name: ${item['name']}');
          // Print other fields as needed
        }
         print(55555555);
        List<FoodItem> foodItems =
            data.map((item) => FoodItem.fromJson(item)).toList();
              print(666666666666);
        return foodItems;
      } else {
       
      print('Response body: ${response.body}');
        throw Exception('Failed to load food items');
      }
    } catch (e) {
       print('Error message: $e');
      throw Exception('Failed to load food items: $e');
    }
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
