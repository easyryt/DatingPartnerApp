import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly_partner/controller/call_controller.dart';
import 'package:get/get.dart';

class PartnerCallScreen extends StatefulWidget {
  final String channelName;
  final String name;
  final String agoraToken;
  final String callerId;
  const PartnerCallScreen(
      {super.key,
      required this.channelName,
      required this.agoraToken,
      required this.callerId,
      required this.name});

  @override
  State<PartnerCallScreen> createState() => _PartnerCallScreenState();
}

class _PartnerCallScreenState extends State<PartnerCallScreen> {
  final AgoraCallService controller = Get.put(AgoraCallService());

  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    _audioPlayer.onPlayerComplete.listen((event) {
      controller.isRinging.value = false;
    });
    controller.channelName.value = widget.channelName;
    controller.agoraToken.value = widget.agoraToken;
    controller.userIds.value = widget.callerId;
    super.initState();
    _playRingingSound();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //  appBar: AppBar(title: const Text('Partner Call Screen')),
        body: SafeArea(
      child: Center(
          child:
              // controller.isJoined.value
              //     ?
              Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Obx(() {
            return Text(
                controller.isJoined.value ? " Connected" : "Incoming Call...");
          }),
          const SizedBox(height: 12),
          Text(
            widget.name,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
                controller.isJoined.value ? controller.callDuration.value : "",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              )),
          const Spacer(),
          const SizedBox(height: 20),
          Obx(() {
            return (controller.isJoined.value)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Obx(() => Icon(
                              controller.isMuted.value
                                  ? Icons.mic_off
                                  : Icons.mic,
                              size: 30,
                              color: Colors.blue,
                            )),
                        onPressed: () {
                          controller.toggleMute();
                        },
                      ),
                      const SizedBox(width: 20),
                      // Loudspeaker/Earpiece Button
                      IconButton(
                        icon: Obx(() => Icon(
                              controller.isLoudspeaker.value
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              size: 30,
                              color: Colors.blue,
                            )),
                        onPressed: () {
                          controller.toggleLoudspeaker();
                        },
                      ),
                    ],
                  )
                : const SizedBox();
          }),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                return (!controller.isJoined.value)
                    ? ElevatedButton(
                        onPressed: () async {
                          controller.acceptCall(widget.channelName);
                          _stopRingingSound();
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
                      )
                    : SizedBox();
              }),
              Obx(() {
                return (!controller.isJoined.value)
                    ? const SizedBox(width: 20)
                    : SizedBox();
              }),
              ElevatedButton(
                onPressed: () async {
                  controller.endCall(widget.channelName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "End Call",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // ElevatedButton(
          //   onPressed: controller.toggleMute,
          //   child:
          //       Text(controller.isMuted.value ? "Unmute" : "Mute"),
          // ),
        ],
      )
          // : ElevatedButton(
          //     onPressed: () => controller.acceptCall(widget.channelName),
          //     child: const Text("Accept Call"),
          //   ),
          ),
    ));
  }

  void _playRingingSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource("sound/call_sound.mp3"));
    controller.isRinging.value = true;
  }

  void _stopRingingSound() async {
    try {
      if (controller.isRinging.value) {
        await _audioPlayer.stop();
        controller.isRinging.value = false;
      }
    } catch (e) {
      print("Error stopping sound: $e");
    }
  }
}
