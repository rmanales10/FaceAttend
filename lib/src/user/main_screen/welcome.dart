import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                width: double.infinity,
                height: screenHeight *
                    0.45, // Set height as a percentage of screen height
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      'TapAttend',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                    Flexible(
                      child: Image(
                        image: AssetImage('assets/logo.png'),
                        width:
                            screenWidth * 0.6, // Responsive width for the image
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Text(
                  '“Keep Your Classrooms Connected —\nAttendance Made Simple!”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Responsive font size
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: () => Get.offNamed('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth * 0.25, // Responsive horizontal padding
                    vertical:
                        screenHeight * 0.02, // Responsive vertical padding
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045, // Responsive font size
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.offNamed('/login'),
                child: Text(
                  'Log in',
                  style: TextStyle(
                    color: blue,
                    fontSize: screenWidth * 0.04, // Responsive font size
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
