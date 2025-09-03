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
    _webRTCService.init();
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
          ElevatedButton(onPressed: () {}, child: Text("Reinit")),
          Expanded(
            child: ListenableBuilder(
              listenable: _webRTCService,
              builder: (context, child) => ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    width: 500,
                    height: 500,
                    child: RTCVideoView(_webRTCService.localRenderer),
                  ),
                  ..._webRTCService.remoteStreams.map(
                    (e) => SizedBox(
                      width: 500,
                      height: 500,
                      child: Builder(
                        builder: (context) {
                          final renderer = RTCVideoRenderer();
                          return FutureBuilder(
                            future: Future<bool>(() async {
                              await renderer.initialize();
                              return true;
                            }),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }
                              renderer.srcObject = e;
                              return RTCVideoView(renderer);
                            },
                          );
                        },
                      ),
                    ),
                  ),
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
                        onPressed: () => _webRTCService.call(clientId),
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
