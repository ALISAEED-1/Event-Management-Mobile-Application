
import 'package:flutter/material.dart';
import 'package:interntask/user/splash_screen/splashscreen_2.dart';

class Splashscreen1 extends StatefulWidget {
  const Splashscreen1({super.key});

  @override
  State<Splashscreen1> createState() => _Splashscreen1State();

}

class _Splashscreen1State extends State<Splashscreen1> {
  @override
  void initState() {
    super.initState();

    // ⏳ Delay for 5 seconds, then navigate
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Splashscreen2()), // 👈 replace with your page
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xffCF3232),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 400,left: 75),
            child: Image.asset("assets/images/logo.png",width: 276,height: 119,),
          ),
        ],
      ),

    );
  }
}
