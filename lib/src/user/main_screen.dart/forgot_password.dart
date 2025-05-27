import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_attend/src/user/api_services/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  RxBool isObscured = true.obs;
  final AuthService _authService = Get.put(AuthService());

  Future<void> resetPassword() async {
    if (formKey.currentState?.validate() == true) {
      await _authService.resetPassword(email.text);
      // Get.to(() => ResetPassword(email: email.text));
      Get.toNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  padding: EdgeInsets.all(24.0),
                  margin: EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        formLabel('Email'),
                        SizedBox(height: 8.0),
                        myTextField(
                            'Enter your email address',
                            Icons.email,
                            email,
                            emailValidator,
                            TextInputType.emailAddress,
                            ''),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      myButton('Reset Password', blue, resetPassword),
                      SizedBox(height: 10),
                      labelTap(context, 'Already have an account? ', 'Log in',
                          () => Get.toNamed('/login'))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
