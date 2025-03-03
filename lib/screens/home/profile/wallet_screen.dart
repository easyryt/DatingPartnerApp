import 'package:flutter/material.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:get/get.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  ProfileController profileController = Get.find();

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
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            )),
        title: const Text(
          'My Wallet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: const [Icon(Icons.info_outline), SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              //color: Colors.white,
              gradient: LinearGradient(colors: [
                whiteColor,
                whiteColor,
                appColor,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Transaction"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: greyMedium1Color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBottomOption(Icons.verified_user, "Secure Checkout"),
                _buildBottomOption(Icons.emoji_events, "Secure Checkout"),
                _buildBottomOption(Icons.lock, "Secure Checkout"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOption(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(height: 5),
        Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
