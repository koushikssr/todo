import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'DataBase.dart';
import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  bool _isObscure = true;


  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }


  Future<void> _registerUser() async {
    if (_formKey.currentState.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final Map<String, dynamic> user = {'email': email, 'password': password};

      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      final List<Map<String, dynamic>> existingUsers = await dbHelper.getUsers();

      bool isEmailRegistered = false;
      for (final existingUser in existingUsers) {
        if (existingUser['email'] == email) {
          isEmailRegistered = true;
          break;
        }
      }

      if (isEmailRegistered) {
        Fluttertoast.showToast(msg: "Email is already registered");
      } else {
        final int result = await dbHelper.saveUser(user);

        if (result != 0) {
          Fluttertoast.showToast(msg: "User registered successfully");

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          Fluttertoast.showToast(msg: "Failed to register user");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("REGISTER",textAlign: TextAlign.center,style: TextStyle(fontSize: 28,color: Colors.black,fontWeight: FontWeight.bold),),
                  )),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (String value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  // Regular expression for email validation
                  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: _isObscure,
                validator: (String value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (String value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),



              GestureDetector(
                onTap: (){
                  _registerUser();

                },
                child: Container(
                  width: 130,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Text(
                        "Register",
                        style: TextStyle(fontSize: 20,color: Colors.white),
                      ),
                    ),
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
