import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomePage.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isHomeMaker = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        title: Text(
          'Homemaker Registration',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the login page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                  controller: firstNameController,
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
                  controller: lastNameController,
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
                  controller: phoneController,
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
              Text(
                "ID",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: TextFormField(
                  controller: idController,
                  decoration: InputDecoration(
                      hintText: "Enter your ID",
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ID.';
                    } else if (containsLetters(value)) {
                      return 'Phone number should not contain letters';
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
                  controller: addressController,
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
                "Email",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      hintText: "Enter your Email",
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
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address.';
                    }
                    if (!value.endsWith('@gmail.com')) {
                      return 'Email must end with @gmail.com';
                    }
                    return null;
                  },
                ),
              ),
              Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      hintText: "Enter your Password",
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
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long.';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  //bool isHomeMaker = true;
                  if (_formKey.currentState!.validate()) {
                    try {
                      final response = await http.post(
                        Uri.parse('http://192.168.1.8:3000/register'),
                        body: {
                          'firstName': firstNameController.text.trim(),
                          'lastName': lastNameController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'id': idController.text.trim(),
                          'address': addressController.text.trim(),
                          'email': emailController.text.trim(),
                          'password': passwordController.text.trim(),
                          'isHomeMaker': isHomeMaker.toString(),
                          'isAvailable': true.toString(),
                        },
                      );

                      if (response.statusCode == 200) {
                        final Map<String, dynamic> responseData =
                            jsonDecode(response.body);
                        final chefid = responseData['userId'];

                        print('User ID: $chefid');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Registration successful'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        await Future.delayed(Duration(seconds: 3));

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  'Your account will be deleted after 24 hours if you don\'t add food items to your profile.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(
                                            id: chefid, isHomemaker: true),
                                      ),
                                    );
                                  },
                                  child: Text('Home Page'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context)
                          ..showSnackBar(
                            SnackBar(
                              content: Text('Registration failed!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                        ..showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 113, 21, 15),
                  ),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              // "I already have an account. Log in" button
              TextButton(
                onPressed: () {
                  // Navigate to the login page
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => LoginPage(),
                  //   ),
                  // );
                },
                child: Text(
                  'I already have an account. Log in',
                  style: TextStyle(
                    color: Color.fromARGB(255, 113, 21, 15),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool containsNumbers(String value) {
// Check if the string containsany numeric digits
  return RegExp(r'\d').hasMatch(value);
}

bool containsLetters(String value) {
  // Check if the string contains any letters
  return RegExp(r'[a-zA-Z]').hasMatch(value);
}
