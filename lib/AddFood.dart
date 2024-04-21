import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomePage.dart';

class AddFood extends StatefulWidget {
  final String userId;

  AddFood({
    required this.userId,
  });

  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  TextEditingController foodNameController = TextEditingController();
  TextEditingController foodDescriptionController = TextEditingController();
  TextEditingController foodPriceController = TextEditingController();
  TextEditingController foodPhotoController = TextEditingController();
  String selectedCategory = 'chicken'; // Default category
  List<String> categories = [
    'chicken',
    'pasta',
    'vegetables',
    'soup',
    'seafood',
    'dessert',
    'salad',
    'other',
  ];
  List<Map<String, dynamic>> foodList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Add Food',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 113, 21, 15),
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    showFoodInputDialog();
                  },
                  icon: Icon(Icons.add),
                  label: Text(
                    'Add Food',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 113, 21, 15),
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    // Add any customer-specific functionality here
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HomePage(id: widget.userId, isHomemaker: true),
                      ),
                    );
                  },
                  icon: Icon(Icons.home),
                  label: Text(
                    'Home',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Food Categories:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              buildFoodList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFoodList() {
    return Column(
      children: [
        for (var index = 0; index < foodList.length; index++)
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: Image.network(
                            foodList[index]['photo'],
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                    child: ClipOval(
                      child: Image.network(
                        foodList[index]['photo'],
                        width: 50,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${foodList[index]['category']}: ${foodList[index]['name']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Description: ${foodList[index]['description']}, Price: ${foodList[index]['price']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color.fromARGB(255, 113, 21, 15),
                    ),
                    onPressed: () {
                      showEditFoodDialog(
                        index,
                        widget.userId,
                        foodList[index],
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Color.fromARGB(255, 113, 21, 15),
                    ),
                    onPressed: () {
                      deleteFoodItem(foodList[index]['_id']);
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void showFoodInputDialog() {
    foodNameController.clear();
    foodDescriptionController.clear();
    foodPriceController.clear();
    foodPhotoController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Food',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                buildFoodInputDialog(
                  foodNameController,
                  foodDescriptionController,
                  foodPriceController,
                  foodPhotoController,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15),
                onPrimary: Colors.white,
              ),
              onPressed: () {
                if (foodNameController.text.isEmpty ||
                    foodDescriptionController.text.isEmpty ||
                    foodPriceController.text.isEmpty ||
                    foodPhotoController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please fill all fields.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  addFood(
                    foodNameController.text,
                    foodDescriptionController.text,
                    foodPriceController.text,
                    foodPhotoController.text,
                    selectedCategory,
                    widget.userId, // Pass userId here
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15),
                onPrimary: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget buildFoodInputDialog(
    TextEditingController foodNameController,
    TextEditingController foodDescriptionController,
    TextEditingController foodPriceController,
    TextEditingController foodPhotoController,
  ) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          "Food Name",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
          child: TextFormField(
            controller: foodNameController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ],
            decoration: InputDecoration(
              hintText: "Enter the Food Name",
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the food name';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 9),
        Text(
          "Food Description",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
          child: TextFormField(
            controller: foodDescriptionController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ],
            decoration: InputDecoration(
              hintText: "Enter the Food Description",
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the food description';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 9),
        Text(
          "Food Price",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
          child: TextFormField(
            controller: foodPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              hintText: "Enter the Food Price",
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the food price';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 9),
        Text(
          "Food Photo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
          child: TextFormField(
            controller: foodPhotoController,
            decoration: InputDecoration(
              hintText: "Add the Food photo",
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the food photo URL';
              }
              if (!Uri.parse(value).isAbsolute) {
                return 'Please enter a valid URL';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  void addFood(
    String name,
    String description,
    String price,
    String photo,
    String category,
    String userId,
  ) async {
    final url = Uri.parse('http://192.168.1.8:3000/food-items');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, dynamic>{
          'name': name,
          'description': description,
          'price': double.parse(price),
          'photo': photo,
          'category': category,
          'userId': userId, // Add userId to the request body
        },
      ),
    );

    if (response.statusCode == 201) {
      final addedFood = jsonDecode(response.body);
       final addedFoodId = addedFood['id']; // Retrieve the ID from the response
       print('Added food item ID: $addedFoodId');
      setState(() {
        foodList.add(addedFood);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in adding'),
          backgroundColor: Color.fromARGB(255, 245, 3, 3),
        ),
      );
    }
  }

  void showEditFoodDialog(
      int index, String userId, Map<String, dynamic> foodItem) {
    TextEditingController foodNameController =
        TextEditingController(text: foodList[index]['name']);
    TextEditingController foodDescriptionController =
        TextEditingController(text: foodList[index]['description']);
    TextEditingController foodPriceController =
        TextEditingController(text: foodList[index]['price'].toString());
    TextEditingController foodPhotoController =
        TextEditingController(text: foodList[index]['photo']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Food',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                buildFoodInputDialog(
                  foodNameController,
                  foodDescriptionController,
                  foodPriceController,
                  foodPhotoController,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15),
                onPrimary: Colors.white,
              ),
              onPressed: () {
                editFood(
                  foodList[index]['_id'],
                  index,
                  foodNameController.text,
                  foodDescriptionController.text,
                  foodPriceController.text,
                  foodPhotoController.text,
                  userId,
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15),
                onPrimary: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void editFood(
    String id, // Add id parameter
    int index,
    String name,
    String description,
    String price,
    String photo,
    String userId,
  ) async {
    final url = Uri.parse(
        'http://192.168.1.8:3000/food-items/$id'); // Use the received id
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, dynamic>{
          'userId': userId,
          'name': name,
          'description': description,
          'price': double.parse(price),
          'photo': photo,
        },
      ),
    );

    if (response.statusCode == 200) {
      final editedFood = jsonDecode(response.body);
      setState(() {
        foodList[index] = editedFood;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in saving'),
          backgroundColor: Color.fromARGB(255, 245, 3, 3),
        ),
      );
    }
  }

  void deleteFoodItem(String id) async {
    final bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this food item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed != null && deleteConfirmed) {
      final url = Uri.parse('http://192.168.1.8:3000/food-items/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          foodList.removeWhere((item) => item['_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Food item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting food item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.userId);
    fetchFoodItems(widget.userId);
  }

  void fetchFoodItems(String userId) async {
    final url = Uri.parse('http://192.168.1.8:3000/food-items?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      print('Received food items:');
      for (var item in data) {
        print('ID: ${item['_id']}');
        print('Name: ${item['name']}');
        // Print other fields as needed
      }
      setState(() {
        foodList = data.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in loading'),
          backgroundColor: Color.fromARGB(255, 245, 3, 3),
        ),
      );
    }
  }
}
