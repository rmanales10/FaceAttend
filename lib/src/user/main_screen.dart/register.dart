import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RxBool isObscured = true.obs;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isTermsAccepted = false.obs; // RxBool for terms acceptance
  final AuthService _authService = Get.put(AuthService());
  final isClick = false.obs;

  void _registerUser() {
    if (_formKey.currentState?.validate() == true && isTermsAccepted.value) {
      _authService.registerUser(fullnameController.text, emailController.text,
          passwordController.text, '09${phoneController.text}');
      isClick.value = true;
    } else {
      Get.snackbar(
        'Error',
        'You must accept the Terms and Privacy Policy to register.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showTermsAndPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms and Privacy Policy'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Collection and Use: \n\n'
                  'In compliance with the Data Privacy Act of 2012 in the Philippines, personal data is collected, used, '
                  'and protected to uphold your privacy rights. Data is gathered for legitimate purposes and handled '
                  'lawfully, with consent obtained where necessary. Personal data will be accurate, relevant, and '
                  'stored only for as long as needed.\n\n'
                  'Your Rights: \n\n'
                  'As a data subject, you have the right to access, correct, or delete your personal data. You can also '
                  'obtain your data in a portable format, object to its processing for certain purposes, and withdraw your '
                  'consent at any time. Complaints can be lodged with the National Privacy Commission.\n\n'
                  'Security Measures: \n\n'
                  'We implement strong security measures to prevent unauthorized access or breaches of personal data. '
                  'Our organization is committed to aligning with international standards, including the EU’s GDPR, to '
                  'ensure transparency and trust in data management.\n\n'
                  'Data Protection Officer: \n\n'
                  'A dedicated Data Protection Officer is appointed to ensure compliance with data privacy regulations '
                  'and to address any concerns or inquiries related to personal data.\n\n'
                  'If you have any questions or concerns, please contact us at rmanales10@gmail.com.',
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                              'Full Name',
                              'Enter your full name',
                              Icons.person,
                              fullnameController,
                              fullNameValidator,
                              ''),
                          _buildTextField('Email', 'Enter your email',
                              Icons.email, emailController, emailValidator, ''),
                          _buildTextField(
                              'Phone Number',
                              'xxxxxxxxx',
                              Icons.phone,
                              phoneController,
                              phoneNumberValidator,
                              '09'),
                          _buildPasswordField(),
                          _buildTermsCheckbox(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                  Obx(
                    () => isClick.value
                        ? myButton('Signing Up...', blue, _registerUser)
                        : myButton('Sign Up', blue, _registerUser),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String textLabel,
      String label,
      IconData icon,
      TextEditingController controller,
      String? Function(String?) validator,
      String prefix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        formLabel(textLabel),
        myTextField(
            label, icon, controller, validator, TextInputType.text, prefix),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        formLabel('Password'),
        Obx(() => myPasswordField(
              'Insert password',
              Icons.visibility,
              isObscured.value,
              () => isObscured.value = !isObscured.value,
              passwordController,
              passwordValidator,
            )),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: isTermsAccepted.value,
            onChanged: (bool? value) {
              isTermsAccepted.value = value!;
            },
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms and Privacy Policy',
                  style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _showTermsAndPrivacyPolicyDialog,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      alignment: Alignment.center,
      child: labelTap(
        context,
        'Already have an account? ',
        'Log in',
        () => Get.toNamed('/login'),
      ),
    );
  }
}
