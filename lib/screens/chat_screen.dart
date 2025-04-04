import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly_partner/constant/color_code.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/screens/messages_screen.dart';
import 'package:gad_fly_partner/services/socket_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  MainApplicationController mainApplicationController = Get.find();

  ChatService chatService = ChatService();

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        _onRequestAccepted,
        (_) {},
      );
      await chatService.fetchChatList();
    }
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
  void initState() {
    initFunction();
    // mainApplicationController.getAllChat();

    chatService.socket.on('chat-list', (data) {
      //  print(data);
      mainApplicationController.chatList.value = data["data"];
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          backgroundColor: white,
          surfaceTintColor: white,
          automaticallyImplyLeading: false,
          title: const Text(
            "Chats",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: greyMedium1Color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                // border: Border.all(
                //     color: blackColor.withOpacity(0.15), width: 1.1),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "search...",
                      style: TextStyle(
                          color: black.withOpacity(0.5),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                    Icon(
                      CupertinoIcons.search,
                      color: black.withOpacity(0.5),
                    )
                  ],
                ),
              ),
            ),
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: mainApplicationController.chatList.length,
                    itemBuilder: (context, index) {
                      var item = mainApplicationController.chatList[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => MessagesScreen(
                                conversationId: item["lastMessage"]
                                    ["conversationId"],
                                receiverId: item["user"]["_id"],
                                name: item["user"]["avatarName"],
                              ));
                        },
                        child: Container(
                          width: width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 5),
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    spreadRadius: 0,
                                    blurRadius: 0,
                                    offset: const Offset(0, 0))
                              ]),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: greyMedium1Color,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["user"]["avatarName"],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item["lastMessage"]["content"],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    formatDate(
                                        item["lastMessage"]["createdAt"]),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  if (item["unreadCount"] != 0)
                                    CircleAvatar(
                                        radius: 11,
                                        backgroundColor:
                                            appColor.withOpacity(0.8),
                                        child: Center(
                                            child: Text(
                                          (item["unreadCount"] > 99)
                                              ? "99+"
                                              : "${item["unreadCount"]}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: white, fontSize: 10),
                                        ))),
                                  if (item["unreadCount"] == 0)
                                    CircleAvatar(
                                      radius: 11,
                                      backgroundColor: white,
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                      //   });
                    }),
              );
            })
          ],
        ));
  }

  String formatDate(String inputDate) {
    try {
      DateTime dateTime = DateTime.parse(inputDate);
      DateTime now = DateTime.now();
      // String outputDate = DateFormat('hh:mm a').format(dateTime);
      // return outputDate;
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return DateFormat('hh:mm a').format(dateTime);
      } else {
        return DateFormat('dd-MMM hh:mm a').format(dateTime);
      }
    } catch (e) {
      print('Invalid date format: $e');
      return 'Invalid Date';
    }
  }
}
