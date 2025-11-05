import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class NotificationService {
  // Semaphore API configuration
  static const String semaphoreApiUrl =
      'https://api.semaphore.co/api/v4/messages';
  static const String semaphoreApiKey =
      'c6743576f5f28b8c6d5e429813d8d6ce'; // TODO: Replace with actual API key
  static const String semaphoreSenderName = 'ABESO';

  // Gmail SMTP configuration
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String smtpUsername = 'faceattendofficial@gmail.com';
  static const String smtpPassword = 'fkwu rufy dbug infr';

  /// Send SMS notification using Semaphore API
  Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Format phone number (remove + and ensure it starts with country code)
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (!formattedNumber.startsWith('63')) {
        // If doesn't start with 63 (Philippines), add it
        if (formattedNumber.startsWith('0')) {
          formattedNumber = '63${formattedNumber.substring(1)}';
        } else {
          formattedNumber = '63$formattedNumber';
        }
      }

      // Semaphore API expects form data (application/x-www-form-urlencoded)
      final response = await http.post(
        Uri.parse(semaphoreApiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apikey': semaphoreApiKey,
          'number': formattedNumber,
          'message': message,
          'sendername': semaphoreSenderName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('SMS sent successfully to $formattedNumber');
        return true;
      } else {
        log('Failed to send SMS: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error sending SMS: $e');
      return false;
    }
  }

  /// Send email notification using Gmail SMTP
  Future<bool> sendEmail({
    required String recipientEmail,
    required String subject,
    required String message,
  }) async {
    try {
      final smtpServer = gmail(smtpUsername, smtpPassword);

      final messageToSend = Message()
        ..from = Address(smtpUsername, 'FaceAttend System')
        ..recipients.add(recipientEmail)
        ..subject = subject
        ..html = message;

      await send(messageToSend, smtpServer);

      log('Email sent successfully to $recipientEmail');
      // If no exception was thrown, email was sent successfully
      return true;
    } catch (e) {
      log('Error sending email: $e');
      return false;
    }
  }

  /// Send attendance notification to multiple recipients
  Future<Map<String, bool>> sendAttendanceNotifications({
    required List<String> phoneNumbers,
    required List<String> emailAddresses,
    required String subject,
    required String section,
    required String date,
    required String teacherName,
    required int presentCount,
    required int absentCount,
    required int totalStudents,
  }) async {
    // Prepare SMS message
    String smsMessage =
        'Attendance submitted for $subject ($section) on $date. '
        'Present: $presentCount, Absent: $absentCount, Total: $totalStudents. '
        'Submitted by: $teacherName';

    // Prepare email message
    String emailSubject = 'Attendance Submitted - $subject';
    String emailMessage = '''
    <html>
      <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #3B5998;">Attendance Submission Notification</h2>
          <div style="background-color: #f4f4f4; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <p><strong>Subject:</strong> $subject</p>
            <p><strong>Section:</strong> $section</p>
            <p><strong>Date:</strong> $date</p>
            <p><strong>Teacher:</strong> $teacherName</p>
          </div>
          <div style="background-color: #e8f5e9; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h3 style="color: #2e7d32; margin-top: 0;">Attendance Summary</h3>
            <p><strong>Total Students:</strong> $totalStudents</p>
            <p><strong style="color: #4caf50;">Present:</strong> $presentCount</p>
            <p><strong style="color: #f44336;">Absent:</strong> $absentCount</p>
          </div>
          <p style="margin-top: 20px; color: #666; font-size: 12px;">
            This is an automated notification from FaceAttend System.
          </p>
        </div>
      </body>
    </html>
    ''';

    Map<String, bool> results = {
      'sms': false,
      'email': false,
    };

    // Send SMS to all phone numbers
    if (phoneNumbers.isNotEmpty) {
      bool smsSuccess = true;
      for (String phone in phoneNumbers) {
        if (phone.isNotEmpty) {
          bool sent = await sendSMS(phoneNumber: phone, message: smsMessage);
          if (!sent) smsSuccess = false;
        }
      }
      results['sms'] = smsSuccess;
    }

    // Send Email to all email addresses
    if (emailAddresses.isNotEmpty) {
      bool emailSuccess = true;
      for (String email in emailAddresses) {
        if (email.isNotEmpty && email.contains('@')) {
          bool sent = await sendEmail(
            recipientEmail: email,
            subject: emailSubject,
            message: emailMessage,
          );
          if (!sent) emailSuccess = false;
        }
      }
      results['email'] = emailSuccess;
    }

    return results;
  }
}
