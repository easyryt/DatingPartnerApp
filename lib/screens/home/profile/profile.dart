import 'package:flutter/material.dart';
import 'package:gad_fly_partner/auth/register_screen.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:gad_fly_partner/screens/home/profile/wallet_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ProfileController updateProfileController = Get.put(ProfileController());
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
        // SystemNavigator.pop();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: whiteColor,
        body: SafeArea(
          child: SizedBox(
            height: height,
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear)),
                const SizedBox(height: 10),
                // Settings Section
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Settings',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const WalletScreen()));
                          },
                          child: _buildSettingsOption(
                              Icons.account_balance_wallet_outlined, 'Wallet'),
                        ),
                        _buildSettingsOption(
                            Icons.language, 'Choose App Language', 'English'),
                        _buildSettingsOption(Icons.translate, 'My Language'),
                        _buildSettingsOption(Icons.lock, 'Privacy & Security'),
                        _buildSettingsOption(Icons.info, 'Our About Us'),
                        _buildSettingsOption(
                            Icons.card_giftcard, 'Refer & Earn'),
                        _buildSettingsOption(Icons.contact_mail, 'Contact Us'),
                        GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();
                              Get.to(() => const RegisterScreen());
                            },
                            child:
                                _buildSettingsOption(Icons.logout, 'Logout')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(IconData icon, String title, [String? subtitle]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              if (subtitle != null)
                Text(subtitle, style: const TextStyle(color: Colors.grey))
            ],
          ))
        ],
      ),
    );
    ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      onTap: () {},
    );
  }
}
