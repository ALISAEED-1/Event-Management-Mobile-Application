import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/onboarding_model.dart';
import 'role_selection.dart';

class Splashscreen2 extends StatefulWidget {
  const Splashscreen2({super.key});
  @override
  State<Splashscreen2> createState() => _Splashscreen2State();
}

class _Splashscreen2State extends State<Splashscreen2> {
  PageController controller = PageController();
  int currentIndex = 0;

  List<OnboardingModel> onboardinglist = [
    OnboardingModel(
        image: 'assets/images/location (1).png',
        text: 'Discover What’s \nHappening Nearby',
        desccription:
        'Find real events from verified community groups and clubs — all in one place.'),
    OnboardingModel(
        image: 'assets/images/ss3.png',
        text: 'Events Sync \nAutomatically',
        desccription:
        'No manual setup — we integrate directly with group calendars for real-time updates.'),
    OnboardingModel(
        image: 'assets/images/ss4.png',
        text: 'Shape the Next \nBig Event',
        desccription:
        'Vote on new event ideas, favorite your picks, and never miss what matters most.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Image.asset(
              "assets/images/paw pattern 1.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Skip Button — hidden on the last page
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 10),
                    child: currentIndex < onboardinglist.length - 1
                        ? TextButton(
                            onPressed: () {
                              // Jump straight to the last page
                              controller.animateToPage(
                                onboardinglist.length - 1,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(
                              "Skip",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFD32F2F),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,

                              ),
                            ),
                          )
                        : const SizedBox(height: 48), // keep layout stable
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemCount: onboardinglist.length,
                    itemBuilder: (context, i) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Image.asset(
                              onboardinglist[i].image,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 50),

                          // Title with specific staggering
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                onboardinglist[i].text,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 32,
                                  height: 1.1,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),

                          // Description
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 40, right: 40),
                            child: Text(
                              onboardinglist[i].desccription,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: const Color(0xFF727272),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: controller,
                        count: onboardinglist.length,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: Color(0xFFD32F2F),
                          dotColor: Color(0xFFE0E0E0),
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Next / Get Started Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              if (currentIndex < onboardinglist.length - 1) {
                                controller.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut);
                              }
                              else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RoleSelection()));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              currentIndex == onboardinglist.length - 1
                                  ? "Get Started"
                                  : "Next",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}