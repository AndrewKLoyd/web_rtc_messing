
import 'package:myapp/src/domain/entities/room.dart';
import 'package:myapp/src/domain/repositories/room_repository.dart';
import 'package:uuid/uuid.dart';

class RoomRepositoryImpl implements RoomRepository {
  final List<Room> _rooms = [];
  final Uuid _uuid = const Uuid();

  @override
  Future<Room> createRoom() async {
    final room = Room(id: _uuid.v4());
    _rooms.add(room);
    return room;
  }

  @override
  Future<List<Room>> getRooms() async {
    return _rooms;
  }
}
