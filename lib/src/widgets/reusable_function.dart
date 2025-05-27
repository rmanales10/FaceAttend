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

TextFormField myTextField(
    String label,
    IconData icon,
    TextEditingController controller,
    FormFieldValidator<String> validator,
    TextInputType inputType,
    String prefix) {
  return TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: inputType,
    decoration: InputDecoration(
      prefix: Text(prefix),
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

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an email';
  }
  // Simple regex for email format
  final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}

// Password validator function
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }

  return null;
}

String? fullNameValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your full name';
  }

  // Split the input by spaces
  List<String> nameParts = value.trim().split(' ');

  // Check if there are at least two words
  if (nameParts.length < 2) {
    return 'Please enter both first and last names';
  }

  // Check if each word starts with a capital letter (optional)
  for (String part in nameParts) {
    if (part.isEmpty || part[0] != part[0].toUpperCase()) {
      return 'Each name should start with a capital letter';
    }
  }

  return null; // Validation passed
}

String? phoneNumberValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number';
  }

  // Check if the input contains only digits
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'Phone number must contain only digits';
  }

  // Check if the length is exactly 11 digits
  if (value.length != 9) {
    return 'Phone number must be exactly 11 digits';
  }

  return null; // Validation passed
}
