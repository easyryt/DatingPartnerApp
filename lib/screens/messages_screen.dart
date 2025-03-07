import 'package:flutter/material.dart';
import 'package:gad_fly_partner/controller/chat_controller.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/services/socket_service.dart';
import 'package:get/get.dart';

class MessagesScreen extends StatefulWidget {
  final String receiverId;
  const MessagesScreen({super.key, required this.receiverId});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatController chatController = Get.put(ChatController());

  MainApplicationController mainApplicationController = Get.find();

  ChatService chatService = ChatService();

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        context,
        mainApplicationController.authToken.value,
        _onRequestAccepted,
        (_) {},
      );
    }
  }

  @override
  void initState() {
    initFunction();
    chatService.socket.on('new-message', (data) {
      chatController.messages.add(data);
    });

    chatService.socket.on('typing-start', (data) {
      chatController.isTyping.value = true;
    });

    chatService.socket.on('typing-stop', (data) {
      chatController.isTyping.value = false;
    });
    super.initState();
  }

  void _onRequestAccepted(Map<String, dynamic> data) async {
    // mainApplicationController.partnerList.clear();
    // if (data.containsKey('data')) {
    //   final List<dynamic> noteData = data['data'];
    //   List<Map<String, dynamic>> dataList =
    //       noteData.map((data) => data as Map<String, dynamic>).toList();
    //   mainApplicationController.partnerList.value = dataList;
    // } else {
    //   throw Exception('Invalid response format: "data" field not found');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    var message = chatController.messages[index];
                    return Align(
                      alignment: message['senderType'] == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: message['senderType'] == 'user'
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['content'],
                          style: TextStyle(
                              color: message['senderType'] == 'user'
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  },
                )),
          ),
          Obx(() => chatController.isTyping.value
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Typing..."),
                )
              : const SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController.messageController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        startTyping(widget.receiverId);
                      } else {
                        stopTyping(widget.receiverId);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(widget.receiverId),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendMessage(String receiverId) {
    if (chatController.messageController.text.trim().isEmpty) return;

    chatService.socket.emit('send-message', {
      'receiverId': receiverId,
      'content': chatController.messageController.text.trim()
    });

    chatController.messageController.clear();
  }

  void startTyping(String receiverId) {
    chatService.socket.emit('typing-start', {'receiverId': receiverId});
  }

  void stopTyping(String receiverId) {
    chatService.socket.emit('typing-stop', {'receiverId': receiverId});
  }
}

///
// import 'package:flutter/material.dart';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
// import 'package:gad_fly_partner/constant/color_code.dart';
// import 'package:gad_fly_partner/services/socket_service.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   ChatService chatService = ChatService();
//   List<Map<String, dynamic>> messages = [];
//   bool isTyping = false;
//
//   loadData() async {
//     await chatService.connect(context, token, _handleIncomingMessage, (_) {});
//     _scrollToBottom();
//   }
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);
//
//     loadData();
//
//     // chatService.connect(widget.id, _handleIncomingMessage,
//     //     onTyping: _handleUserTyping, onStopTyping: _handleStopTyping);
//
//     super.initState();
//     KeyboardVisibilityController().onChange.listen((bool isVisible) {
//       if (isVisible) {
//         _scrollToBottom();
//       }
//     });
//
//     // Listen to typing event
//     //   _controller.addListener(() {
//     //     if (_controller.text.isNotEmpty) {
//     //       chatService.startTyping(widget.id); // Emit typing event
//     //     } else {
//     //       chatService.stopTyping(widget.id); // Emit stop typing event
//     //     }
//     //   });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       chatService.connect(context, token, _handleIncomingMessage, (_) {});
//     } else if (state == AppLifecycleState.paused) {
//       chatService.disconnect();
//     }
//   }
//
//   @override
//   void dispose() {
//     //  chatService.disconnect();
//     _controller.dispose();
//     _scrollController.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 controller: _scrollController,
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     // contentPadding: EdgeInsets.only(
//                     //     right: (widget.driverSocketId !=
//                     //             messages[index]["senderId"])
//                     //         ? 12
//                     //         : size.width * 0.15,
//                     //     left: (widget.driverSocketId !=
//                     //             messages[index]["senderId"])
//                     //         ? size.width * 0.15
//                     //         : 12),
//                     title: Align(
//                       // alignment:
//                       //     (widget.driverSocketId != messages[index]["senderId"])
//                       //         ? Alignment.centerRight
//                       //         : Alignment.centerLeft,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 4),
//                         decoration: BoxDecoration(
//                           color:
//                           // (widget.driverSocketId !=
//                           //         messages[index]["senderId"])
//                           //     ? themeColor
//                           //   :
//                           Colors.grey.shade500,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           messages[index]["message"],
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding:
//               const EdgeInsets.only(left: 8.0, right: 8, bottom: 6, top: 4),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _controller,
//                       minLines: 1,
//                       maxLines: 2,
//                       decoration: InputDecoration(
//                         isDense: true,
//                         hintText: 'Type your message...',
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 8,
//                   ),
//                   Card(
//                     surfaceTintColor: Colors.white,
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                     elevation: 4.0,
//                     child: IconButton(
//                       icon: const Icon(Icons.send),
//                       onPressed: _sendMessage,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _sendMessage() async {
//     final message = _controller.text;
//
//     if (message.isNotEmpty) {
//       // chatService.sendMessage(widget.rideId, message);
//       // await _messageService.createMessages(
//       //     message, widget.authToken, widget.id, context);
//
//       // chatService.stopTyping(widget.id);
//       //_controller.clear();
//     }
//   }
//
//   String? token = "";
//
//   void _handleIncomingMessage(Map<String, dynamic> newMessage) {
//     if (mounted) {
//       setState(() {
//         messages.add(newMessage);
//       });
//     }
//     _scrollToBottom();
//   }
//
//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
// }
///
