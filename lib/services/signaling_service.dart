
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SignalingService extends ChangeNotifier {
  IO.Socket? _socket;
  String? _selfId;
  List<String> _clients = [];
  Function(String from, dynamic offer)? onOffer;
  Function(String from, dynamic answer)? onAnswer;
  Function(String from, dynamic candidate)? onCandidate;

  String? get selfId => _selfId;
  List<String> get clients => _clients;

  void connect() {
    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('connected to signaling server');
      _selfId = _socket!.id;
      notifyListeners();
    });

    _socket!.on('clients', (data) {
      _clients = List<String>.from(data);
      _clients.remove(_selfId);
      notifyListeners();
    });

    _socket!.on('offer', (data) {
      if (onOffer != null) {
        onOffer!(data['from'], data['offer']);
      }
    });

    _socket!.on('answer', (data) {
      if (onAnswer != null) {
        onAnswer!(data['from'], data['answer']);
      }
    });

    _socket!.on('candidate', (data) {
      if (onCandidate != null) {
        onCandidate!(data['from'], data['candidate']);
      }
    });

    _socket!.onDisconnect((_) {
      print('disconnected from signaling server');
      _clients = [];
      notifyListeners();
    });
  }

  void register(String id) {
    _socket?.emit('register', id);
  }

  void sendOffer(String target, dynamic offer) {
    _socket?.emit('offer', {'target': target, 'offer': offer});
  }

  void sendAnswer(String target, dynamic answer) {
    _socket?.emit('answer', {'target': target, 'answer': answer});
  }

  void sendCandidate(String target, dynamic candidate) {
    _socket?.emit('candidate', {'target': target, 'candidate': candidate});
  }

  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
