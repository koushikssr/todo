import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Dashboard/DashboardScreen.dart';
import 'DataBase.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      final List<Map<String, dynamic>> users = await dbHelper.getUsers();

      bool isLoggedIn = false;
      for (final user in users) {
        if (user['email'] == email && user['password'] == password) {
          isLoggedIn = true;
          break;
        }
      }

      if (isLoggedIn) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen(_emailController.text.toString())));
        Fluttertoast.showToast(msg: "Login in successfully");

        // Navigate to another screen or perform any other action
      } else {
        Fluttertoast.showToast(msg: "Invalid email or password");


      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                    child: Text("LOGIN",textAlign: TextAlign.center,style: TextStyle(fontSize: 28,color: Colors.black,fontWeight: FontWeight.bold),),
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

              GestureDetector(
                onTap: (){
                  _loginUser();

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
                        "Login",
                        style: TextStyle(fontSize: 18,color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),

              GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()));
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
                        style: TextStyle(fontSize: 18,color: Colors.white),
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
