import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:myapp/src/domain/repositories/signaling_repository.dart';

class CallProvider extends ChangeNotifier {
  final SignalingRepository _signalingRepository;
  final String _roomId;
  final Map<String, dynamic> _iceServers;

  RTCPeerConnection? _peerConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  CallProvider(this._signalingRepository, this._roomId, this._iceServers);

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _createPeerConnection();
    await _connectToSignaling();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers, {});
    _peerConnection!.onIceCandidate = (candidate) {
      _signalingRepository.send('ice', candidate.toMap());
    };
    _peerConnection!.onTrack = (event) {
      _remoteRenderer.srcObject = event.streams[0];
      notifyListeners();
    };

    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    _localRenderer.srcObject = stream;
    stream.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, stream);
    });
    notifyListeners();
  }

  Future<void> _connectToSignaling() async {
    await _signalingRepository.connect(_roomId, (event, data) async {
      switch (event) {
        case 'offer':
          final offer = RTCSessionDescription(data['sdp'], data['type']);
          await _peerConnection!.setRemoteDescription(offer);
          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);
          _signalingRepository.send('answer', answer.toMap());
          break;
        case 'answer':
          final answer = RTCSessionDescription(data['sdp'], data['type']);
          await _peerConnection!.setRemoteDescription(answer);
          break;
        case 'ice':
          final candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
          await _peerConnection!.addCandidate(candidate);
          break;
      }
    });
  }

  Future<void> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    _signalingRepository.send('offer', offer.toMap());
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.dispose();
    _signalingRepository.dispose();
    super.dispose();
  }
}
