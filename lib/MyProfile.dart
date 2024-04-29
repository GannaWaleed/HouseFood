import 'package:flutter/material.dart';
import 'Cart.dart';
import 'AddFood.dart';
import 'EditProfilePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order.dart';
import 'CurrentOrder.dart';
import 'FinishedOrder.dart';
import 'ProcessingOrder.dart';
import 'previousOrder.dart';

DateTime? currentBackPressTime;

class MyProfilePage extends StatefulWidget {
  final String userId;

  MyProfilePage({required this.userId});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _isHomemaker = false;
  bool _isAvailable = false; // New variable to track availability
  bool _updatedAvailable = false; // Initialize to some default value
  Map<String, dynamic>? _userData;

  _MyProfilePageState() {
    // Initialize _updatedAvailable after _isAvailable has been initialized
    _updatedAvailable = !_isAvailable;
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    checkHomemakerStatus();
    fetchAvailabilityStatus();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.7:3000/profile/${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          _userData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> checkHomemakerStatus() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.7:3000/profile/${widget.userId}/isHomemaker'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isHomemaker = data['isHomemaker'];
        });
        if (_isHomemaker) {
          // Fetch availability status if user is a homemaker
          fetchAvailabilityStatus();
        }
      } else {
        throw Exception('Failed to check homemaker status');
      }
    } catch (error) {
      print('Error checking homemaker status: $error');
    }
  }

  Future<void> fetchAvailabilityStatus() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.7:3000/profile/${widget.userId}/availability'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isAvailable = data['isAvailable'];
          print('Availability status: $_isAvailable');
        });
      } else {
        throw Exception('Failed to fetch availability status');
      }
    } catch (error) {
      print('Error fetching availability status: $error');
    }
  }

  Future<void> updateAvailability() async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://192.168.1.7:3000/profile/${widget.userId}/availability'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(
            {"isAvailable": _isAvailable}), // Send _isAvailable directly
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Parse the response JSON to extract the updated availability status
        final responseData = json.decode(response.body);
        final updatedAvailability = responseData['user']['isAvailable'];

        // Update the _isAvailable variable with the updated availability status
        setState(() {
          _isAvailable = updatedAvailability;
        });
      }
      // await fetchAvailabilityStatus();
      else {
        // Handle unsuccessful update
        throw Exception('Failed to update availability status');
      }
    } catch (error) {
      // Handle network or server errors
      print('Error updating availability status: $error');
    }
  }

  Future<void> deleteAccount() async {
    // Display a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Dismiss the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Send DELETE request to delete account
                try {
                  final response = await http.delete(
                    Uri.parse(
                        'http://192.168.1.7:3000/profile/${widget.userId}'),
                  );
                  if (response.statusCode == 200) {
                    // Account deleted successfully
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LoginPage()), // Navigate to Login.dart
                    );
                  } else {
                    throw Exception('Failed to delete account');
                  }
                } catch (error) {
                  print('Error deleting account: $error');
                }
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Function to handle logout
  Future<void> logout() async {
    // Show confirmation dialog
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log out'),
          content: Text('Log out from your account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Perform logout actions on frontend
                await performLogout();

                // Perform logout actions on backend
                await logoutBackend();

                // Navigate to login page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  ModalRoute.withName('/'),
                );
              },
              child: Text('Log out'),
            ),
          ],
        );
      },
    );

    // If user confirms logout, proceed with logout actions
    if (confirmLogout == true) {
      // Perform logout actions on frontend
      await performLogout();

      // Perform logout actions on backend
      await logoutBackend();

      // Navigate to login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        ModalRoute.withName('/'),
      );
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginPage()),
      // );
    }
  }

  // Function to perform logout actions on frontend (clear session data, etc.)
  Future<void> performLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Clear session data or authentication tokens here
    await prefs.remove('authToken'); // Example: Clear all stored preferences
  }

  // Function to perform logout actions on backend
  Future<void> logoutBackend() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7:3000/logout'),
      );

      if (response.statusCode == 200) {
        // Logout successful
        print('Logout successful');
      } else {
        // Handle logout error
        print('Error: Logout failed');
      }
    } catch (error) {
      // Handle network or server errors
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.userId != null);

    // Check if userId is null
    if (widget.userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('User ID is empty!'),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 113, 21, 15),
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'My Profile',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         NotificationPage(userId: widget.userId),
                //   ),
                // );
              },
            ),
            // My Orders section
            PopupMenuButton<String>(
              icon: Icon(Icons.shopping_basket, color: Colors.white),
              onSelected: (value) {
                // Handle the selection of different order-related actions
                if (value == 'my_current_orders') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          currentOrdersPage(userId: widget.userId),
                    ),
                  );
                } else if (value == 'previous_orders') {
                  // Navigate to current orders page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          previousOrdersPage(userId: widget.userId),
                    ),
                  );
                } else if (value == 'finished_orders' && _isHomemaker) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          finishedOrdersPage(chefId: widget.userId),
                    ),
                  );
                } else if (value == 'processing_orders' && _isHomemaker) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProcessingOrdersPage(chefId: widget.userId),
                    ),
                  );
                } else if (value == 'pending_orders' && _isHomemaker) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderPage(chefId: widget.userId),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (_isHomemaker)
                  PopupMenuItem<String>(
                    value: 'pending_orders',
                    child: Text('Pending Orders'),
                  ),
                if (_isHomemaker)
                  PopupMenuItem<String>(
                    value: 'processing_orders',
                    child: Text('Processing Orders'),
                  ),
                if (_isHomemaker)
                  PopupMenuItem<String>(
                    value: 'finished_orders',
                    child: Text('Finished Orders'),
                  ),
                PopupMenuItem<String>(
                  value: 'my_current_orders',
                  child: Text('My Current Orders'),
                ),
                PopupMenuItem<String>(
                  value: 'previous_orders',
                  child: Text('Completed Orders'),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: fetchUserData,
          child: ListView(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // My Account Section
                    if (_userData != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Account :',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 16),
                            // Display user data
                            Text('First Name : ${_userData!['firstName']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                )),
                            Text('Last Name : ${_userData!['lastName']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                )),
                            Text('Address : ${_userData!['address']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                )),
                            Text('Phone :  ${_userData!['phone']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                )),
                            Text('Email : ${_userData!['email']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                )),
                            // Password field (hidden)
                            Text(
                              'Password : ${'*' * 10}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            if (_isHomemaker) ...[
                              Row(
                                children: [
                                  Text(
                                    'Availability :',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Switch(
                                    value: _isAvailable,
                                    onChanged: (_updatedAvailable) {
                                      // Update availability
                                      updateAvailability();
                                    },
                                    activeColor: Colors
                                        .green, // Color when switch is ON (Available)
                                    inactiveThumbColor: Colors
                                        .grey, // Color when switch is OFF (Unavailable)
                                    activeTrackColor: Colors.green
                                        .shade100, // Color for the track when switch is ON (Available)
                                    inactiveTrackColor: Colors.grey
                                        .shade400, // Color for the track when switch is OFF (Unavailable)
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    _isAvailable
                                        ? 'Available Now'
                                        : 'Unavailable',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: _isAvailable
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    // Settings Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings :',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromARGB(255, 113, 21, 15),
                              ),
                              onPressed: () {
                                // Navigate to AddFoodPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddFood(chefId: widget.userId),
                                  ),
                                );
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
                          // Display Edit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromARGB(255, 113, 21, 15),
                              ),
                              onPressed: () async {
                                final updatedData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                      userId: widget.userId,
                                      firstName: _userData!['firstName'],
                                      lastName: _userData!['lastName'],
                                      address: _userData!['address'],
                                      phone: _userData!['phone'].toString(),
                                    ),
                                  ),
                                );
                                if (updatedData != null) {
                                  setState(() {
                                    _userData = updatedData;
                                  });
                                }
                              },
                              icon: Icon(Icons.edit),
                              label: Text(
                                'Edit your data',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          // Change Email Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromARGB(255, 113, 21, 15),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String currentEmail = '';
                                    String newEmail = '';
                                    return AlertDialog(
                                      title: Text(
                                        'Change Email',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            "Current Email",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0, bottom: 15.0),
                                            child: TextField(
                                              onChanged: (value) {
                                                currentEmail = value;
                                              },
                                              decoration: InputDecoration(
                                                  hintText: "Current Email",
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 2,
                                                          horizontal: 20),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(
                                                              210, 158, 158, 158))),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(202, 158, 158, 158)))),
                                            ),
                                          ),
                                          Text(
                                            "New Email",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0, bottom: 15.0),
                                            child: TextField(
                                              onChanged: (value) {
                                                newEmail = value;
                                              },
                                              decoration: InputDecoration(
                                                  hintText: "New Email",
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 2,
                                                          horizontal: 20),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(
                                                              210, 158, 158, 158))),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(202, 158, 158, 158)))),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Color.fromARGB(255, 113, 21, 15),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Color.fromARGB(255, 113, 21, 15),
                                            ),
                                          ),
                                          onPressed: () async {
                                            // Validate new email (Check if it has '@gmail.com')
                                                
                                            if (!newEmail
                                                .endsWith('@gmail.com')) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Enter Invalid Email'),
                                                ),
                                              );
                                              return;
                                            }
                                            final response = await http.put(
                                              Uri.parse(
                                                  'http://192.168.1.7:3000/changeEmail'),
                                              headers: {
                                                "Content-Type":
                                                    "application/json"
                                              },
                                              body: json.encode({
                                                "userId": widget.userId,
                                                "currentEmail": currentEmail,
                                                "newEmail": newEmail,
                                              }),
                                            );
                                            // Check the response status code
                                            if (response.statusCode == 200) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Email updated successfully'),
                                                ),
                                              );
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            } else {
                                              final responseBody =
                                                  json.decode(response.body);
                                              final errorMessage =
                                                  responseBody['message'];
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(errorMessage),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.email),
                              label: Text(
                                'Change Email',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromARGB(255, 113, 21, 15),
                              ),
                              onPressed: () {
                                // Show dialog for changing password
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String currentPassword = '';
                                    String newPassword = '';
                                    String confirmPassword = '';
                                    return AlertDialog(
                                      title: Text(
                                        'Change Password',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            "Current Password",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0, bottom: 15.0),
                                            child: TextField(
                                              obscureText: true,
                                              onChanged: (value) {
                                                currentPassword = value;
                                              },
                                              decoration: InputDecoration(
                                                  hintText: "Current Password",
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 2,
                                                          horizontal: 20),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(
                                                              210, 158, 158, 158))),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(202, 158, 158, 158)))),
                                            ),
                                          ),
                                          Text(
                                            "New Password",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0, bottom: 15.0),
                                            child: TextField(
                                              obscureText: true,
                                              onChanged: (value) {
                                                newPassword = value;
                                              },
                                              decoration: InputDecoration(
                                                  hintText: "New Password",
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 2,
                                                          horizontal: 20),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(
                                                              210, 158, 158, 158))),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(202, 158, 158, 158)))),
                                            ),
                                          ),
                                          Text(
                                            "Confirm Password",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0, bottom: 15.0),
                                            child: TextField(
                                              obscureText: true,
                                              onChanged: (value) {
                                                confirmPassword = value;
                                              },
                                              decoration: InputDecoration(
                                                  hintText: "Confirm Password",
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 2,
                                                          horizontal: 20),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(
                                                              210, 158, 158, 158))),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: const Color.fromARGB(202, 158, 158, 158)))),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Color.fromARGB(255, 113, 21, 15),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Color.fromARGB(255, 113, 21, 15),
                                            ),
                                          ),
                                          onPressed: () async {
                                            // Validate password fields
                                            if (newPassword.length < 8 ||
                                                confirmPassword.length < 8) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Password must be at least 8 characters',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                ),
                                              );
                                              return;
                                            }
                                            if (newPassword !=
                                                confirmPassword) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Passwords do not match'),
                                                ),
                                              );
                                              return;
                                            }
                                            // Send request to backend to change password
                                            final response = await http.put(
                                              Uri.parse(
                                                  'http://192.168.1.7:3000/changePassword'),
                                              headers: {
                                                "Content-Type":
                                                    "application/json"
                                              },
                                              body: json.encode({
                                                "userId": widget.userId,
                                                "currentPassword":
                                                    currentPassword,
                                                "newPassword": newPassword,
                                              }),
                                            );
                                            if (response.statusCode == 200) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Password changed successfully'),
                                                ),
                                              );
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            } else {
                                              final responseBody =
                                                  json.decode(response.body);
                                              final errorMessage =
                                                  responseBody['message'];
                                              if (errorMessage ==
                                                  'Current password is incorrect') {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Current password is incorrect'),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Failed to change password'),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.lock),
                              label: Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromARGB(255, 113, 21, 15),
                              ),
                              onPressed: () {
                                deleteAccount();
                              },
                              icon: Icon(Icons.delete),
                              label: Text(
                                'Delete My Account',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromARGB(255, 113, 21, 15),
                              ),
                              onPressed: logout,
                              icon: Icon(Icons.logout),
                              label: Text(
                                'Log out',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Logout button
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
