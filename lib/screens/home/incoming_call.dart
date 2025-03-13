import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/services/socket_service.dart';
import 'package:get/get.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String callId;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.callId,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  bool isCallConnected = false;
  String callerName = '';
  MainApplicationController mainApplicationController = Get.find();
  bool isLoading = false;
  MediaStream? remoteStream;

  ChatService chatService = ChatService();

  Duration _callDuration = Duration.zero;
  Timer? _timer;
  bool _isTimerRunning = false;
  bool _isMuted = false;
  bool _isLoudspeakerOn = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = false;

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        _onRequestAccepted,
        (MediaStream stream) {
          if (mounted) {
            setState(() {
              remoteStream = stream;
            });
          }
        },
      );
      await chatService.setupWebRTC();
      _playRingingSound();
    }
  }

  @override
  void initState() {
    initFunction();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isRinging = false;
      });
    });
    super.initState();

    chatService.socket.on('call-accepted', (_) {
      if (mounted) {
        setState(() {
          isCallConnected = true;
        });
      }
      _stopRingingSound();
      _startTimer();
    });

    chatService.socket.on('call-rejected', (_) {
      // chatService.disconnect();
      setState(() {
        isCallConnected = false;
      });

      _stopRingingSound();
      _stopTimer();
      Get.back();
    });

    chatService.socket.on('call-ended', (_) {
      //  chatService.disconnect();
      if (mounted) {
        setState(() {
          isCallConnected = false;
          remoteStream = null;
        });
      }
      chatService.endCalls();
      // _stopRingingSound();
      _stopTimer();
      Get.back();
    });
  }

  void _onRequestAccepted(Map<String, dynamic> data) async {
    // if (mounted) {
    //   setState(() {
    //     callerName = data['caller']["avatarName"];
    //     isCalling = true;
    //   });
    // }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    remoteStream?.dispose();
    //  chatService.disconnect();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Text(
                isCallConnected ? "Connected" : "Incoming Call...",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (isCallConnected)
                Text(
                  _formatDuration(_callDuration),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                ),
              const SizedBox(height: 8),
              Text(
                widget.callerName,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Spacer(),
              if (isCallConnected)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _toggleLoudspeaker,
                      style: IconButton.styleFrom(
                          backgroundColor:
                              _isLoudspeakerOn ? Colors.green : Colors.grey,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                      icon: const Icon(
                        Icons.volume_up,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMute,
                      style: IconButton.styleFrom(
                          backgroundColor: _isMuted ? Colors.red : Colors.grey,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isCallConnected)
                    ElevatedButton(
                      onPressed: () async {
                        await chatService.acceptCall(
                            mainApplicationController.currentCallId.value);
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
                    onPressed: () async {
                      await chatService.endCall();
                      _stopTimer();
                      //  Get.back();
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
              const SizedBox(height: 40),
            ],
          ),
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text(
          //       isCallConnected ? "Connected" : "Incoming Call",
          //       style:
          //           const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          //     ),
          //     const SizedBox(height: 20),
          //     Text(
          //       "Caller: ${widget.callerName}",
          //       style: const TextStyle(fontSize: 18),
          //     ),
          //     const SizedBox(height: 40),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         if (!isCallConnected)
          //           ElevatedButton(
          //             onPressed: () async {
          //               await chatService.acceptCall(widget.callId);
          //             },
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.green,
          //               padding: const EdgeInsets.symmetric(
          //                   horizontal: 40, vertical: 15),
          //             ),
          //             child: const Text(
          //               "Accept",
          //               style: TextStyle(fontSize: 18, color: Colors.white),
          //             ),
          //           ),
          //         if (!isCallConnected) const SizedBox(width: 20),
          //         ElevatedButton(
          //           onPressed: () {
          //             chatService.endCall();
          //           },
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.red,
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 40, vertical: 15),
          //           ),
          //           child: Text(
          //             isCallConnected ? "End Call" : "Reject",
          //             style: const TextStyle(fontSize: 18, color: Colors.white),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }

  void _startTimer() {
    _callDuration = Duration.zero;
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isTimerRunning = false;
    _callDuration = Duration.zero;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    chatService.toggleMicrophone(_isMuted);
  }

  void _toggleLoudspeaker() async {
    setState(() {
      _isLoudspeakerOn = !_isLoudspeakerOn;
    });
    await chatService.toggleLoudspeaker(_isLoudspeakerOn);
  }

  void _playRingingSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource("sound/call_sound.mp3"));
    setState(() {
      _isRinging = true;
    });
  }

  void _stopRingingSound() async {
    // await _audioPlayer.stop();
    // if (mounted) {
    //   setState(() {
    //     _isRinging = false;
    //   });
    // }
    try {
      if (_isRinging) {
        await _audioPlayer.stop();
        setState(() {
          _isRinging = false;
        });
      }
    } catch (e) {
      print("Error stopping sound: $e");
    }
  }
}
