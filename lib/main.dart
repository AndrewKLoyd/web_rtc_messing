
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/signaling_service.dart';
import 'services/webrtc_service.dart';
import 'screens/call_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignalingService()),
        ChangeNotifierProvider(create: (_) => WebRTCService()),
      ],
      child: MaterialApp(
        title: 'Flutter WebRTC',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CallScreen(),
      ),
    );
  }
}
