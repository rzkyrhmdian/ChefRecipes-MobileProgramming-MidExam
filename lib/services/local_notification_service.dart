import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // uses default app icon
      [
        NotificationChannel(
          channelGroupKey: 'recipe_channel_group',
          channelKey: 'chef_recipes_channel',
          channelName: 'Chef Recipes Notifications',
          channelDescription: 'Reminder notifications for cooking activities',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'recipe_channel_group',
          channelGroupName: 'Recipe Group',
        )
      ],
      debug: true,
    );

    // Set Listeners so tapping notification opens app (Default routing logic)
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );

    // Request permissions if not already allowed
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Tapping automatically opens the app by default for AwesomeNotifications.
    // If you need custom navigation: MyApp.navigatorKey.currentState?.pushNamed('/some-page');
  }

  Future<void> showInstantTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1001,
        channelKey: 'chef_recipes_channel',
        title: 'Chef Recipes',
        body: 'Time to cook your favorite recipe!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> scheduleReminderAfterSeconds(int seconds) async {
    // For specific seconds scheduling
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1002,
        channelKey: 'chef_recipes_channel',
        title: 'Chef Recipes Reminder',
        body: 'Check today’s Chef Recipes ideas!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationInterval(
        interval: Duration(seconds: seconds),
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: false,
      ),
    );
  }

  Future<void> scheduleDailyReminder() async {
    // We can fulfill the requested daily reminder texts:
    // Request string: "Don't forget dinner prep at 5 PM"
    
    // Morning reminder at 08:00
    await _scheduleForHour(
      id: 1003,
      hour: 8,
      title: 'Good Morning Chef! 🍳',
      body: 'Check today’s Chef Recipes ideas!',
    );
    // Evening reminder at 17:00 (5 PM)
    await _scheduleForHour(
      id: 1004,
      hour: 17,
      title: 'Dinner Time! 🍲',
      body: "Don't forget dinner prep at 5 PM",
    );
  }

  Future<void> _scheduleForHour({
    required int id,
    required int hour,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'chef_recipes_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: 0,
        second: 0,
        millisecond: 0,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true,
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
