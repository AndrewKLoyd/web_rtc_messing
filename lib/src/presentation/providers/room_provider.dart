import 'package:flutter/material.dart';
import 'package:myapp/src/domain/entities/room.dart';
import 'package:myapp/src/domain/repositories/room_repository.dart';

class RoomProvider extends ChangeNotifier {
  final RoomRepository _roomRepository;
  List<Room> _rooms = [];

  RoomProvider(this._roomRepository);

  List<Room> get rooms => _rooms;

  Future<void> loadRooms() async {
    _rooms = await _roomRepository.getRooms();
    notifyListeners();
  }

  Future<Room> createRoom() async {
    final room = await _roomRepository.createRoom();
    await loadRooms();
    return room;
  }
}
