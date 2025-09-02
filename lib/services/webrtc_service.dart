import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/foundation.dart';

class WebRTCService extends ChangeNotifier {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration, {});
  }

  Future<void> initiatePeerConnection(
    Function(dynamic) onIceCandidate,
    Function(MediaStream) onAddStream,
  ) async {
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      onIceCandidate(candidate.toMap());
    };

    _peerConnection!.onConnectionState = (state) {
      if (state != RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        return;
      }

      _peerConnection?.addStream(_localStream!);
      _localStream?.getTracks().forEach(
        (element) => _peerConnection?.addTrack(element, _localStream!),
      );
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
        onAddStream(_remoteStream!);
        notifyListeners();
      }
    };
  }

  Future<Map<String, dynamic>> createOffer() async {
    RTCSessionDescription description = await _peerConnection!.createOffer({
      'offerToReceiveVideo': 1,
    });
    await _peerConnection!.setLocalDescription(description);
    return description.toMap();
  }

  Future<Map<String, dynamic>> createAnswer() async {
    RTCSessionDescription description = await _peerConnection!.createAnswer({
      'offerToReceiveVideo': 1,
    });
    await _peerConnection!.setLocalDescription(description);
    return description.toMap();
  }

  Future<void> setRemoteDescription(dynamic sdp) async {
    RTCSessionDescription description = RTCSessionDescription(
      sdp['sdp'],
      sdp['type'],
    );
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<void> addCandidate(dynamic candidate) async {
    RTCIceCandidate rtcIceCandidate = RTCIceCandidate(
      candidate['candidate'],
      candidate['sdpMid'],
      candidate['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(rtcIceCandidate);
  }

  Future<void> openUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;
    if (_localStream == null) return;
    _localStream!.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    notifyListeners();
  }

  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    super.dispose();
  }
}
