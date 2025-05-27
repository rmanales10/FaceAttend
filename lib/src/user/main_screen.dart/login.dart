import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_attend/src/user/api_services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _isObscured = true.obs;

  final AuthService _authService = Get.put(AuthService());

  Future<void> _loginUser() async {
    if (_formKey.currentState?.validate() == true) {
      await _authService.loginUser(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildLoginForm(size),
                const SizedBox(height: 50),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Log in',
      style: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoginForm(Size size) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
              label: 'Email',
              hint: 'Enter your email address',
              icon: Icons.email,
              controller: _emailController,
              validator: emailValidator,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            Obx(
              () => _buildPasswordField(
                label: 'Password',
                hint: 'Insert password',
                controller: _passwordController,
                validator: passwordValidator,
                isObscured: _isObscured.value,
                toggleVisibility: () {
                  _isObscured.value = !_isObscured.value;
                },
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed('/forgot'),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        formLabel(label),
        const SizedBox(height: 8.0),
        myTextField(hint, icon, controller, validator, keyboardType, ''),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required bool isObscured,
    required VoidCallback toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        formLabel(label),
        const SizedBox(height: 8.0),
        myPasswordField(
          hint,
          Icons.visibility,
          isObscured,
          toggleVisibility,
          controller,
          validator,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Obx(
          () => myButton(
            _authService.isLoggin.value ? 'Logging in...' : 'Log in',
            blue,
            _loginUser,
          ),
        ),
        const SizedBox(height: 10),
        labelTap(
          context,
          "Don't have an account? ",
          'Create an Account',
          () => Get.toNamed('/register'),
        ),
      ],
    );
  }
}
