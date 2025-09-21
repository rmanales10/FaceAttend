import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class ResetPassword extends StatefulWidget {
  String? email;
  ResetPassword({super.key, required this.email});

  @override
  // ignore: library_private_types_in_public_api
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final resetCode = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  RxBool isObscured = true.obs;

  Future<void> resetPassword() async {
    // await _authService.resetPassword(email.text);
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
                  'Recovery Password',
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
                        myDisabledField(
                          widget.email.toString(),
                          Icons.email,
                          resetCode,
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
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
