abstract class SignalingRepository {
  Future<void> connect(String roomId, Function(String, dynamic) onMessage);
  void send(String event, dynamic data);
  void dispose();
}
