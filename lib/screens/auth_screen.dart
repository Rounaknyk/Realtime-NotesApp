import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'notes_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, this.isLogin = true});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Dio dio = Dio();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn(); // Check if the user is already logged in
  }

  // Check if the user is already logged in
  Future<void> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('uid');

    if (uid != null && uid.isNotEmpty) {
      // If the user is already logged in, navigate to the NotesScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotesScreen(userId: uid)),
      );
    }
  }

  // Save the user's UID locally
  Future<void> _saveUserIdLocally(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }

  // Clear the user's UID locally (for logout)
  Future<void> _clearUserIdLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
  }

  Future<void> authenticate() async {
    setState(() => isLoading = true);
    final String url = widget.isLogin
        ? '$kBaseUrl/login'
        : '$kBaseUrl/register';

    final Map<String, dynamic> data = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    if (!widget.isLogin) {
      data["name"] = nameController.text;
    }

    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final uid = response.data['user']["uid"];
        await _saveUserIdLocally(uid); // Save UID locally
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotesScreen(userId: uid)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Authentication failed"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isLogin ? "Login" : "Register"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!widget.isLogin)
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.isLogin ? "Login" : "Register",
                style: TextStyle(fontSize: 16, color: Colors.white,),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(isLogin: !widget.isLogin),
                  ),
                );
              },
              child: Text(
                widget.isLogin
                    ? "Don't have an account? Register"
                    : "Already have an account? Login",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}