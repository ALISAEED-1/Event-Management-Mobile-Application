import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interntask/user/credentials/signup.dart';
import '../../backend/services/auth.dart';
import '../homepage/root_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Moved inside state to ensure they are cleaned up properly
  final TextEditingController phonecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    phonecontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hardcoded white background
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Image.asset(
                "assets/images/paw pattern 1.png",
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD32F2F),
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          " To Your Account",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: Colors.black, // Locked color
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Text(
                          "Enter given detail to login to your \naccount",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black87, // Locked color
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: TextField(
                      controller: phonecontroller,
                      style: const TextStyle(color: Colors.black), // Locked text color
                      decoration: InputDecoration(
                        label: Text(
                          "Phone number",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: const Color(0xff000000),
                          ),
                        ),
                        hintText: '+92-123456789',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xff9E9E9E),
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xffD1D1D1),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: TextField(
                      controller: passwordcontroller,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black), // Locked text color
                      decoration: InputDecoration(
                        label: Text(
                          "Password",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: const Color(0xff000000),
                          ),
                        ),
                        hintText: '***********',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xff9E9E9E),
                          fontSize: 14,
                        ),
                        suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xffD1D1D1),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF000000),
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          if (phonecontroller.text.trim().isEmpty ||
                              passwordcontroller.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all fields')),
                            );
                            return;
                          }

                          setState(() { _isLoading = true; });

                          try {
                            await authservices().loginuser(
                              email: phonecontroller.text.trim(),
                              password: passwordcontroller.text,
                            );

                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const RootPage()),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            if (mounted) setState(() { _isLoading = false; });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    "OR",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          side: const BorderSide(
                            color: Color(0xff9A9A9A),
                            width: 0.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Better alignment
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Image.asset("assets/images/google_icon.png"),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "Continue with google",
                              style: GoogleFonts.poppins(
                                color: const Color(0xff505050),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "If you don’t have an account ",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup()));
                        },
                        child: Text(
                          "Create Account",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD32F2F),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFFD32F2F),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}