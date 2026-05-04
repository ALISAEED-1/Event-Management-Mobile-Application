
import 'package:flutter/material.dart';
import 'splashscreen_2.dart';

class Splashscreenadmin1 extends StatefulWidget {
  const Splashscreenadmin1({super.key});

  @override
  State<Splashscreenadmin1> createState() => _Splashscreenadmin1State();

}

class _Splashscreenadmin1State extends State<Splashscreenadmin1> {
  @override
  void initState() {
    super.initState();

    // ⏳ Delay for 5 seconds, then navigate
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Splashscreenadmin2()),
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
