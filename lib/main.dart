import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/data/datasources/remote_data_source.dart';
import 'package:myapp/src/data/repositories/room_repository_impl.dart';
import 'package:myapp/src/data/repositories/signaling_repository_impl.dart';
import 'package:myapp/src/presentation/providers/call_provider.dart';
import 'package:myapp/src/presentation/providers/room_provider.dart';
import 'package:myapp/src/presentation/screens/call_screen.dart';
import 'package:myapp/src/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/room/:id',
      builder: (context, state) {
        final roomId = state.pathParameters['id']!;
        return ChangeNotifierProvider(
          create: (context) => CallProvider(
            SignalingRepositoryImpl(webSocketUrl: webSocketUrl),
            roomId,
            iceServers,
          ),
          child: CallScreen(roomId: roomId),
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RoomProvider(RoomRepositoryImpl())..loadRooms(),
        ),
      ],
      child: MaterialApp.router(
        title: 'WebRTC App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerConfig: _router,
      ),
    );
  }
}
