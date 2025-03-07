import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:gad_fly_partner/screens/bottom_navigation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileCreateScreen extends StatefulWidget {
  final bool isRegistration;
  const ProfileCreateScreen({super.key, required this.isRegistration});

  @override
  State<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends State<ProfileCreateScreen> {
  MainApplicationController mainApplicationController = Get.find();
  ProfileController profileController = Get.put(ProfileController());
  File? _selectedImage;
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _avatarNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'female';
  final _languagesController = TextEditingController();
  // final _languagesController1 = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _voiceNoteUrlController = TextEditingController();
  final List<String> _languages = [];
  @override
  void initState() {
    profileController.getProfile().then((profileData) {
      if (profileData != null) {
        setState(() {
          _nameController.text = profileData["additionalInfo"]["ogName"];
          _phoneController.text = profileData["data"]["phone"];
          _avatarNameController.text =
              profileData["additionalInfo"]["avatarName"];
          _ageController.text = profileData["additionalInfo"]["age"].toString();
          _gender = profileData["additionalInfo"]["gender"] ?? "";
          if (_gender == "female") {
            profileController.gender.value = 1;
          } else if (_gender == "male") {
            profileController.gender.value = 0;
          } else {
            profileController.gender.value = 2;
          }
          // _languagesController.text =
          //     profileData["additionalInfo"]["languages"][0];
          // _languagesController1.text =
          //     profileData["additionalInfo"]["languages"][1];
          var langs = profileData["additionalInfo"]["languages"];
          if (langs != null && langs is List) {
            _languages.addAll(List<String>.from(langs));
          }
          _emailController.text = profileData["additionalInfo"]["email"];
          _addressController.text = profileData["additionalInfo"]["address"];
        });
      }
    });
    _voiceNoteUrlController.text = "https://example.com/voice_note.mp3";
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarNameController.dispose();
    _ageController.dispose();
    _languagesController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _voiceNoteUrlController.dispose();
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
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_sharp,
            size: 18,
            color: blackColor,
          ),
        ),
        title: Text(
          "Personal Info ",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: blackColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Obx(() {
                    return Center(
                      child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey[400],
                          child: _selectedImage != null
                              ? Container(
                                  height: 58,
                                  width: 58,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    image: DecorationImage(
                                        image: FileImage(_selectedImage!),
                                        fit: BoxFit.cover),
                                  ),
                                )
                              : profileController.imgUrl.value != ""
                                  ? Container(
                                      height: 58,
                                      width: 58,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                profileController.imgUrl.value),
                                            fit: BoxFit.cover),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 30,
                                      backgroundColor: appColor,
                                    )),
                    );
                  }),
                  const SizedBox(
                    height: 6,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        await _pickImage();
                      },
                      child: Text(
                        "Edit Picture",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: appColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: _nameController,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        hintText: "Name",
                        hintStyle: GoogleFonts.roboto(color: blackColor),
                        floatingLabelStyle:
                            GoogleFonts.roboto(color: blackColor),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blackColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: _avatarNameController,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        hintText: "Avtar Name",
                        hintStyle: GoogleFonts.roboto(color: blackColor),
                        floatingLabelStyle:
                            GoogleFonts.roboto(color: blackColor),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blackColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: _emailController,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        hintText: "Email ID",
                        hintStyle: GoogleFonts.roboto(color: blackColor),
                        floatingLabelStyle:
                            GoogleFonts.roboto(color: blackColor),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blackColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: _phoneController,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        hintText: "Phone Number",
                        hintStyle: GoogleFonts.roboto(color: blackColor),
                        floatingLabelStyle:
                            GoogleFonts.roboto(color: blackColor),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blackColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: _ageController,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        hintText: "Age ",
                        hintStyle: GoogleFonts.roboto(color: blackColor),
                        floatingLabelStyle:
                            GoogleFonts.roboto(color: blackColor),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blackColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: _addressController,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        hintText: "Address ",
                        hintStyle: GoogleFonts.roboto(color: blackColor),
                        floatingLabelStyle:
                            GoogleFonts.roboto(color: blackColor),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blackColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("Languages",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: _languages
                            .map((lang) => Chip(
                                  backgroundColor: whiteColor,
                                  surfaceTintColor: whiteColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: BorderSide(
                                          color: greyMedium1Color, width: 1)),
                                  label: Text(lang),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () =>
                                      setState(() => _languages.remove(lang)),
                                ))
                            .toList(),
                      ),
                      // TextFormField(
                      //   controller: _languagesController,
                      //   decoration: InputDecoration(
                      //     hintText: "Add Languages",
                      //     suffixIcon: IconButton(
                      //       icon: const Icon(Icons.add),
                      //       onPressed: () {
                      //         if (_languagesController.text.isNotEmpty) {
                      //           setState(() {
                      //             _languages.add(_languagesController.text);
                      //             _languagesController.clear();
                      //           });
                      //         }
                      //       },
                      //     ),
                      //   ),
                      //   onFieldSubmitted: (value) {
                      //     if (value.isNotEmpty) {
                      //       setState(() {
                      //         _languages.add(value);
                      //         _languagesController.clear();
                      //       });
                      //     }
                      //   },
                      // ),
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: _languagesController,
                          cursorColor: blackColor,
                          style: TextStyle(color: blackColor),
                          decoration: InputDecoration(
                            hintText: "Add Language",
                            hintStyle: GoogleFonts.roboto(color: blackColor),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                if (_languagesController.text.isNotEmpty) {
                                  setState(() {
                                    _languages.add(_languagesController.text);
                                    _languagesController.clear();
                                  });
                                }
                              },
                            ),
                            floatingLabelStyle:
                                GoogleFonts.roboto(color: blackColor),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(5)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: blackColor),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                _languages.add(value);
                                _languagesController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _voiceNoteUrlController,
                    cursorColor: blackColor,
                    style: TextStyle(color: blackColor),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Voice url ",
                      hintStyle: GoogleFonts.roboto(color: blackColor),
                      floatingLabelStyle: GoogleFonts.roboto(color: blackColor),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(5)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: blackColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Gender",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            onTap: () {
                              profileController.gender.value = 0;
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColor),
                                  ),
                                  child: profileController.gender.value == 0
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Male",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            onTap: () {
                              profileController.gender.value = 1;
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColor),
                                  ),
                                  child: profileController.gender.value == 1
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Female",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            onTap: () {
                              profileController.gender.value = 2;
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColor),
                                  ),
                                  child: profileController.gender.value == 2
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Other",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Intersted In",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            onTap: () {
                              profileController.intersted.value = 0;
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColor),
                                  ),
                                  child: profileController.intersted.value == 0
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Male",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            onTap: () {
                              profileController.intersted.value = 1;
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColor),
                                  ),
                                  child: profileController.intersted.value == 1
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Female",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            onTap: () {
                              profileController.intersted.value = 2;
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColor),
                                  ),
                                  child: profileController.intersted.value == 2
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Other",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final profileData = {
                            "ogName": _nameController.text,
                            "avatarName": _avatarNameController.text,
                            "age": int.parse(_ageController.text),
                            "gender": _gender,
                            "languages": _languages,
                            "email": _emailController.text,
                            "address": _addressController.text,
                            "voiceNote": {
                              "public_id": "sample_voice_note_id",
                              "url": _voiceNoteUrlController.text,
                            },
                          };
                          setState(() {
                            isLoading = true;
                          });
                          await mainApplicationController
                              .profileCreate(profileData)
                              .then((onValue) {
                            if (onValue != null) {
                              Get.snackbar(
                                  "wow", "profile create successfully");
                              if (widget.isRegistration) {
                                Get.to(() => const MainHomeScreen());
                              }
                            } else {
                              Get.snackbar("Alert", "profile create failed");
                            }
                          });
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Text(widget.isRegistration ? 'Save' : 'Update'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Center(
                  child: CircularProgressIndicator(),
                ))
        ],
      ),
    );
  }
}
