import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String address;
  final String phone;
  final String password;

  EditProfilePage({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phone,
    required this.password,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _addressController = TextEditingController(text: widget.address);
    _phoneController = TextEditingController(text: widget.phone);
    _passwordController = TextEditingController(text: widget.password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
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
    String updatedPassword = _passwordController.text;

    // Prepare the updated user data to send to the server
    Map<String, String> userData = {
      'firstName': updatedFirstName,
      'lastName': updatedLastName,
      'address': updatedAddress,
      'phone': updatedPhone,
      'password': updatedPassword,
    };

    // Send the updated user data to the server
    final response = await http.put(
      Uri.parse('http://192.168.1.8:3000/profile/${widget.userId}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(userData),
    );

    // Handle the response from the server
    if (response.statusCode == 200) {
      // Data updated successfully
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
    _passwordController.dispose();
    super.dispose();
  }
}