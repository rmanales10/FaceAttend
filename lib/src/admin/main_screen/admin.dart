
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreenForAdmin extends StatefulWidget {
  const LoginScreenForAdmin({super.key});

  @override
  State<LoginScreenForAdmin> createState() => _LoginScreenForAdminState();
}

class _LoginScreenForAdminState extends State<LoginScreenForAdmin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isLoggingIn = false.obs;

  // Error dialog for demonstration purposes only (no backend)
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // _isLoggingIn.value ? Get.offAll(() => AdminDashboard()) : null;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 1, 37, 66),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                height: 350,
                width: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _emailController,
                        hintText: "Email",
                        icon: Icons.email,
                        isPassword: false,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _passwordController,
                        hintText: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            _showErrorDialog('Please fill in both fields.');
                          } else {
                            _isLoggingIn.value = !_isLoggingIn.value;
                            if (_emailController.text == 'admin' &&
                                _passwordController.text == 'admin') {
                              Get.offAllNamed('/dashboard');
                            }
                          }
                        },
                        child: Obx(
                          () => Container(
                            height: 40,
                            width: 200,
                            decoration: BoxDecoration(
                              color: _isLoggingIn.value
                                  ? Colors.grey
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: _isLoggingIn.value
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black),
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        // ignore: deprecated_member_use
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
