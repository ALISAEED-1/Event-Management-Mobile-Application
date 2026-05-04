import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/users.dart';
import '../../backend/services/auth.dart';
import '../../backend/services/user_services.dart';
import '../homepage/root_page.dart';
import 'login.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers moved inside the state for proper lifecycle management
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController cpasswordcontroller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    cpasswordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Locked background
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Optional: small touch target padding
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Prevents expanding to full width
                            children: [
                              // 1. The small, elevated back arrow
                              Transform.translate(
                                // Negative Y value pushes it UP.
                                // (0, -1) or (0, -1.5) provides the minute correction to align with the vertical line of the 'B'
                                offset: const Offset(0, -1.5),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFFD32F2F), // Red matching your branding
                                  size: 16, // Much smaller than the text for that minimalist look
                                ),
                              ),

                              // Small spacer between arrow and text
                              const SizedBox(width: 4),

                              // 2. The main 'Back' text
                              Text(
                                'Back',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFD32F2F), // Same red
                                  fontSize: 18, // Text size establishes the visual weight
                                  fontWeight: FontWeight.w600, // Medium-Bold for clarity
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Text(
                          "Create",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD32F2F),
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          " Account",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: Colors.black, // Locked text color
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
                          "Enter given detail to create your \naccount",
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

                  // Email Field
                  _buildLockedTextField(
                    controller: emailcontroller,
                    label: "EMAIL",
                    hint: 'Example23@gmail.com',
                  ),

                  const SizedBox(height: 25),

                  // Password Field
                  _buildLockedTextField(
                    controller: passwordcontroller,
                    label: "Password",
                    hint: '***********',
                    isPassword: true,
                  ),

                  const SizedBox(height: 25),

                  // Confirm Password Field
                  _buildLockedTextField(
                    controller: cpasswordcontroller,
                    label: "Confirm Password",
                    hint: '***********',
                    isPassword: true,
                  ),

                  const SizedBox(height: 50),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        if (emailcontroller.text.trim().isEmpty ||
                            passwordcontroller.text.isEmpty ||
                            cpasswordcontroller.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields')),
                          );
                          return;
                        }
                        if (passwordcontroller.text != cpasswordcontroller.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Passwords do not match')),
                          );
                          return;
                        }

                        setState(() { _isLoading = true; });

                        try {
                          final user = await authservices().registeruser(
                            email: emailcontroller.text.trim(),
                            password: passwordcontroller.text,
                          );

                          await UserServices().createUser(UsersModel(
                            docId: user.uid,
                            email: emailcontroller.text.trim(),
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                          ));

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
                              "Continue",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
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
                      color: Colors.black, // Locked color
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Google Sign Up
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xff9A9A9A), width: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/google_icon.png", width: 24),
                          const SizedBox(width: 15),
                          Text(
                            "Continue with Google",
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

                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "If you have an account ",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Login())
                          );
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD32F2F),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper widget to keep the code clean and colors locked
  Widget _buildLockedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xff9E9E9E), fontSize: 14),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off_outlined, color: Colors.grey)
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xffD1D1D1), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),
      ),
    );
  }
}