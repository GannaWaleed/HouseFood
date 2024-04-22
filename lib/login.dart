import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chooser.dart';
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool isHomemaker = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 150.0, bottom: 200.00, left: 16.0, right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Image.asset('assets/cheflogo.png',),
              // Text(
              //   "House of food",
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 50,
              //     fontFamily: 'DancingScript',
              //     color: Color.fromARGB(255, 123, 9, 1),
              //   ),
              // ),
              SizedBox(height: 16),
              Text(
                "Email",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                        color: const Color.fromARGB(210, 158, 158, 158),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(202, 158, 158, 158),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {},
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: TextFormField(
                  controller: passwordController,
                  focusNode: _passwordFocus,
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
                        color: const Color.fromARGB(210, 158, 158, 158),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(202, 158, 158, 158),
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      child: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: _passwordFocus.hasFocus
                          ? Color.fromARGB(255, 113, 21, 15)
                          : Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  cursorColor: Colors.black,
                  validator: (value) {},
                ),
              ),
              SizedBox(height: 25),
              Builder(builder: (BuildContext context) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 113, 21, 15),
                    onPrimary: Colors.white,
                  ),
                  onPressed: () async {
                    // Perform login without Firebase authentication
                    final bool loggedIn = await checkCredentials(
                      emailController.text,
                      passwordController.text,
                    );
                    if (loggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Login successful'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                );
              }),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate to the chooser page when the user wants to register
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => chooser(),
                    ),
                  );
                },
                child: Text(
                  'Don\'t have an account ? Register now',
                  style: TextStyle(color: Color.fromARGB(255, 113, 21, 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> checkCredentials(String email, String password) async {
    try {
    final response = await http.post(
      Uri.parse('http://192.168.1.2:3000/login'),
      body: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        //final userId = responseData['userId'];
        // Login successful, navigate to HomePage2.dart
        final responseData = json.decode(response.body);
        final userId = responseData['userId'];
        final isHomemakerString = responseData['isHomemaker'];
        final isHomemaker = isHomemakerString == 'true';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(id: userId, isHomemaker: isHomemaker),
            //HomePage2(id: userId),
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect email or password'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to login. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
