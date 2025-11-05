import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'attendance', 'system', 'reminder', etc.
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'system',
      isRead: data['is_read'] ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: data['data'],
    );
  }
}

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxList<AppNotification> notifications = <AppNotification>[].obs;
  RxInt unreadCount = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    // Set up real-time listener for notifications
    _setupNotificationsListener();
  }

  void _setupNotificationsListener() {
    if (currentUser == null) return;

    _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: currentUser!.uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      notifications.value = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
      _updateUnreadCount();
    });
  }

  Future<void> fetchNotifications() async {
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: currentUser!.uid)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      notifications.value = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();

      _updateUnreadCount();
    } catch (e) {
      log('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = AppNotification(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          type: notifications[index].type,
          isRead: true,
          createdAt: notifications[index].createdAt,
          data: notifications[index].data,
        );
        _updateUnreadCount();
      }
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (currentUser == null) return;

    try {
      final unreadNotifications =
          notifications.where((n) => !n.isRead).toList();

      final batch = _firestore.batch();
      for (var notification in unreadNotifications) {
        final ref = _firestore.collection('notifications').doc(notification.id);
        batch.update(ref, {'is_read': true});
      }
      await batch.commit();

      // Update local state
      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = AppNotification(
            id: notifications[i].id,
            title: notifications[i].title,
            message: notifications[i].message,
            type: notifications[i].type,
            isRead: true,
            createdAt: notifications[i].createdAt,
            data: notifications[i].data,
          );
        }
      }
      _updateUnreadCount();
    } catch (e) {
      log('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      log('Error deleting notification: $e');
    }
  }

  // Create a notification (for system use)
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
        'data': data,
      });
    } catch (e) {
      log('Error creating notification: $e');
    }
  }
}
