import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:gad_fly_partner/screens/home/profile/profile.dart';
import 'package:gad_fly_partner/screens/home/profile/profile_create_screen.dart';
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
      }
    });
    initFunction();
    chatService.socket.on('call-accepted', (_) {
      setState(() {
        isCallConnected = true;
      });
    });

    chatService.socket.on('call-rejected', (_) {
      // chatService.disconnect();
      setState(() {
        isCalling = false;
        isCallConnected = false;
      });
    });

    chatService.socket.on('call-ended', (_) {
      //  chatService.disconnect();
      setState(() {
        isCalling = false;
        isCallConnected = false;
      });
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
    chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    var appYellow = const Color(0xFFFFE30F);
    var appGreenColor = const Color(0xFF35D673);
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
              }
            },
            child: Image.asset(
              "assets/gadfly.png",
              height: 48,
            ),
          ),
          actions: [
            Obx(() {
              return DropdownButton<String>(
                value:
                    profileController.isAvailable.value ? "Online" : "Offline",
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    setState(() {
                      mainApplicationController.selectedStatus.value = newValue;
                      if (mainApplicationController.selectedStatus.value ==
                          "Online") {
                        profileController.isAvailable.value = true;
                      } else {
                        profileController.isAvailable.value = false;
                      }
                    });
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
                items:
                    statusOptions.map<DropdownMenuItem<String>>((String value) {
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
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isCallConnected ? "Connected" : "Incoming Call",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Caller $callerName",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isCallConnected)
                          ElevatedButton(
                            onPressed: () async {
                              await chatService.acceptCall(
                                  mainApplicationController
                                      .currentCallId.value);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                            ),
                            child: const Text(
                              "Accept",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        if (!isCallConnected) const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            chatService.endCall();
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
                  ],
                ),
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
                                  const Text("₹0.00",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600)),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileCreateScreen()),
                                );
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
