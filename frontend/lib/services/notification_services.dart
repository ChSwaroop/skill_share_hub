import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/providers/user_provider.dart';

class CallNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final UserProvider? userProvider;

  CallNotificationService({this.userProvider});

  Future<void> initialize({
    required Function(String channelName, bool isVideo, String callerName)
        onCallReceived,
  }) async {
    // Request notification permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (details.payload != null) {
          final Map<String, dynamic> data = json.decode(details.payload!);
          if (data['type'] == 'call') {
            debugPrint("====================================================");
            debugPrint(
              "caller name: " + data['callerName'],
            );
            debugPrint(
              "channel name: " + data['channelName'],
            );
            debugPrint("====================================================");
            onCallReceived(
              data['channelName'],
              data['isVideo'] == 'true',
              data['callerName'],
            );
          }
        }
      },
    );

    // Configure FCM foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      if (message.data['type'] == 'call') {
        // Show incoming call notification
        _showCallNotification(
          message.data['channelName'] ?? '',
          message.data['isVideo'] == 'true',
          message.data['callerName'] ?? 'Unknown Caller',
        );
      }
    });

    // Configure FCM background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification when app was terminated and opened
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data['type'] == 'call') {
      onCallReceived(
        initialMessage.data['channelName'] ?? '',
        initialMessage.data['isVideo'] == 'true',
        initialMessage.data['callerName'] ?? 'Unknown Caller',
      );
    }

    // Handle notification click when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'call') {
        onCallReceived(
          message.data['channelName'] ?? '',
          message.data['isVideo'] == 'true',
          message.data['callerName'] ?? 'Unknown Caller',
        );
      }
    });

    // After getting the token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    debugPrint("calling to get token..........");
    String userId = userProvider?.user?.id ?? 'unknown-user';
    debugPrint("userId in notifications: " + userId);
    String username = userProvider?.user?.username ?? 'unknown-user';
    debugPrint("user name in notifications: " + username);

// Add this code to send token to your backend
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register-device'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'username': username,
          'fcmToken': token,
        }),
      );

      if (response.statusCode == 200) {
        print('Token successfully registered with backend');
      } else {
        print('Failed to register token with backend: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token to backend: $e');
    }

    // TODO: Send token to your backend server to associate with user
  }

  Future<void> _showCallNotification(
    String channelName,
    bool isVideo,
    String callerName,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'call_channel',
      'Calls',
      channelDescription: 'Notifications for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      sound: RawResourceAndroidNotificationSound('incoming_call'),
      playSound: true,
      enableLights: true,
      enableVibration: true,
      category: AndroidNotificationCategory.call,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'incoming_call.aiff',
      categoryIdentifier: 'call',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show the notification
    await _notificationsPlugin.show(
      0,
      isVideo ? 'Incoming Video Call' : 'Incoming Call',
      callerName,
      notificationDetails,
      payload: json.encode({
        'type': 'call',
        'channelName': channelName,
        'isVideo': isVideo.toString(),
        'callerName': callerName,
      }),
    );
  }

  // Get the device token (to send to your backend)
  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }
}

// Background handler must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print("Handling a background message: ${message.messageId}");

  // Initialize necessary services for background handling
  // Note: Keep this minimal as it runs in the background
}
