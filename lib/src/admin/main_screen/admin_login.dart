import 'package:app_attend/src/admin/main_screen/color_constant.dart';
import 'package:app_attend/src/admin/main_screen/reusable_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  RxBool isObscured = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: blue,
            borderRadius: BorderRadius.circular(12),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.blue.withOpacity(0.2),
            //     spreadRadius: 2,
            //     blurRadius: 4,
            //     offset: Offset(0, 2),
            //   ),
            // ],
          ),
          width: 450,
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Admin Login',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      formLabel('Username'),
                      SizedBox(height: 8.0),
                      myTextField('Enter your username', Icons.email, username,
                          usernameValidator),
                      SizedBox(height: 20.0),
                      formLabel('Password'),
                      SizedBox(height: 8.0),
                      Obx(() => myPasswordField('Insert password',
                              Icons.visibility, isObscured.value, () {
                            isObscured.value = !isObscured.value;
                          }, password, passwordValidator)),
                      SizedBox(height: 10.0),
                      Column(
                        children: [
                          myButton('Log in', blue, () {
                            if (username.text == 'admin' &&
                                password.text == 'admin1234') {
                              Get.offAllNamed('/dashboard');
                              Get.snackbar(
                                  'Success', 'Admin Login Successfully');
                            } else {
                              Get.snackbar('Error', 'Error while login');
                            }
                          }), // Call _loginUser
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
