import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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

  final List<MediaStream> remoteStreams = [];

  final constrains = {
    'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
  };

  Future<void> init() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    await getUserMedia();
    _connection = await createPeerConnection({
      'urls': 'stun.tagan.ru:3478',
    }, constrains);

    for (MediaStreamTrack track in _localStream?.getTracks() ?? []) {
      _connection.addTrack(track, _localStream!);
    }

    _signalingService.onOffer = _onOffer;
    _signalingService.onAnswer = _onAnswer;
    _signalingService.onCandidate = _onICECandidate;

    _connection.onIceCandidate = (candidate) {
      _signalingService.sendCandidate(target, candidate.toMap());
    };

    _connection.onTrack = (event) async {
      remoteStreams.addAll(event.streams);
      notifyListeners();
    };
  }

  Future<void> _onOffer(dynamic from, dynamic offer) async {
    target = from;
    await _connection.setRemoteDescription(
      RTCSessionDescription(offer["sdp"], offer["type"]),
    );
    final answer = await _connection.createAnswer(constrains);
    await _connection.setLocalDescription(answer);
    _signalingService.sendAnswer(target, answer.toMap());
  }

  Future<void> _onAnswer(String target, dynamic answer) async {
    await _connection.setRemoteDescription(
      RTCSessionDescription(answer["sdp"], answer["type"]),
    );
  }

  Future<void> _onICECandidate(String target, data) async {
    await _connection.addCandidate(
      RTCIceCandidate(data["candidate"], data["sdpMid"], data["sdpMLineIndex"]),
    );
  }

  Future<void> _createOffer() async {
    final offer = await _connection.createOffer(constrains);
    await _connection.setLocalDescription(offer);
    _signalingService.sendOffer(target, offer.toMap());
  }

  Future<void> getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      "video": {"width": 1280, "height": 720},
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
