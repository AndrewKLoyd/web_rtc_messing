import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:myapp/src/presentation/providers/call_provider.dart';
import 'package:provider/provider.dart';

class CallScreen extends StatefulWidget {
  final String roomId;

  const CallScreen({super.key, required this.roomId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    super.initState();
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.roomId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(callProvider.localRenderer),
          ),
          Expanded(
            child: RTCVideoView(callProvider.remoteRenderer),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final callProvider = Provider.of<CallProvider>(context, listen: false);
          callProvider.createOffer();
        },
        child: const Icon(Icons.call),
      ),
    );
  }
}
