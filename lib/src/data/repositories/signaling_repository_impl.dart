import 'package:myapp/src/domain/repositories/signaling_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SignalingRepositoryImpl implements SignalingRepository {
  final String webSocketUrl;
  WebSocketChannel? _channel;

  SignalingRepositoryImpl({required this.webSocketUrl});

  @override
  Future<void> connect(
    String roomId,
    Function(String, dynamic) onMessage,
  ) async {
    _channel = WebSocketChannel.connect(Uri.parse('$webSocketUrl/$roomId'));

    _channel!.stream.listen((message) {
      // Handle incoming messages and pass them to the onMessage callback
    });
  }

  @override
  void send(String event, dynamic data) {
    _channel?.sink.add('{"event": "$event", "data": $data}');
  }

  @override
  void dispose() {
    _channel?.sink.close();
  }
}
