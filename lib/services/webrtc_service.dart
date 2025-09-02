import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:myapp/services/signaling_service.dart';

class WebRTCService extends ChangeNotifier {
  final SignalingService _signalingService;

  late final RTCPeerConnection _connection;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  String target = "";

  WebRTCService({required SignalingService signalingService})
    : _signalingService = signalingService;

  Future<void> call(String target) async {
    this.target = target;
    await _createOffer();
  }

  Future<void> init() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    await getUserMedia();
    _connection = await createPeerConnection({
      'urls': 'stun:stun.l.google.com:19302',
    }, {});

    for (MediaStreamTrack track in _localStream?.getTracks() ?? []) {
      _connection.addTrack(track, _localStream!);
    }

    _signalingService.onOffer = _onOffer;
    _signalingService.onAnswer = _onAnswer;
    _signalingService.onCandidate = _onICECandidate;

    _connection.onConnectionState = (state) async {
      print(state.name);
      if (state != RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        return;
      }

      notifyListeners();
    };
    _connection.onIceCandidate = (candidate) {
      _signalingService.sendCandidate(target, candidate.toMap());
    };
    _connection.onAddStream = (s) {
      print(s);
    };
    _connection.onAddTrack = (s, t) {
      print("s + t");
    };
    _connection.onAddTrack = (s, t) {
      notifyListeners();
    };

    _connection.onAddStream = (stream) {
      notifyListeners();
    };
    _connection.onTrack = (track) async {
      await remoteRenderer.initialize();
      remoteRenderer.srcObject = track.streams.first;
      notifyListeners();
    };
  }

  Future<void> _onOffer(dynamic from, dynamic offer) async {
    target = from;
    await _connection.setRemoteDescription(
      RTCSessionDescription(offer["sdp"], offer["type"]),
    );
    final answer = await _connection.createAnswer();
    await _connection.setLocalDescription(answer);
    // await _connection.setLocalDescription(answer);
    _signalingService.sendAnswer(target, answer.toMap());
  }

  Future<void> _onAnswer(String target, dynamic answer) async {
    await _connection.setRemoteDescription(
      RTCSessionDescription(answer["sdp"], answer["type"]),
    );
  }

  Future<void> _onICECandidate(String target, data) async {
    final RTCIceCandidate candidate = RTCIceCandidate(
      data["candidate"],
      data["sdpMid"],
      data["sdpMLineIndex"],
    );
    await _connection.addCandidate(candidate);
  }

  Future<void> _createOffer() async {
    final offer = await _connection.createOffer();
    await _connection.setLocalDescription(offer);
    _signalingService.sendOffer(target, offer.toMap());
  }

  Future<void> getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = _localStream;

    notifyListeners();
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    _connection.close();
    _connection.dispose();

    super.dispose();
  }
}
