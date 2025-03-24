import 'dart:io'; // Import for HttpOverrides
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../screens/video_room_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  // Allow insecure connections (for development only)
  HttpOverrides.global = MyHttpOverrides();

  try {
    await dotenv.load(
      fileName:
          "/Users/dana.gertsch/GitHub/flutter_projects/learn_flutter_webrtc/.env",
    );
    print("Environment variables loaded successfully.");
  } catch (e) {
    print("Failed to load environment variables: $e");
  }

  runApp(const ProviderScope(child: MyApp())); // Wrap the app in ProviderScope
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch values from .env
    final livekitUrl = dotenv.env['LIVEKIT_URL']!;
    final roomName = dotenv.env['LIVEKIT_ROOM_NAME']!;
    final participantName = dotenv.env['LIVEKIT_PARTICIPANT_NAME']!;
    final token = dotenv.env['LIVEKIT_TOKEN']!;

    return MaterialApp(
      title: 'LiveKit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VideoRoomScreen(
        livekitUrl: livekitUrl,
        roomName: roomName,
        participantName: participantName,
        token: token,
      ),
    );
  }
}
