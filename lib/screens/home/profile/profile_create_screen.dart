import 'package:flutter/material.dart';
import 'package:gad_fly_partner/controller/main_application_controller.dart';
import 'package:gad_fly_partner/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCreateScreen extends StatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  State<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends State<ProfileCreateScreen> {
  MainApplicationController mainApplicationController = Get.find();
  ProfileController profileController = Get.find();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _avatarNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'male';
  final _languagesController = TextEditingController();
  final _languagesController1 = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _voiceNoteUrlController = TextEditingController();

  @override
  void initState() {
    profileController.getProfile().then((profileData) {
      if (profileData != null) {
        setState(() {
          _nameController.text = profileData["additionalInfo"]["ogName"];
          _avatarNameController.text =
              profileData["additionalInfo"]["avatarName"];
          _ageController.text = profileData["additionalInfo"]["age"].toString();
          _gender = profileData["additionalInfo"]["gender"] ?? "";

          _languagesController.text =
              profileData["additionalInfo"]["languages"][0];
          _languagesController1.text =
              profileData["additionalInfo"]["languages"][1];
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
          "Create Profile",
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _avatarNameController,
                    decoration: const InputDecoration(labelText: 'Avatar Name'),
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
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
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    value: _gender,
                    items: <String>['female', 'male', 'other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _gender = newValue;
                        });
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Please select gender' : null,
                  ),
                  TextFormField(
                    controller: _languagesController,
                    decoration:
                        const InputDecoration(labelText: 'preferred Language'),
                  ),
                  TextFormField(
                    controller: _languagesController1,
                    decoration:
                        const InputDecoration(labelText: 'Additional Language'),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
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
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: _voiceNoteUrlController,
                    decoration: const InputDecoration(labelText: 'Voice URL'),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final profileData = {
                            "ogName": _nameController.text,
                            "avatarName": _avatarNameController.text,
                            "age": int.parse(_ageController.text),
                            "gender": _gender,
                            "languages": [
                              _languagesController.text,
                              _languagesController1.text
                            ],
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
                            } else {
                              Get.snackbar("Alert", "profile create failed");
                            }
                          });
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: const Text('Create Profile'),
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
