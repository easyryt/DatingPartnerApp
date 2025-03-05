import 'package:flutter/material.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:gad_fly_partner/screens/home/profile/profile_create_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final ProfileController _updateProfileController = Get.find();

  bool isLoading = false;

  initFunction() async {}

  @override
  void initState() {
    initFunction();
    super.initState();
    _updateProfileController.getProfile().then((profileData) {
      if (profileData != null) {
        final data = profileData["data"];

        _updateProfileController.name.text = data["name"] ?? "";
        _updateProfileController.phoneNumber.text = data["phone"] ?? "";
        _updateProfileController.email.text = data["email"] ?? "";
        final gender = data["gender"] ?? "";
        _updateProfileController.gender.value = (gender == "male")
            ? 0
            : (gender == "female")
                ? 1
                : 2;
        final intersted = data["intersted"] ?? "";
        _updateProfileController.intersted.value = (intersted == "male")
            ? 0
            : (intersted == "female")
                ? 1
                : 2;
      } else {
        Get.snackbar("Error", "Something went wrong ...Profile not found. ");
      }
    }).catchError((error) {
      Get.snackbar("Error", "An error occurred while fetching profile data.");
    });
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
    return Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          height: height,
          width: width,
          child: Column(
            children: [
              SizedBox(
                height: AppBar().preferredSize.height,
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back_ios_new_sharp,
                            size: 18,
                            color: blackColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Profile",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: blackColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfileCreateScreen(
                                      isRegistration: false,
                                    )),
                          );
                        },
                        icon: Icon(Icons.edit)),
                  ],
                ),
              ),
              Expanded(
                  child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(() {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[300],
                                    child:
                                        _updateProfileController.imgUrl.value !=
                                                ""
                                            ? Container(
                                                height: 56,
                                                width: 56,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          _updateProfileController
                                                              .imgUrl.value),
                                                      fit: BoxFit.cover),
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 26,
                                                backgroundColor: appColor,
                                              )),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _updateProfileController.nameS.value,
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      _updateProfileController
                                          .phoneNumberS.value,
                                      style: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Professional Listener",
                              style: TextStyle(
                                  color: Colors.grey.withOpacity(0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Namaste! I’m ${_updateProfileController.nameS.value}. When I’m not Whipping up delicious treats in the kitchen.",
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              "Expertise",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            _buildChips([
                              'Empathy',
                              'Compassion',
                              'Problem-Solving',
                              'Loneliness'
                            ], greyMedium1Color),
                            const SizedBox(height: 8),
                            const Text('Language',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            _buildChips(_updateProfileController.language,
                                greyMedium1Color),
                            const Spacer(),
                            // GestureDetector(
                            //   onTap: () async {
                            //     // setState(() {
                            //     //   isLoading = true;
                            //     // });
                            //     // await _updateProfileController
                            //     //     .updateProfile()
                            //     //     .then((onValue) {
                            //     //   if (onValue == true) {
                            //     //     Get.snackbar(
                            //     //         "wow", "Profile updated successfully",
                            //     //         snackPosition: SnackPosition.TOP,
                            //     //         backgroundColor: Colors.grey.shade300);
                            //     //     // print("Profile updated successfully");
                            //     //   } else {
                            //     //     Get.snackbar(
                            //     //         "Alert", "Profile updated Failed",
                            //     //         snackPosition: SnackPosition.TOP,
                            //     //         backgroundColor: Colors.grey.shade300);
                            //     //   }
                            //     // });
                            //     // setState(() {
                            //     //   isLoading = false;
                            //     // });
                            //   },
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(
                            //         vertical: 9, horizontal: 12),
                            //     margin: const EdgeInsets.symmetric(
                            //         vertical: 8, horizontal: 6),
                            //     width: width * 0.88,
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(8),
                            //       color: greyMedium1Color,
                            //     ),
                            //     child: Center(
                            //       child: Text("Update & Save",
                            //           style: TextStyle(
                            //               color: blackColor,
                            //               fontSize: 16,
                            //               fontWeight: FontWeight.w500)),
                            //     ),
                            //   ),
                            // ),
                          ]);
                    }),
                  ),
                  if (isLoading)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(blackColor),
                      )),
                    )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChips(List labels, greyMedium1Color) {
    return Wrap(
      spacing: 10.0,
      children: labels
          .map((label) => Chip(
              // surfaceTintColor: greyMedium1Color.,
              // backgroundColor: greyMedium1Color,
              side: BorderSide.none,
              label: Text(label)))
          .toList(),
    );
  }
}
