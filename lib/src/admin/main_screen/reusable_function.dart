import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

ElevatedButton myButton(String label, Color color, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Colors.white,
          width: 2.0,
        ),
      ),
    ),
    child: Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
    ),
  );
}

TextFormField myTextField(String label, IconData icon,
    TextEditingController controller, FormFieldValidator<String> validator) {
  return TextFormField(
    controller: controller,
    validator: validator,
    decoration: InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
    ),
  );
}

TextFormField myDisabledField(
    String label, IconData icon, TextEditingController controller) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      enabled: false,
      hintText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
    ),
  );
}

Text formLabel(String label) {
  return Text(
    label,
    style: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
  );
}

TextFormField myPasswordField(
    String label,
    IconData icon,
    bool isObscured,
    VoidCallback onPressed,
    TextEditingController controller,
    FormFieldValidator<String> validator) {
  return TextFormField(
    validator: validator,
    controller: controller,
    obscureText: isObscured,
    decoration: InputDecoration(
      hintText: label,
      prefixIcon: Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
        onPressed: onPressed,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
    ),
  );
}

RichText labelTap(BuildContext context, String leftText, String rightText,
    VoidCallback onTap) {
  return RichText(
    text: TextSpan(
      text: leftText,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
      ),
      children: [
        TextSpan(
          text: rightText,
          style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = onTap,
        ),
      ],
    ),
  );
}

Container lineSpacer(Size size) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 20),
    width: size.width,
    color: blue,
    height: 1,
  );
}

String? usernameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter usernames';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }

  return null;
}
