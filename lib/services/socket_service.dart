import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly_partner/constant/api_end_point.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  Function(MediaStream)? onRemoteStream;
  MainApplicationController mainApplicationController = Get.find();

  final Map<String, dynamic> configuration = {
    "iceServers": [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {
        "url": "stun:global.stun.twilio.com:3478",
        "urls": "stun:global.stun.twilio.com:3478"
      },
      {
        'urls': 'turn:relay1.expressturn.com:3478',
        'username': 'ef8M6WFNY9LISR2PA9',
        'credential': 'GOKTdvE3sYZQ6NRm',
      },
    ]
  };

  connect(
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
        Get.snackbar("wow", "Socket connected successfully");
      }
    });

    socket.on('error', (data) async {
      if (kDebugMode) {
        try {
          print(data);
          Get.snackbar("Error", data["message"].toString());
        } catch (error) {
          print("Error accessing driverId: $error");
          Get.snackbar("An error occurred", "Please try again later.");
        }
      }
    });

    socket.on("toggleResponse", (data) async {
      print(data);
    });

    socket.on('incoming-call', (data) async {
      mainApplicationController.currentCallId.value = data['callId'];
      print('Incoming call from: ${data['caller']}');
      await setupWebRTC();
      onMessageReceived!(data);

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => IncomingCallScreen(
      //       callerName: data['caller']["name"],
      //       callId: data['callId'],
      //     ),
      //   ),
      // );
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
      await peerConnection?.setRemoteDescription(
          RTCSessionDescription(data["answer"]['sdp'], data["answer"]['type']));
    });

    socket.on('ice-candidate', (data) async {
      print('Received ICE candidate');
      await peerConnection?.addCandidate(
        RTCIceCandidate(data['candidate']['candidate'],
            data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']),
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

  toggle(isAvailable) {
    socket.emit('toggle', {
      'isAvailable': isAvailable,
    });

    if (kDebugMode) {
      print('isActive: $isAvailable');
    }
  }

  Future<void> acceptCall(String callId) async {
    socket.emit('accept-call', {'callId': callId});
  }

  Future<void> setupWebRTC() async {
    peerConnection = await createPeerConnection(configuration);
    try {
      localStream = await webrtc.navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });

      localStream?.getTracks().forEach((track) {
        print("Remote track: ${track.id}, enabled: ${track.enabled}");
        peerConnection?.addTrack(track, localStream!);
      });
    } catch (e) {
      print("Error getting user media: $e");
      return;
    }

    peerConnection?.onIceCandidate = (candidate) {
      socket.emit('ice-candidate', {
        'callId': mainApplicationController.currentCallId.value,
        'candidate': candidate.toMap()
      });
    };

    peerConnection?.onTrack = (event) {
      if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
        onRemoteStream?.call(event.streams[0]);
      }
    };
  }

  Future<void> initPeerConnection() async {
    if (peerConnection == null) {
      peerConnection = await createPeerConnection(configuration);
      try {
        localStream = await webrtc.navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': false,
        });

        localStream?.getTracks().forEach((track) {
          print("Remote track: ${track.id}, enabled: ${track.enabled}");
          peerConnection?.addTrack(track, localStream!);
        });
      } catch (e) {
        print("Error getting user media: $e");
        return;
      }

      peerConnection?.onIceCandidate = (candidate) {
        socket.emit('ice-candidate', {
          'callId': mainApplicationController.currentCallId.value,
          'candidate': candidate.toMap()
        });
      };

      peerConnection?.onTrack = (event) {
        if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
          onRemoteStream?.call(event.streams[0]);
        }
      };
    }
  }

  Future<void> _handleOffer(offer) async {
    if (peerConnection == null) {
      await setupWebRTC();
    }
    if (peerConnection != null) {
      await peerConnection!.setRemoteDescription(RTCSessionDescription(
        offer["offer"]["sdp"],
        offer["offer"]["type"],
      ));
      RTCSessionDescription answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);
      socket.emit('answer', {
        'callId': mainApplicationController.currentCallId.value,
        'answer': {'sdp': answer.sdp, 'type': answer.type},
      });
    } else {
      print("Error: peerConnection is null!");
    }
  }

  void endCall() {
    socket.emit(
        'end-call', {'callId': mainApplicationController.currentCallId.value});
    endCalls();
  }

  void endCalls() {
    peerConnection?.close();
    localStream?.dispose();
    peerConnection = null;
    localStream = null;
  }

  disconnect() {
    socket.disconnect();
  }
}
