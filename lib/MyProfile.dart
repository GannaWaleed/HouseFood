import 'package:flutter/material.dart';
import 'AddFood.dart';
import 'EditProfilePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          .get(Uri.parse('http://192.168.1.8:3000/profile/${widget.userId}'));
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
          'http://192.168.1.8:3000/profile/${widget.userId}/isHomemaker'));
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
          'http://192.168.1.8:3000/profile/${widget.userId}/availability'));
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
// Future<void> updateAvailability() async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse(
  //           'http://192.168.1.8:5000/profile/${widget.userId}/availability'),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode({"isAvailable": !_isAvailable}),
  //     );
  //     print('Response status code: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _isAvailable = !_isAvailable;
  //       });
  //       //fetchUpdatedAvailability(); // Call the function here
  //     } else {
  //       throw Exception('Failed to update availability status');
  //     }
  //   } catch (error) {
  //     print('Error updating availability status: $error');
  //   }
  // }
  Future<void> updateAvailability() async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://192.168.1.8:3000/profile/${widget.userId}/availability'),
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

  // void updateAvailability(bool newValue) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse(
  //           'http://192.168.1.8:5000/profile/${widget.userId}/availability'),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode({"isAvailable": newValue}),
  //     );

  //     if (response.statusCode == 200) {
  //       // Update availability status in the UI only after successful update in the backend
  //       setState(() {
  //         _isAvailable = newValue;
  //       });
  //     } else {
  //       // Handle unsuccessful update
  //       throw Exception(
  //           'Failed to update availability status. Status code: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     // Handle network or server errors
  //     print('Error updating availability status: $error');
  //   }
  // }

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
                        'http://192.168.1.8:3000/profile/${widget.userId}'),
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
        Uri.parse('http://192.168.1.8:3000/logout'),
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
    // // Check if user data is fetched
    // if (_userData == null) {
    //   return Center(child: CircularProgressIndicator());
    // }
    // Ensure userId is not null
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
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    // Display user data
                    Text('First Name: ${_userData!['firstName']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        )),
                    Text('Last Name: ${_userData!['lastName']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        )),
                    Text('Address: ${_userData!['address']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        )),
                    Text('Phone: ${_userData!['phone']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        )),
                    Text('Email: ${_userData!['email']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        )),
                    // Password field (hidden)
                    Text(
                        'Password: ${'*' * _userData!['password'].toString().length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        )),
                    // Display Edit button
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Color.fromARGB(255, 113, 21, 15)),
                      // Use the edit icon
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
                              password: _userData!['password'],
                            ),
                          ),
                        );
                        // Update state with the new data
                        if (updatedData != null) {
                          setState(() {
                            _userData = updatedData;
                          });
                        }
                      },
                    ),
                    // Display Availability button (if homemaker)
                    if (_isHomemaker) ...[
                      Row(
                        children: [
                          Text(
                            'Availability:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 10),
                          Switch(
                            value: _isAvailable,
                            onChanged: (_updatedAvailable) {
                              // Update availability
                              updateAvailability();
                            },
                            activeColor: Colors
                                .green, // Color when switch is ON (Available)
                            inactiveThumbColor:
                                Colors.grey, // Color when switch is OFF (Unavailable)
                            activeTrackColor: Colors.green
                                .shade100, // Color for the track when switch is ON (Available)
                            inactiveTrackColor: Colors.grey
                                .shade400, // Color for the track when switch is OFF (Unavailable)
                          ),
                          SizedBox(width: 10),
                          Text(
                            _isAvailable ? 'Available Now' : 'Unavailable',
                            style: TextStyle(
                                fontSize: 16,
                                color: _isAvailable ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 113, 21, 15),
                            onPrimary: Colors.white,
                          ),
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
                      Divider(height: 5, color: const Color.fromARGB(255, 135, 135, 135)),
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
                    'Settings',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  // Display Language setting
                  // Display Payment method setting
                  // Display Theme setting
                  // Display Delete Account button
                  SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 113, 21, 15),
                            onPrimary: Colors.white,
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
                            primary: Color.fromARGB(255, 113, 21, 15),
                            onPrimary: Colors.white,
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
    );
  }
}