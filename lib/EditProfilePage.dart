import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String address;
  final String phone;

  EditProfilePage({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phone,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _addressController = TextEditingController(text: widget.address);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color.fromARGB(255, 127, 37, 12),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "First Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: "Enter your First Name",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            color: const Color.fromARGB(210, 158, 158, 158))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            color: const Color.fromARGB(202, 158, 158, 158))),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name.';
                    } else if (containsNumbers(value)) {
                      return 'Name Should not contain number';
                    }
                    return null;
                  },
                ),
              ),
              Text(
                "Last Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                      hintText: "Enter your Last Name",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(210, 158, 158, 158))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color:
                                  const Color.fromARGB(202, 158, 158, 158)))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name.';
                    } else if (containsNumbers(value)) {
                      return 'Name Should not contain number';
                    }
                    return null;
                  },
                ),
              ),
              Text(
                "Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                      hintText: "Enter your Address",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(210, 158, 158, 158))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color:
                                  const Color.fromARGB(202, 158, 158, 158)))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address.';
                    }
                    return null;
                  },
                ),
              ),
              Text(
                "Phone",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                      hintText: "Enter your Phone",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(210, 158, 158, 158))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color:
                                  const Color.fromARGB(202, 158, 158, 158)))),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number.';
                    } else if (containsLetters(value)) {
                      return 'Phone number should not contain letters';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 127, 37, 12),
                ),
                onPressed: () {
                  // Save changes if form is valid
                  if (_formKey.currentState!.validate()) {
                    saveChanges();
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveChanges() async {
    // Get updated data from text controllers
    String updatedFirstName = _firstNameController.text;
    String updatedLastName = _lastNameController.text;
    String updatedAddress = _addressController.text;
    String updatedPhone = _phoneController.text;

    // Prepare the updated user data to send to the server
    Map<String, String> userData = {
      'firstName': updatedFirstName,
      'lastName': updatedLastName,
      'address': updatedAddress,
      'phone': updatedPhone,
    };

    // Send the updated user data to the server
    final response = await http.put(
      Uri.parse('http://192.168.1.4:3000/profile/${widget.userId}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(userData),
    );

    // Handle the response from the server
    if (response.statusCode == 200) {
      // Data updated successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved changes successfully'),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 500), // Set duration to 0.5 second
        ),
      );
      Navigator.pop(context); // Navigate back to MyProfilePage
    } else {
      // Failed to update data
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to save changes.'),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 127, 37, 12),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool containsNumbers(String value) {
// Check if the string containsany numeric digits
    return RegExp(r'\d').hasMatch(value);
  }

  bool containsLetters(String value) {
    // Check if the string contains any letters
    return RegExp(r'[a-zA-Z]').hasMatch(value);
  }
}
