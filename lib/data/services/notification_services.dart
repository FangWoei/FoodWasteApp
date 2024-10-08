import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final String _shownNotificationsKey = 'shown_expired_notifications';

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  Future<Set<String>> _getShownNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> shownNotifications =
        prefs.getStringList(_shownNotificationsKey) ?? [];
    return shownNotifications.toSet();
  }

  Future<void> _addShownNotification(String foodId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> shownNotifications =
        prefs.getStringList(_shownNotificationsKey) ?? [];

    if (!shownNotifications.contains(foodId)) {
      shownNotifications.add(foodId);
      await prefs.setStringList(_shownNotificationsKey, shownNotifications);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool isGroupSummary = false,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'food_expiry',
      'Food Expiry Notifications',
      channelDescription: 'Notifications for food expiration dates',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      groupKey: 'food_expiry_group',
      setAsGroupSummary: isGroupSummary,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> checkFoodExpiry(List<Food> foods) async {
    final shownNotifications = await _getShownNotifications();

    List<String> expiringFoods = [];
    List<String> expiredFoods = [];
    List<String> markedExpiredFoods = [];
    int notificationId = 1;

    for (var food in foods) {
      final foodId = food.id ?? '';

      if (food.state) {
        if (!shownNotifications.contains('${foodId}_marked')) {
          markedExpiredFoods.add(food.name);
          await showNotification(
            id: notificationId++,
            title: 'Food Expired Notification System',
            body: '${food.name} has been marked as expired',
          );
          await _addShownNotification('${foodId}_marked');
        }
      } else {
        final daysUntilExpiry =
            food.expiredDate.difference(DateTime.now()).inDays;

        if (daysUntilExpiry <= 7 && daysUntilExpiry > 0) {
          expiringFoods.add('${food.name} ($daysUntilExpiry days)');
          // We don't store "expiring soon" notifications as they should show daily
          await showNotification(
            id: notificationId++,
            title: 'Food Expired Notification System',
            body: '${food.name} will expire in $daysUntilExpiry days',
          );
        } else if (daysUntilExpiry <= 0 &&
            !shownNotifications.contains('${foodId}_expired')) {
          expiredFoods.add(food.name);
          await showNotification(
            id: notificationId++,
            title: 'Food Expired Notification System',
            body: '${food.name} has expired',
          );
          await _addShownNotification('${foodId}_expired');
        }
      }
    }

    // Show summary notifications
    if (expiringFoods.isNotEmpty) {
      await showNotification(
        id: notificationId++,
        title: 'Expiring Foods Summary',
        body: 'Foods expiring soon: ${expiringFoods.join(", ")}',
        isGroupSummary: true,
      );
    }

    if (expiredFoods.isNotEmpty) {
      await showNotification(
        id: notificationId++,
        title: 'Expired Foods Summary',
        body: 'Expired foods: ${expiredFoods.join(", ")}',
        isGroupSummary: true,
      );
    }

    if (markedExpiredFoods.isNotEmpty) {
      await showNotification(
        id: notificationId++,
        title: 'Marked Expired Foods Summary',
        body: 'Marked as expired: ${markedExpiredFoods.join(", ")}',
        isGroupSummary: true,
      );
    }
  }

  // Call this when a food item is deleted
  Future<void> removeNotificationRecord(String foodId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> shownNotifications =
        prefs.getStringList(_shownNotificationsKey) ?? [];

    shownNotifications.removeWhere(
        (id) => id == '${foodId}_expired' || id == '${foodId}_marked');

    await prefs.setStringList(_shownNotificationsKey, shownNotifications);
  }
}
