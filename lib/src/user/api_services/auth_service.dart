import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  RxBool isLoggin = false.obs;

  // Helper function to get the IP address
  Future<String> getIPAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['ip'];
      } else {
        throw Exception('Failed to get IP address');
      }
    } catch (e) {
      return 'Unknown IP'; // Fallback if the IP cannot be fetched
    }
  }

  // Register user with Firebase Auth and store in Firestore
  Future<void> registerUser(
      String fullname, String email, String password, String phone) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Fetch the IP address
      String ipAddress = await getIPAddress();

      // Save user information to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullname': fullname.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': false, // Initial status set to offline
        'lastIPAddress': ipAddress,
      });

      // Log activity in Firestore
      await addOrUpdateActivityLog(userCredential.user!.uid, email, ipAddress,
          'Registered', 'User registered successfully.');

      showSuccess(message: 'Account created! Please verify your email.');
      Get.toNamed('/login'); // Navigate to the login page
    } catch (e) {
      showError(message: e.toString());
    }
  }

  // Login user with Firebase Auth
  Future<void> loginUser(String email, String password) async {
    try {
      isLoggin.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch the IP address
      String ipAddress = await getIPAddress();

      // Check if email is verified
      if (userCredential.user!.emailVerified) {
        // Update user status to online
        await updateUserStatus(userCredential.user!.uid, true, ipAddress);

        // Log activity in Firestore
        await addOrUpdateActivityLog(userCredential.user!.uid, email, ipAddress,
            'Online', 'User logged in successfully.');

        showSuccess(message: 'Logged in successfully!');
        Get.offAllNamed('/dashboard'); // Navigate to the dashboard page
      } else {
        // Sign out the user if email is not verified
        await _auth.signOut();
        showError(message: 'Please verify your email first!');
        isLoggin.value = false;
      }
    } catch (e) {
      showError(message: 'Incorrect Email or Password');
      isLoggin.value = false;
    }
  }

  // Resend email verification
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        showSuccess(message: 'Verification email sent!');
      }
    } catch (e) {
      showError(message: 'Failed to send verification email');
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        // Fetch the IP address
        String ipAddress = await getIPAddress();

        // Update user status to offline
        await updateUserStatus(currentUser!.uid, false, ipAddress);

        // Log activity in Firestore
        await addOrUpdateActivityLog(currentUser!.uid, currentUser!.email!,
            ipAddress, 'Offline', 'User logged out.');

        await _auth.signOut();
        showSuccess(message: 'User Logged out successfully!');
        Get.offAllNamed('/welcome'); // Navigate to the welcome page
      }
    } catch (e) {
      showError(message: 'An error occurred while logging out.');
    }
  }

  // Reset password for user
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      showSuccess(message: 'Password reset email sent! Check your inbox.');
    } catch (e) {
      showError(message: 'Please check your connection!');
    }
  }

  // Update user online/offline status in Firestore
  Future<void> updateUserStatus(
      String userId, bool isOnline, String ipAddress) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
        'lastIPAddress': ipAddress,
      });
    } catch (e) {
      showError(message: 'Failed to update user status.');
    }
  }

  // Log user activity in Firestore
  Future<void> addOrUpdateActivityLog(String userId, String email,
      String ipAddress, String action, String description) async {
    try {
      // Set or update the document in the activityLogs collection using the userId as the document ID
      await _firestore.collection('activityLogs').doc(userId).set(
          {
            'email': email.trim(),
            'ipAddress': ipAddress,
            'action': action,
            'description': description,
            'timestamp': FieldValue.serverTimestamp(),
          },
          SetOptions(
              merge:
                  true)); // Merge so existing data is not overwritten but updated
    } catch (e) {
      showError(message: 'Failed to log user activity.'); 
    }
  }
}
