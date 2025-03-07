// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:gad_fly_partner/controller/main_application_controller.dart';
// import 'package:gad_fly_partner/screens/home/home_page.dart';
// import 'package:gad_fly_partner/services/socket_service.dart';
// import 'package:get/get.dart';
//
// class IncomingCallScreen extends StatefulWidget {
//   final String callerName;
//   final String callId;
//
//   const IncomingCallScreen({
//     super.key,
//     required this.callerName,
//     required this.callId,
//   });
//
//   @override
//   State<IncomingCallScreen> createState() => _IncomingCallScreenState();
// }
//
// class _IncomingCallScreenState extends State<IncomingCallScreen> {
//   bool isCallConnected = false;
//   MainApplicationController mainApplicationController = Get.find();
//   bool isLoading = false;
//   MediaStream? remoteStream;
//
//   ChatService chatService = ChatService();
//   initFunction() async {
//     if (mainApplicationController.authToken.value != "") {
//       await chatService.connect(
//         context,
//         mainApplicationController.authToken.value,
//         _onRequestAccepted,
//         (MediaStream stream) {
//           setState(() {
//             remoteStream = stream;
//           });
//         },
//       );
//       await chatService.setupWebRTC();
//     }
//   }
//
//   @override
//   void initState() {
//     initFunction();
//     super.initState();
//     chatService.socket.on('call-accepted', (_) {
//       setState(() {
//         isCallConnected = true;
//       });
//     });
//
//     chatService.socket.on('call-rejected', (_) {
//       chatService.disconnect();
//       Navigator.push(
//           context, MaterialPageRoute(builder: (_) => const HomePage()));
//     });
//
//     chatService.socket.on('call-ended', (_) {
//       chatService.disconnect();
//       Navigator.push(
//           context, MaterialPageRoute(builder: (_) => const HomePage()));
//     });
//   }
//
//   void _onRequestAccepted(Map<String, dynamic> data) async {}
//
//   @override
//   void dispose() {
//     chatService.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await chatService.disconnect();
//         Navigator.push(
//             context, MaterialPageRoute(builder: (_) => const HomePage()));
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 isCallConnected ? "Connected" : "Incoming Call",
//                 style:
//                     const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Caller: ${widget.callerName}",
//                 style: const TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 40),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (!isCallConnected)
//                     ElevatedButton(
//                       onPressed: () async {
//                         await chatService.acceptCall(widget.callId);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 40, vertical: 15),
//                       ),
//                       child: const Text(
//                         "Accept",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                   if (!isCallConnected) const SizedBox(width: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       chatService.endCall();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 40, vertical: 15),
//                     ),
//                     child: Text(
//                       isCallConnected ? "End Call" : "Reject",
//                       style: const TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
