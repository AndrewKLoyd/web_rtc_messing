import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final SignalingService _signalingService;
  late final WebRTCService _webRTCService;

  @override
  void initState() {
    super.initState();
    _signalingService = context.read<SignalingService>();
    _webRTCService = context.read<WebRTCService>();

    _signalingService.connect();

    _webRTCService.initialize();

    _signalingService.onOffer = (from, offer) async {
      await _webRTCService.initiatePeerConnection(
        (candidate) {
          _signalingService.sendCandidate(from, candidate);
        },
        (stream) {
          setState(() {});
        },
      );
      await _webRTCService.setRemoteDescription(offer);
      final answer = await _webRTCService.createAnswer();
      _signalingService.sendAnswer(from, answer);
      await _webRTCService.openUserMedia();
    };

    _signalingService.onAnswer = (from, answer) async {
      await _webRTCService.setRemoteDescription(answer);
    };

    _signalingService.onCandidate = (from, candidate) async {
      await _webRTCService.addCandidate(candidate);
    };
  }

  @override
  void dispose() {
    _webRTCService.dispose();
    _signalingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebRTC Call')),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _webRTCService,
              builder: (context, child) => Row(
                children: [
                  Expanded(child: RTCVideoView(_webRTCService.localRenderer)),
                  Expanded(child: RTCVideoView(_webRTCService.remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListenableBuilder(
              listenable: _signalingService,
              builder: (context, child) => Wrap(
                spacing: 8.0,
                children: _signalingService.clients
                    .where((clientId) => clientId != _signalingService.selfId)
                    .map(
                      (clientId) => ElevatedButton(
                        onPressed: () async {
                          await _webRTCService.initiatePeerConnection(
                            (candidate) {
                              _signalingService.sendCandidate(
                                clientId,
                                candidate,
                              );
                            },
                            (stream) {
                              setState(() {});
                            },
                          );
                          await _webRTCService.openUserMedia();
                          final offer = await _webRTCService.createOffer();
                          _signalingService.sendOffer(clientId, offer);
                        },
                        child: Text('Call $clientId'),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
