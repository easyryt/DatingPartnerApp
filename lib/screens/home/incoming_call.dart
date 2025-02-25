import 'package:flutter/material.dart';
import 'package:gad_fly_partner/services/socket_service.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final ChatService chatService;
  final String callId;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.chatService,
    required this.callId,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  bool isCallConnected = false;

  @override
  void initState() {
    super.initState();
    widget.chatService.socket.on('call-accepted', (_) {
      setState(() {
        isCallConnected = true;
      });
    });

    widget.chatService.socket.on('call-rejected', (_) {
      Navigator.pop(context);
    });

    widget.chatService.socket.on('call-ended', (_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isCallConnected ? "Connected" : "Incoming Call",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Caller: ${widget.callerName}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isCallConnected)
                  ElevatedButton(
                    onPressed: () async {
                      await widget.chatService.acceptCall(widget.callId);
                      await widget.chatService.setupWebRTC(isCaller: false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      "Accept",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                if (!isCallConnected) const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.chatService.endCall();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    isCallConnected ? "End Call" : "Reject",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
