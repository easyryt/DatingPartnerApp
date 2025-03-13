import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly_partner/constant/api_end_point.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:gad_fly_partner/screens/home/incoming_call.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStreamTrack? localAudioTrack;
  Function(MediaStream)? onRemoteStream;
  MainApplicationController mainApplicationController = Get.find();
  ProfileController profileController = Get.find();

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
      {
        'urls': 'turn:relay1.expressturn.com:3478',
        'username': 'efR4AAMWMYPFT40U65',
        'credential': 'bLSEHxZk2rbABCG8',
      },
    ]
  };

  connect(Function(Map<String, dynamic>)? onMessageReceived,
      Function(MediaStream) onRemoteStream) {
    this.onRemoteStream = onRemoteStream;
    socket = IO.io(ApiEndpoints.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {
        'token': mainApplicationController.authToken.value,
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

    socket.on('new-message', (data) {
      print(data);
    });
    socket.on('join-room', (data) {
      print(data);
    });

    socket.on('chat-list-update', (data) async {
      if (kDebugMode) {
        print(data);
      }
    });

    socket.on('typing-start', (data) {
      print(data);
    });

    socket.on('typing-stop', (data) {
      print(data);
    });

    socket.on("toggleResponse", (data) async {
      print(data);
      profileController.isAvailable.value = data["isAvailable"];
    });

    socket.on('incoming-call', (data) async {
      mainApplicationController.currentCallId.value = data['callId'];
      print('Incoming call from: ${data['caller']}');
      // await setupWebRTC();
      // onMessageReceived!(data);
      Get.to(
        () => IncomingCallScreen(
          callerName: data['caller']["avatarName"],
          callId: data['callId'],
        ),
      );
    });

    socket.on('call-initiated', (data) {
      print('Call initiated........... with ID: ${data['callId']}');
    });

    socket.on('offer', (data) async {
      print('Received ..............offer......................');

      await _handleOffer(data);
    });

    socket.on('answer', (data) async {
      print('Received answer');
      await peerConnection?.setRemoteDescription(
          RTCSessionDescription(data["answer"]['sdp'], data["answer"]['type']));
    });

    socket.on('ice-candidate', (data) async {
      //  print('Received ICE candidate');
      await peerConnection?.addCandidate(
        RTCIceCandidate(data['candidate']['candidate'],
            data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']),
      );
    });

    socket.on('wallet-update', (data) async {
      if (kDebugMode) {
        print(data);
      }
      if (data.containsKey("walletAmount")) {
        profileController.amount.value =
            double.parse("${data["walletAmount"]}");
      }
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
    // if (kDebugMode) {print('isActive: $isAvailable');}
  }

  Future<void> acceptCall(String callId) async {
    socket.emit('accept-call', {'callId': callId});
  }

  fetchChatList() {
    socket.emit('fetch-chat-list');
  }

  bool _isLoudspeakerOn = false;
  Future<void> toggleLoudspeaker(bool isLoudspeakerOn) async {
    try {
      await webrtc.Helper.setSpeakerphoneOn(isLoudspeakerOn);
      _isLoudspeakerOn = isLoudspeakerOn;
      print('Loudspeaker is ${isLoudspeakerOn ? 'ON' : 'OFF'}');
    } catch (e) {
      print('Error toggling loudspeaker: $e');
    }
  }

  void toggleMicrophone(bool isMuted) {
    if (localAudioTrack != null) {
      localAudioTrack!.enabled = !isMuted;
    }
  }

  Future<void> setupWebRTC() async {
    // peerConnection = await createPeerConnection(configuration);
    try {
      // await endCalls();
      localStream = await webrtc.navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });

      localAudioTrack = localStream!.getAudioTracks().first;

      peerConnection = await createPeerConnection(configuration);

      localStream?.getTracks().forEach((track) {
        //print("Remote track: ${track.id}, enabled: ${track.enabled}");
        peerConnection?.addTrack(track, localStream!);
      });

      peerConnection?.onTrack = (event) {
        if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
          onRemoteStream?.call(event.streams.first);
        }
      };

      peerConnection?.onIceCandidate = (candidate) {
        socket.emit('ice-candidate', {
          'callId': mainApplicationController.currentCallId.value,
          'candidate': candidate.toMap()
        });
      };
    } catch (e) {
      print("Error getting user media: $e");
      return;
    }
  }

  Future<void> _handleOffer(offer) async {
    if (peerConnection == null) await setupWebRTC();

    await peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer["offer"]["sdp"], offer["offer"]["type"]),
    );

    RTCSessionDescription answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    socket.emit('answer', {
      'callId': mainApplicationController.currentCallId.value,
      'answer': {'sdp': answer.sdp, 'type': answer.type},
    });
  }

  endCall() {
    socket.emit(
        'end-call', {'callId': mainApplicationController.currentCallId.value});
    endCalls();
  }

  endCalls() {
    peerConnection?.close();
    localStream?.dispose();
    peerConnection = null;
    localStream = null;
    localAudioTrack = null;
  }

  disconnect() {
    socket.disconnect();
  }
}
