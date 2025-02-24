import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
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
      resizeToAvoidBottomInset: false,
      backgroundColor: whiteColor,
      // appBar: AppBar(
      //   backgroundColor: whiteColor,
      //   surfaceTintColor: whiteColor,
      //   leading: IconButton(
      //       onPressed: () {
      //         Navigator.pop(context);
      //       },
      //       icon: const Icon(
      //         Icons.arrow_back_ios_new,
      //         size: 18,
      //       )),
      //   title: const Text(
      //     'Intro',
      //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      //   ),
      //   actions: const [Icon(Icons.info_outline), SizedBox(width: 16)],
      // ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: height,
              width: width,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildProfileCard(
                        appColor, appGreenColor, greyMedium1Color),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: width * 0.16,
              right: width * 0.16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 9,
                      offset: Offset(0, 7),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const HomePage()),
                        // );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8, horizontal: width * 0.11),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          Icons.call,
                          color: blackColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 8, horizontal: width * 0.11),
                      decoration: BoxDecoration(
                        color: appColor,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        Icons.person,
                        color: whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(appColor, appColorGreen, greyMedium1Color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: appColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Salvi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('23k Mint',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: appColorGreen, size: 16),
                      Text(' 4.9', style: TextStyle(color: appColorGreen)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 6),
        const Text('Professional Listener',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const Text(
          "Namaste! I'm Nirali and speak Hindi. When I'm not whipping up delicious treats in the kitchen.",
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 10),
        const Text('Expertise',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildChips(['Empathy', 'Compassion', 'Problem-Solving', 'Loneliness'],
            greyMedium1Color),
        const SizedBox(height: 10),
        const Text('Language',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'Hindi',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        const SizedBox(height: 12),
        const Text('Timing',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          '23k mint',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
        )
      ],
    );
  }

  Widget _buildChips(List<String> labels, greyMedium1Color) {
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
