import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly_partner/constant/api_end_point.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  Function(MediaStream)? onRemoteStream;
  String? currentCallId;

  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"},
      {"urls": "stun:stun1.l.google.com:19302"}
    ]
  };

  void connect(
      context,
      String? token,
      Function(Map<String, dynamic>)? onMessageReceived,
      Function(MediaStream) onRemoteStream) {
    this.onRemoteStream = onRemoteStream;
    socket = IO.io(ApiEndpoints.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {
        'token': token,
        'userType': "Partner",
      },
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      if (kDebugMode) {
        print('Connected to socket.io server');
        //  Get.snackbar("wow", "Socket connected successfully");
      }
      //   requestPartnerList();
    });

    socket.on('error', (data) async {
      if (kDebugMode) {
        try {
          print(data);
          //  Get.snackbar("Error", data["message"].toString());
        } catch (error) {
          print("Error accessing driverId: $error");
          // Get.snackbar("An error occurred", "Please try again later.");
        }
      }
    });

    socket.on("toggleResponse", (data) async {
      print(data);
    });

    // socket.on('incoming-call', (data) {
    //   print('Call initiated with ID: ${data['callId']}');
    //   print('Incoming call from: ${data['caller']}');
    // });
    socket.on('incoming-call', (data) async {
      currentCallId = data['callId'];
      print('Incoming call from: ${data['caller']}');
      // onMessageReceived!(data);
      //

      socket.emit('accept-call', {'callId': currentCallId});
      setupWebRTC(isCaller: false);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (_) => InCallScreen()));
    });

    socket.on('call-initiated', (data) {
      print('Call initiated with ID: ${data['callId']}');
    });

    socket.on('offer', (data) async {
      print('Received offer');
      await _handleOffer(data);
    });

    socket.on('answer', (data) async {
      print('Received answer');
      //  print("recieve Answer: ${data.sdp}");
      await peerConnection?.setRemoteDescription(
          RTCSessionDescription(data['answer'], 'answer'));
    });

    socket.on('ice-candidate', (data) async {
      print('Received ICE candidate');
      await peerConnection?.addCandidate(
        RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
      );
    });

    socket.on('call-ended', (_) {
      print('Call ended');
      endCalls();
    });

    socket.onDisconnect((_) {
      if (kDebugMode) {
        print('Disconnected from socket.io server');
      }
    });
  }

  void toggle(isAvailable) {
    socket.emit('toggle', {
      'isAvailable': isAvailable,
    });

    if (kDebugMode) {
      print('isActive: $isAvailable');
    }
  }

  Future<void> acceptCall(String callId) async {
    socket.emit('accept-call', {'callId': callId});
    //  await _setupWebRTC();
  }

  Future<void> setupWebRTC({required bool isCaller}) async {
    peerConnection = await createPeerConnection(configuration);
    // localStream = await navigator.mediaDevices.getUserMedia({
    //   'audio': true,
    //   'video': false,
    // });
    // localStream?.getTracks().forEach((track) {
    //   peerConnection?.addTrack(track, localStream!);
    // });
    try {
      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });

      localStream?.getAudioTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });
    } catch (e) {
      print("Error getting user media: $e");
      return; // Stop setup if media access fails
    }

    peerConnection?.onIceCandidate = (candidate) {
      socket.emit('ice-candidate',
          {'callId': currentCallId, 'candidate': candidate.toMap()});
    };

    peerConnection?.onTrack = (event) {
      if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
        onRemoteStream?.call(event.streams[0]);
      }
    };
  }

  Future<void> _handleOffer(offer) async {
    // print("Received Offer: ${offer['sdp']}");
    if (peerConnection != null) {
      await peerConnection!
          .setRemoteDescription(RTCSessionDescription(offer, 'offer'));
      RTCSessionDescription answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);
      socket.emit('answer', {'callId': currentCallId, 'answer': answer.sdp});
      //  print("Sending Answer: ${answer.sdp}");
    } else {
      print("Error: peerConnection is null!");
    }
  }

  void endCall() {
    socket.emit('end-call', {'callId': currentCallId});
  }

  void endCalls() {
    peerConnection?.close();
    localStream?.dispose();
    peerConnection = null;
    localStream = null;
  }

  void disconnect() {
    socket.disconnect();
  }
}
