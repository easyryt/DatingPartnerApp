import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:gad_fly_partner/screens/home/history.dart';
import 'package:gad_fly_partner/screens/home/profile/my_profile.dart';
import 'package:gad_fly_partner/screens/home/profile/profile.dart';
import 'package:gad_fly_partner/services/socket_service.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MainApplicationController mainApplicationController = Get.find();
  ProfileController profileController = Get.put(ProfileController());
  bool isLoading = false;
  bool isCalling = false;
  bool isCallConnected = false;
  MediaStream? remoteStream;
  String callerName = '';

  final List<String> statusOptions = ['Online', 'Offline'];
  ChatService chatService = ChatService();

  Duration _callDuration = Duration.zero;
  Timer? _timer;
  bool _isTimerRunning = false;

  void _startTimer() {
    _callDuration = Duration.zero;
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration += const Duration(seconds: 1);
      });
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

  bool _isMuted = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    chatService.toggleMicrophone(_isMuted);
  }

  bool _isLoudspeakerOn = false;

  void _toggleLoudspeaker() async {
    setState(() {
      _isLoudspeakerOn = !_isLoudspeakerOn;
    });
    await chatService.toggleLoudspeaker(_isLoudspeakerOn);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = false;

  void _playRingingSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource("sound/call_sound.mp3"));
    setState(() {
      _isRinging = true;
    });
  }

  void _stopRingingSound() async {
    await _audioPlayer.stop();
    setState(() {
      _isRinging = false;
    });
  }

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        context,
        mainApplicationController.authToken.value,
        _onRequestAccepted,
        (MediaStream stream) {
          setState(() {
            remoteStream = stream;
          });
        },
      );
    }
  }

  @override
  void initState() {
    mainApplicationController.checkMicrophonePermission();
    profileController.getProfile().then((onValue) {
      if (onValue != null) {
        profileController.isAvailable.value = onValue["data"]["isAvailable"];
        profileController.amount.value =
            double.parse("${onValue["data"]["walletAmount"]}");
      }
    });
    mainApplicationController.getAllTransaction();
    initFunction();

    chatService.socket.on('incoming-call', (data) async {
      _playRingingSound();
    });
    chatService.socket.on('call-accepted', (_) {
      setState(() {
        isCallConnected = true;
      });
      _stopRingingSound();
      _startTimer();
    });

    chatService.socket.on('call-rejected', (_) {
      // chatService.disconnect();
      setState(() {
        isCalling = false;
        isCallConnected = false;
      });
      _stopRingingSound();
      _stopTimer();
    });

    chatService.socket.on('call-ended', (_) {
      //  chatService.disconnect();
      setState(() {
        isCalling = false;
        isCallConnected = false;
        remoteStream = null;
      });
      chatService.endCalls();
      _stopRingingSound();
      _stopTimer();
    });

    super.initState();
  }

  void _onRequestAccepted(Map<String, dynamic> data) async {
    setState(() {
      callerName = data['caller']["name"];
      isCalling = true;
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    remoteStream?.dispose();
    chatService.disconnect();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    var greyMedium1Color = const Color(0xFFDBDBDB);
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: whiteColor,
          surfaceTintColor: whiteColor,
          leadingWidth: 0,
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: () async {
              await chatService.disconnect();
              if (mainApplicationController.authToken.value != "") {
                chatService.connect(
                  context,
                  mainApplicationController.authToken.value,
                  _onRequestAccepted,
                  (MediaStream stream) {
                    setState(() {
                      remoteStream = stream;
                    });
                  },
                );
                profileController.getProfile().then((onValue) {
                  if (onValue != null) {
                    profileController.isAvailable.value =
                        onValue["data"]["isAvailable"];
                  }
                });
              }
            },
            child: Image.asset(
              "assets/gadfly.png",
              height: 48,
            ),
          ),
          actions: [
            if (!isCalling)
              IconButton(
                  onPressed: () {
                    Get.to(() => HistoryScreen());
                  },
                  icon: const Icon(Icons.history)),
            if (!isCalling)
              Obx(() {
                return DropdownButton<String>(
                  value: profileController.isAvailable.value
                      ? "Online"
                      : "Offline",
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      //  setState(() {
                      mainApplicationController.selectedStatus.value = newValue;
                      if (mainApplicationController.selectedStatus.value ==
                          "Online") {
                        profileController.isAvailable.value = true;
                      } else {
                        profileController.isAvailable.value = false;
                      }
                      // });
                      await chatService
                          .toggle(profileController.isAvailable.value);
                      profileController.getProfile().then((onValue) {
                        if (onValue != null) {
                          profileController.isAvailable.value =
                              onValue["data"]["isAvailable"];
                        }
                      });
                      // await chatService.disconnect();
                      // if (mainApplicationController.authToken.value != "") {
                      //   chatService.connect(
                      //     context,
                      //     mainApplicationController.authToken.value,
                      //     _onRequestAccepted,
                      //     (MediaStream stream) {
                      //       setState(() {
                      //         remoteStream = stream;
                      //       });
                      //     },
                      //   );
                      // }
                    }
                  },
                  items: statusOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  value == 'Online' ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                  underline: const SizedBox(),
                  icon: const SizedBox.shrink(),
                );
              }),
            if (!isCalling)
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                  icon: const Icon(Icons.settings))
          ],
        ),
        body: isCalling
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    isCallConnected ? "Connected" : "Incoming Call",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
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
                    callerName,
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
                              backgroundColor:
                                  _isMuted ? Colors.red : Colors.grey,
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
                          setState(() {
                            isCalling = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: Text(
                          isCallConnected ? "End Call" : "Reject",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              )
            : Stack(
                children: [
                  SizedBox(
                    height: height,
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      whiteColor,
                                      whiteColor,
                                      appColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Wallet Balance",
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 5),
                                  Obx(() {
                                    return Text(
                                      "₹${profileController.amount.value}",
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600),
                                    );
                                  }),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: whiteColor,
                                        foregroundColor: appColor,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text("See All"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x16000000),
                                    blurRadius: 2,
                                    offset: Offset(0, 2),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "New User",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          "Daily Updates",
                                          style: TextStyle(
                                              color:
                                                  blackColor.withOpacity(0.3),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Row(
                                    children: [
                                      const Text(
                                        "15+",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10),
                                      ),
                                      const SizedBox(width: 6),
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: appColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Overview",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: greyMedium1Color,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "This Week",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Earning",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.grey[500]),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "1.38k",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Minutes",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.grey[500]),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "155",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Call",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.grey[500]),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "27",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Missed",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.grey[500]),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "2",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 24,
                      left: width * 0.16,
                      right: width * 0.16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 9,
                              offset: Offset(0, 7),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: width * 0.11),
                              decoration: BoxDecoration(
                                color: appColor,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Icon(
                                Icons.call,
                                color: whiteColor,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => const MyProfileScreen());
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: width * 0.11),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: blackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
      ),
    );
  }
}
