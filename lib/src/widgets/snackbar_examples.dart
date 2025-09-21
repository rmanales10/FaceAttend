import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'snackbar_utils.dart';

/// Example usage of snackbar utility functions
/// This file demonstrates how to use the snackbar utility functions

// Example 1: Basic usage
void basicExamples() {
  // Success message
  showSuccess(message: 'Operation completed successfully!');

  // Error message
  showError(message: 'Something went wrong!');

  // Warning message
  showWarning(message: 'Please check your input!');

  // Info message
  showInfo(message: 'New feature available!');
}

// Example 2: Custom snackbars
void customExamples() {
  // Custom snackbar with custom colors
  showCustom(
    message: 'Custom message',
    title: 'Custom Title',
    backgroundColor: Colors.purple,
    textColor: Colors.white,
    icon: Icons.star,
  );

  // Custom snackbar with custom duration and position
  showCustom(
    message: 'This will stay longer',
    duration: const Duration(seconds: 5),
    position: SnackPosition.BOTTOM,
    backgroundColor: Colors.teal,
  );
}

// Example 3: Quick action messages
void quickActionExamples() {
  // Quick success messages
  loginSuccess();
  attendanceMarked();
  profileUpdated();

  // Quick error messages
  loginError();
  networkError();
  validationError('email');
}

// Example 4: Loading and dismissal
void loadingExamples() {
  // Show loading snackbar
  showLoading(message: 'Processing your request...');

  // Later, dismiss it
  // dismissSnackbar();

  // Or dismiss all snackbars
  // dismissAllSnackbars();
}

// Example 5: In a widget context
Widget exampleButton() {
  return ElevatedButton(
    onPressed: () {
      showSuccess(
        message: 'Button pressed!',
        title: 'Action',
      );
    },
    child: const Text('Show Success Snackbar'),
  );
}

// Example 6: With error handling
void errorHandlingExample() {
  try {
    // Some operation that might fail
    // ... your code here ...

    showSuccess(message: 'Operation completed!');
  } catch (e) {
    showError(
      message: 'Operation failed: ${e.toString()}',
      title: 'Error',
    );
  }
}
