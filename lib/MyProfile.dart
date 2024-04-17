import 'package:flutter/material.dart';
import 'AddFood.dart';
import 'EditProfilePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfilePage extends StatefulWidget {
  final String userId;

  MyProfilePage({required this.userId});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _isHomemaker = false;
  bool _isAvailable = false; // New variable to track availability
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    print(widget.userId);
    super.initState();
    fetchUserData();
    checkHomemakerStatus();
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
          fetchUpdatedAvailability();
        }
      } else {
        throw Exception('Failed to check homemaker status');
      }
    } catch (error) {
      print('Error checking homemaker status: $error');
    }
  }

  // Function to fetch updated availability status
  Future<void> fetchUpdatedAvailability() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.7:3000/profile/${widget.userId}/availability'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isAvailable = data['isAvailable'];
        });
      } else {
        throw Exception('Failed to fetch updated availability status');
      }
    } catch (error) {
      print('Error fetching updated availability status: $error');
    }
  }

  Future<void> updateAvailability() async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://192.168.1.7:3000/profile/${widget.userId}/availability'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"isAvailable": !_isAvailable}),
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          _isAvailable = !_isAvailable;
        });
        fetchUpdatedAvailability(); // Call the function here
      } else {
        throw Exception('Failed to update availability status');
      }
    } catch (error) {
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
    bool confirmLogout = await showDialog(
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
              onPressed: () {
                 Navigator.of(context).popUntil((route) => route.isFirst); // Dismiss the dialog
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // Function to perform logout actions on frontend (clear session data, etc.)
  Future<void> performLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Clear session data or authentication tokens here
    await prefs.clear(); // Example: Clear all stored preferences
  }

  // Function to perform logout actions on backend
  Future<void> logoutBackend() async {
    try {
      final response = await http.get(
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
    // Check if user data is fetched
    if (_userData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: SingleChildScrollView(
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
                      'My Account',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    // Display user data
                    // Display user data
                    Text('First Name: ${_userData!['firstName']}'),
                    Text('Last Name: ${_userData!['lastName']}'),
                    Text('Address: ${_userData!['address']}'),
                    Text('Phone: ${_userData!['phone']}'),
                    Text('Email: ${_userData!['email']}'),
                    // Password field (hidden)
                    Text(
                        'Password: ${'*' * _userData!['password'].toString().length}'),
                    // Display Edit button
                    ElevatedButton(
                      onPressed: () async {
                        // Navigate to EditProfilePage
                        final updatedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              userId: widget.userId,
                              firstName: _userData!['firstName'],
                              lastName: _userData!['lastName'],
                              address: _userData!['address'],
                              phone: _userData!['phone'].toString(),
                              email: _userData!['email'],
                              password: _userData!['password'],
                            ),
                          ),
                        );
                        // Update state with the new data
                        setState(() {
                          _userData = updatedData;
                        });
                      },
                      child: Text('Edit'),
                    ),
                    // Display Availability button (if homemaker)
                    if (_isHomemaker)
                      ElevatedButton(
                        onPressed: () {
                          // Update availability
                          updateAvailability();
                        },
                        child: Text(_isAvailable ? 'Available' : 'Unavailable'),
                      ),
                    if (_isHomemaker)
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to AddFoodPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddFood(userId: widget.userId),
                            ),
                          );
                        },
                        child: Text('Add Food'),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: Color.fromARGB(255, 166, 67, 67)),
            ],
            // Settings Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  // Display Language setting
                  // Display Payment method setting
                  // Display Theme setting
                  // Display Delete Account button
                  ElevatedButton(
                    onPressed: () {
                      deleteAccount();
                    },
                    child: Text('Delete My Account'),
                  ),
                ],
              ),
            ),
            // Logout button
            ElevatedButton(
              onPressed: logout, // Call logout function when button is pressed
              child: Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
