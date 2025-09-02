import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'services/signaling_service.dart';
import 'services/webrtc_service.dart';
import 'screens/call_screen.dart';

final Map<String, dynamic> mediaConstraints = {
  'audio': true,
  'video': {'facingMode': 'user'},
};
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await navigator.mediaDevices.enumerateDevices();
  await navigator.mediaDevices.getUserMedia(mediaConstraints);
  runApp(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => MyApp())),
            child: Text("Go to call"),
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final signalingService = SignalingService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SignalingService>.value(value: signalingService),
        ChangeNotifierProvider(
          create: (_) => WebRTCService(signalingService: signalingService),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter WebRTC',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: CallScreen(),
      ),
    );
  }
}
