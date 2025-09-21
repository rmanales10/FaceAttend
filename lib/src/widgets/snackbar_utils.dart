import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Success snackbar
void showSuccess({
  required String message,
  String? title,
  Duration duration = const Duration(seconds: 3),
  SnackPosition position = SnackPosition.TOP,
}) {
  Get.snackbar(
    title ?? 'Success',
    message,
    backgroundColor: Colors.green.shade600,
    colorText: Colors.white,
    icon: const Icon(
      Icons.check_circle,
      color: Colors.white,
    ),
    duration: duration,
    snackPosition: position,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}

// Error snackbar
void showError({
  required String message,
  String? title,
  Duration duration = const Duration(seconds: 4),
  SnackPosition position = SnackPosition.TOP,
}) {
  Get.snackbar(
    title ?? 'Error',
    message,
    backgroundColor: Colors.red.shade600,
    colorText: Colors.white,
    icon: const Icon(
      Icons.error,
      color: Colors.white,
    ),
    duration: duration,
    snackPosition: position,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}

// Warning snackbar
void showWarning({
  required String message,
  String? title,
  Duration duration = const Duration(seconds: 3),
  SnackPosition position = SnackPosition.TOP,
}) {
  Get.snackbar(
    title ?? 'Warning',
    message,
    backgroundColor: Colors.orange.shade600,
    colorText: Colors.white,
    icon: const Icon(
      Icons.warning,
      color: Colors.white,
    ),
    duration: duration,
    snackPosition: position,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}

// Info snackbar
void showInfo({
  required String message,
  String? title,
  Duration duration = const Duration(seconds: 3),
  SnackPosition position = SnackPosition.TOP,
}) {
  Get.snackbar(
    title ?? 'Info',
    message,
    backgroundColor: Colors.blue.shade600,
    colorText: Colors.white,
    icon: const Icon(
      Icons.info,
      color: Colors.white,
    ),
    duration: duration,
    snackPosition: position,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}

// Custom snackbar
void showCustom({
  required String message,
  String? title,
  Color? backgroundColor,
  Color? textColor,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
  SnackPosition position = SnackPosition.TOP,
  EdgeInsets? margin,
  double? borderRadius,
  bool isDismissible = true,
  VoidCallback? onTap,
}) {
  Get.snackbar(
    title ?? '',
    message,
    backgroundColor: backgroundColor ?? Colors.grey.shade800,
    colorText: textColor ?? Colors.white,
    icon: icon != null
        ? Icon(
            icon,
            color: textColor ?? Colors.white,
          )
        : null,
    duration: duration,
    snackPosition: position,
    margin: margin ?? const EdgeInsets.all(16),
    borderRadius: borderRadius ?? 8,
    isDismissible: isDismissible,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
    onTap: onTap != null ? (_) => onTap() : null,
  );
}

// Loading snackbar (indefinite duration)
void showLoading({
  required String message,
  String? title,
  SnackPosition position = SnackPosition.TOP,
}) {
  Get.snackbar(
    title ?? 'Loading',
    message,
    backgroundColor: Colors.grey.shade800,
    colorText: Colors.white,
    icon: const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
    duration: const Duration(days: 1), // Indefinite duration
    snackPosition: position,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
    isDismissible: false,
  );
}

// Dismiss current snackbar
void dismissSnackbar() {
  Get.closeCurrentSnackbar();
}

// Dismiss all snackbars
void dismissAllSnackbars() {
  Get.closeAllSnackbars();
}

// Quick success messages for common actions
void loginSuccess() {
  showSuccess(message: 'Login successful!');
}

void logoutSuccess() {
  showSuccess(message: 'Logged out successfully!');
}

void registerSuccess() {
  showSuccess(message: 'Registration successful!');
}

void passwordResetSent() {
  showInfo(message: 'Password reset email sent!');
}

void attendanceMarked() {
  showSuccess(message: 'Attendance marked successfully!');
}

void profileUpdated() {
  showSuccess(message: 'Profile updated successfully!');
}

void dataSaved() {
  showSuccess(message: 'Data saved successfully!');
}

// Quick error messages for common issues
void loginError() {
  showError(message: 'Login failed. Please check your credentials.');
}

void networkError() {
  showError(message: 'Network error. Please check your connection.');
}

void validationError(String field) {
  showError(message: 'Please enter a valid $field.');
}

void permissionDenied() {
  showError(message: 'Permission denied. Please check app permissions.');
}

void somethingWentWrong() {
  showError(message: 'Something went wrong. Please try again.');
}
