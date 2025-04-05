import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly_partner/constant/color_code.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:gad_fly_partner/services/socket_service.dart';
import 'package:gad_fly_partner/widgets/drawer.dart';
import 'package:gad_fly_partner/widgets/gradient_color_widget.dart';
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
      await mainApplicationController.getAllChat();
      await mainApplicationController.getAllTransaction();
    }
  }

  @override
  void initState() {
    mainApplicationController.checkMicrophonePermission();
    initFunction();
    profileController.getProfile().then((onValue) {
      if (onValue != null) {
        profileController.isAvailable.value = onValue["data"]["isAvailable"];
        profileController.amount.value =
            double.parse("${onValue["data"]["walletAmount"]}");
      }
    });
    mainApplicationController.getAllAnalytics();

    // chatService.socket.on('incoming-call', (data) async {
    //   _playRingingSound();
    // });
    // chatService.socket.on('call-accepted', (_) {
    //   setState(() {
    //     isCallConnected = true;
    //   });
    //   _stopRingingSound();
    //   _startTimer();
    // });
    //
    // chatService.socket.on('call-rejected', (_) {
    //   // chatService.disconnect();
    //   setState(() {
    //     isCalling = false;
    //     isCallConnected = false;
    //   });
    //   _stopRingingSound();
    //   _stopTimer();
    // });
    //
    // chatService.socket.on('call-ended', (_) {
    //   //  chatService.disconnect();
    //   if (mounted) {
    //     setState(() {
    //       isCalling = false;
    //       isCallConnected = false;
    //       remoteStream = null;
    //     });
    //   }
    //   chatService.endCalls();
    //   _stopRingingSound();
    //   _stopTimer();
    // });

    super.initState();
  }

  @override
  void dispose() {
    // _audioPlayer.stop();
    // _audioPlayer.dispose();
    //  remoteStream?.dispose();
    //  chatService.disconnect();
    // _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () async {
            if (!isCalling) {
              await chatService.disconnect();
              if (mainApplicationController.authToken.value != "") {
                chatService.connect(
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
            }
          },
          child: Image.asset(
            "assets/gadfly.png",
            height: 48,
          ),
        ),
        actions: [
          // if (!isCalling)
          //   Obx(() {
          //     return DropdownButton<String>(
          //       value:
          //           profileController.isAvailable.value ? "Online" : "Offline",
          //       onChanged: (String? newValue) async {
          //         if (newValue != null) {
          //           //  setState(() {
          //           mainApplicationController.selectedStatus.value = newValue;
          //           if (mainApplicationController.selectedStatus.value ==
          //               "Online") {
          //             profileController.isAvailable.value = true;
          //           } else {
          //             profileController.isAvailable.value = false;
          //           }
          //           // });
          //           await chatService
          //               .toggle(profileController.isAvailable.value);
          //           profileController.getProfile().then((onValue) {
          //             if (onValue != null) {
          //               profileController.isAvailable.value =
          //                   onValue["data"]["isAvailable"];
          //             }
          //           });
          //           // await chatService.disconnect();
          //           // if (mainApplicationController.authToken.value != "") {
          //           //   chatService.connect(
          //           //     context,
          //           //     mainApplicationController.authToken.value,
          //           //     _onRequestAccepted,
          //           //     (MediaStream stream) {
          //           //       setState(() {
          //           //         remoteStream = stream;
          //           //       });
          //           //     },
          //           //   );
          //           // }
          //         }
          //       },
          //       items:
          //           statusOptions.map<DropdownMenuItem<String>>((String value) {
          //         return DropdownMenuItem<String>(
          //           value: value,
          //           child: Row(
          //             children: <Widget>[
          //               Container(
          //                 width: 10,
          //                 height: 10,
          //                 decoration: BoxDecoration(
          //                   shape: BoxShape.circle,
          //                   color:
          //                       value == 'Online' ? Colors.green : Colors.red,
          //                 ),
          //               ),
          //               const SizedBox(width: 8),
          //               Text(value),
          //             ],
          //           ),
          //         );
          //       }).toList(),
          //       underline: const SizedBox(),
          //       icon: const SizedBox.shrink(),
          //     );
          //   }),
          if (!isCalling)
            Builder(
              builder: (context) => IconButton(
                icon: Image.asset(
                  "assets/drawerIcon.png",
                  width: 24,
                  fit: BoxFit.fitWidth,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
        ],
      ),
      drawer: buildDrawer(width, height),
      body:
          // isCalling
          //     ? Column(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           const SizedBox(height: 30),
          //           Text(
          //             isCallConnected ? "Connected" : "Incoming Call",
          //             style: const TextStyle(
          //                 fontSize: 24, fontWeight: FontWeight.bold),
          //           ),
          //           const SizedBox(height: 8),
          //           if (isCallConnected)
          //             Text(
          //               _formatDuration(_callDuration),
          //               textAlign: TextAlign.center,
          //               style: const TextStyle(
          //                   fontSize: 15, fontWeight: FontWeight.w400),
          //             ),
          //           const SizedBox(height: 8),
          //           Text(
          //             callerName,
          //             style: const TextStyle(fontSize: 18),
          //           ),
          //           const SizedBox(height: 20),
          //           const Spacer(),
          //           if (isCallConnected)
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 IconButton(
          //                   onPressed: _toggleLoudspeaker,
          //                   style: IconButton.styleFrom(
          //                       backgroundColor:
          //                           _isLoudspeakerOn ? Colors.green : Colors.grey,
          //                       padding: const EdgeInsets.all(10),
          //                       shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.circular(50),
          //                       )),
          //                   icon: const Icon(
          //                     Icons.volume_up,
          //                     size: 28,
          //                     color: Colors.white,
          //                   ),
          //                 ),
          //                 const SizedBox(width: 20),
          //                 IconButton(
          //                   icon: Icon(
          //                     _isMuted ? Icons.mic_off : Icons.mic,
          //                     size: 32,
          //                     color: Colors.white,
          //                   ),
          //                   onPressed: _toggleMute,
          //                   style: IconButton.styleFrom(
          //                       backgroundColor:
          //                           _isMuted ? Colors.red : Colors.grey,
          //                       padding: const EdgeInsets.all(10),
          //                       shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.circular(50),
          //                       )),
          //                 ),
          //               ],
          //             ),
          //           const SizedBox(height: 20),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               if (!isCallConnected)
          //                 ElevatedButton(
          //                   onPressed: () async {
          //                     await chatService.acceptCall(
          //                         mainApplicationController.currentCallId.value);
          //                   },
          //                   style: ElevatedButton.styleFrom(
          //                     backgroundColor: Colors.green,
          //                     padding: const EdgeInsets.symmetric(
          //                         horizontal: 40, vertical: 15),
          //                   ),
          //                   child: const Text(
          //                     "Accept",
          //                     style: TextStyle(fontSize: 18, color: Colors.white),
          //                   ),
          //                 ),
          //               if (!isCallConnected) const SizedBox(width: 20),
          //               ElevatedButton(
          //                 onPressed: () async {
          //                   await chatService.endCall();
          //                   _stopTimer();
          //                   setState(() {
          //                     isCalling = false;
          //                   });
          //                 },
          //                 style: ElevatedButton.styleFrom(
          //                   backgroundColor: Colors.red,
          //                   padding: const EdgeInsets.symmetric(
          //                       horizontal: 40, vertical: 15),
          //                 ),
          //                 child: Text(
          //                   isCallConnected ? "End Call" : "Reject",
          //                   style:
          //                       const TextStyle(fontSize: 18, color: Colors.white),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           const SizedBox(height: 40),
          //         ],
          //       )
          //     :
          Stack(
        children: [
          SizedBox(
            height: height,
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      width: width,
                      padding: const EdgeInsets.only(
                          left: 10, right: 2, top: 16, bottom: 16),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Wallet Balance",
                                  style: TextStyle(
                                      color: black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400)),
                              const SizedBox(height: 4),
                              Obx(() {
                                return Text(
                                  "₹${profileController.amount.value}",
                                  style: TextStyle(
                                      color: black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600),
                                );
                              }),
                              const SizedBox(height: 8),
                              Container(
                                  width: 76,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: GradientBorder(
                                      borderGradient: LinearGradient(
                                        colors: [
                                          appColor,
                                          appColorAccent,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "See All  ",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: GradientBorder(
                                              borderGradient: LinearGradient(
                                                colors: [
                                                  appColor,
                                                  appColorAccent,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 8,
                                            color: appColor,
                                          )),
                                    ],
                                  )),
                            ],
                          ),
                          Image.asset(
                            "assets/gold.png",
                            width: 120,
                            fit: BoxFit.contain,
                          )
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Active Status",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                Text(
                                  "Go online to start taking call",
                                  style: TextStyle(
                                      color: black.withOpacity(0.6),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Obx(() {
                            return Switch(
                              value: profileController.isAvailable.value,
                              onChanged: (bool newValue) async {
                                profileController.isAvailable.value = newValue;
                                mainApplicationController.selectedStatus.value =
                                    newValue ? "Online" : "Offline";

                                await chatService.toggle(
                                    profileController.isAvailable.value);

                                // profileController.getProfile().then((onValue) {
                                //   if (onValue != null) {
                                //     profileController.isAvailable.value =
                                //         onValue["data"]["isAvailable"];
                                //   }
                                // });

                                // Optional: Reconnect chat service if needed
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
                              },
                              activeColor: white,
                              activeTrackColor: Colors.green,
                              inactiveTrackColor: appColor,
                              trackOutlineColor: WidgetStatePropertyAll(white),
                              inactiveThumbColor: white,
                            );
                          })
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Overview",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: greyMedium1Color.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              " ALL ",
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w500),
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
                        Obx(() {
                          return Text(
                            mainApplicationController.totalEarnings.value,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          );
                        }),
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
                        Obx(() {
                          return Text(
                            mainApplicationController.totalMinutes.value,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          );
                        }),
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
                        Obx(() {
                          return Text(
                            "${mainApplicationController.totalCall.value}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          );
                        }),
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
                        Obx(() {
                          return Text(
                            "${mainApplicationController.totalMissedCall.value}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _startTimer() {
  //   _callDuration = Duration.zero;
  //   _isTimerRunning = true;
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     setState(() {
  //       _callDuration += const Duration(seconds: 1);
  //     });
  //   });
  // }
  //
  // void _stopTimer() {
  //   _timer?.cancel();
  //   _timer = null;
  //   _isTimerRunning = false;
  //   _callDuration = Duration.zero;
  // }
  //
  // String _formatDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   final hours = twoDigits(duration.inHours);
  //   final minutes = twoDigits(duration.inMinutes.remainder(60));
  //   final seconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "$hours:$minutes:$seconds";
  // }
  //
  // void _toggleMute() {
  //   setState(() {
  //     _isMuted = !_isMuted;
  //   });
  //   chatService.toggleMicrophone(_isMuted);
  // }
  //
  // void _toggleLoudspeaker() async {
  //   setState(() {
  //     _isLoudspeakerOn = !_isLoudspeakerOn;
  //   });
  //   await chatService.toggleLoudspeaker(_isLoudspeakerOn);
  // }
  //
  // void _playRingingSound() async {
  //   await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  //   await _audioPlayer.play(AssetSource("sound/call_sound.mp3"));
  //   setState(() {
  //     _isRinging = true;
  //   });
  // }
  //
  // void _stopRingingSound() async {
  //   await _audioPlayer.stop();
  //   setState(() {
  //     _isRinging = false;
  //   });
  // }

  void _onRequestAccepted(Map<String, dynamic> data) async {
    // if (mounted) {
    //   setState(() {
    //     callerName = data['caller']["avatarName"];
    //     isCalling = true;
    //   });
    // }
  }
}
