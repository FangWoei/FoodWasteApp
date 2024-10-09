import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/repo/food_repo.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final NotificationService notificationService = NotificationService();
      await notificationService.initNotification();
      
      final FoodRepo foodRepo = FoodRepo();
      final foods = await foodRepo.getAllFoodsAsList();
      
      await notificationService.checkFoodExpiry(foods);
      return Future.value(true);
    } catch (e) {
      print("Error in background task: $e");
      return Future.value(false);
    }
  });
}

class NotificationService {
  static final NotificationService _notificationService = 
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  final String _shownNotificationsKey = 'shown_expired_notifications';
  static const String channelId = 'food_expiry_channel';
  static const String channelName = 'Food Expiry Notifications';
  static const String channelDescription = 
      'Notifications for food expiration dates';

  Future<void> initNotification() async {
    // Initialization code remains the same
  }

  Future<void> initBackgroundTask() async {
    // Background task initialization remains the same
  }

  Future<NotificationDetails> _notificationDetails() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final details = await _notificationDetails();
    await notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  Future<Set<String>> _getShownNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> shownNotifications =
        prefs.getStringList(_shownNotificationsKey) ?? [];
    return shownNotifications.toSet();
  }

  Future<void> _addShownNotification(String notificationKey) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> shownNotifications =
        prefs.getStringList(_shownNotificationsKey) ?? [];

    if (!shownNotifications.contains(notificationKey)) {
      shownNotifications.add(notificationKey);
      await prefs.setStringList(_shownNotificationsKey, shownNotifications);
    }
  }

  Future<void> removeNotificationRecord(String foodId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> shownNotifications =
        prefs.getStringList(_shownNotificationsKey) ?? [];

    shownNotifications.removeWhere((key) => key.startsWith(foodId));
    await prefs.setStringList(_shownNotificationsKey, shownNotifications);
  }

  Future<void> checkFoodExpiry(List<Food> foods) async {
    final shownNotifications = await _getShownNotifications();
    int notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    for (var food in foods) {
      final foodId = food.id ?? '';
      
      if (food.state) {
        // Handle marked as expired
        String notificationKey = '${foodId}_marked';
        if (!shownNotifications.contains(notificationKey)) {
          await showNotification(
            id: notificationId++,
            title: 'Food Expired',
            body: '${food.name} is marked as Finish',
          );
          await _addShownNotification(notificationKey);
        }
      } else {
        // Handle expiration date
        final daysUntilExpiry = food.expiredDate.difference(DateTime.now()).inDays;
        String notificationKey;
        String notificationBody;

        if (daysUntilExpiry < 0) {
          // Expired
          notificationKey = '${foodId}_expired_${daysUntilExpiry.abs()}';
          notificationBody = '${food.name} has expired ${daysUntilExpiry.abs()} days ago';
        } else if (daysUntilExpiry <= 7) {
          // Expiring soon
          notificationKey = '${foodId}_expiring_$daysUntilExpiry';
          notificationBody = '${food.name} will expire in $daysUntilExpiry days';
        } else {
          continue; // Skip if not expired or expiring soon
        }

        if (!shownNotifications.contains(notificationKey)) {
          await showNotification(
            id: notificationId++,
            title: daysUntilExpiry < 0 ? 'Food Expired' : 'Food Expiring Soon',
            body: notificationBody,
          );
          await _addShownNotification(notificationKey);
        }
      }
    }
  }
}