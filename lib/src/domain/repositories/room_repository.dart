import 'package:myapp/src/domain/entities/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getRooms();
  Future<Room> createRoom();
}
