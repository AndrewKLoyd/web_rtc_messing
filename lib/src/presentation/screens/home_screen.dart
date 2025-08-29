import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/presentation/providers/room_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Rooms'),
      ),
      body: ListView.builder(
        itemCount: roomProvider.rooms.length,
        itemBuilder: (context, index) {
          final room = roomProvider.rooms[index];
          return ListTile(
            title: Text('Room: ${room.id}'),
            onTap: () => context.go('/room/${room.id}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final room = await roomProvider.createRoom();
          context.go('/room/${room.id}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
