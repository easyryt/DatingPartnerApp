import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/services/socket_service.dart';
import 'package:get/get.dart';

class AgoraCallService extends GetxController {
  static const String appId = "90dde3ee5fbc4fe5a6a876e972c7bb2a";
  final RxBool isJoined = false.obs;
  final RxBool isRinging = false.obs;
  final RxBool isLoudspeaker = true.obs;
  final RxBool isMuted = false.obs;
  var channelName = "".obs;
  var agoraToken = "".obs;
  var userIds = "".obs;
  final RxString callDuration = "00:00".obs;
  DateTime? _callStartTime;

  late RtcEngine engine;
  MainApplicationController mainApplicationController =
      Get.put(MainApplicationController());
  ChatService chatService = ChatService();

  @override
  void onInit() {
    super.onInit();
    initializeAgora();
    initFunction();
  }

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        (_) {},
        (_) {},
      );
    }

    chatService.socket.on('call-accepted', (data) {
      joinCall(agoraToken.value, data['channelName'], data["partnerId"]);
    });

    chatService.socket.on('call-ended', (data) {
      engine.leaveChannel();
      isJoined.value = false;
      _stopCallTimer();
      Get.back();
    });
  }

  void _startCallTimer() {
    _callStartTime = DateTime.now();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_callStartTime != null) {
        final duration = DateTime.now().difference(_callStartTime!);
        callDuration.value = _formatDuration(duration);
      } else {
        timer.cancel();
      }
    });
  }

  // Stop the call timer
  void _stopCallTimer() {
    _callStartTime = null;
  }

  // Format duration as "mm:ss"
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void toggleLoudspeaker() async {
    isLoudspeaker.value = !isLoudspeaker.value;
    await engine.setEnableSpeakerphone(isLoudspeaker.value);
  }

  void initializeAgora() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: appId,
      // channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // Enable audio and set channel profile
    await engine.enableAudio();
    // await engine
    //     .setChannelProfile(ChannelProfileType.channelProfileCommunication);
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    // Route audio to speaker
    await engine.setDefaultAudioRouteToSpeakerphone(true);

    // Register event handlers
    engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        print("Joined channel successfully");
        isJoined.value = true;
      },
      onError: (ErrorCodeType err, String msg) {
        print("Error: $err, Message: $msg");
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        print("Remote user joined: $remoteUid");
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        print("Remote user offline: $remoteUid");
      },
    ));
  }

  void acceptCall(channelName) {
    chatService.socket.emit('accept-call', channelName);
  }

  Future<void> joinCall(String token, String channelName, userId) async {
    await engine.joinChannelWithUserAccount(
      token: token,
      channelId: channelName,
      // uid: 0,
      userAccount: userId,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
    _startCallTimer();
  }

  void endCall(channelName) {
    chatService.socket.emit('end-call', {'channelName': channelName});
    // engine.leaveChannel();
    // isJoined.value = false;
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    engine.muteLocalAudioStream(isMuted.value);
  }

  @override
  void onClose() {
    engine.release();
    super.onClose();
  }
}
