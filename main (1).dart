import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Received background message: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'MyAppInstance',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  runApp(FirebaseMessagingApp());
}

class FirebaseMessagingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Push Notifications Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: NotificationHomePage(title: 'Push Notifications'),
    );
  }
}

class NotificationHomePage extends StatefulWidget {
  final String title;
  const NotificationHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _NotificationHomePageState createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  late FirebaseMessaging firebaseMessaging;
  String? notificationContent;

  @override
  void initState() {
    super.initState();
    firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.subscribeToTopic("notifications");
    
    firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("New message received");
      print("Notification content: ${message.notification?.body}");
      print("Data payload: ${message.data.values}");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("New Notification"),
            content: Text(message.notification?.body ?? "No content"),
            actions: [
              TextButton(
                child: Text(
                  "Close",
                  style: TextStyle(
                      color: message.data.isEmpty ? Colors.green : Colors.red),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Notification clicked by user.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(child: Text("Welcome to the Firebase Messaging Demo")),
    );
  }
}
