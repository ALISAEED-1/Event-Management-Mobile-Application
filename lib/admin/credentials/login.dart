import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../homepage/admin_root_page.dart';

class Loginadmin extends StatefulWidget {
  const Loginadmin({super.key});

  @override
  State<Loginadmin> createState() => _LoginadminState();
}

class _LoginadminState extends State<Loginadmin> {
  // ─── Hardcoded admin credentials ───────────────────────────────────────────
  static const _adminEmail = 'admin@interntask.com';
  static const _adminPassword = 'Admin@1234';
  // ───────────────────────────────────────────────────────────────────────────

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate a brief loading delay for UX, then validate locally
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (email == _adminEmail && password == _adminPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminRootPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid admin credentials')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen height to fix the background stretch
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          // Ensures the stack (and the background image) spans the full height
          height: screenHeight,
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: Image.asset(
                  'assets/images/paw pattern 1.png',
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -1.5),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFFD32F2F),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Back',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFD32F2F),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Text(
                            'Admin ',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD32F2F),
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 4),
                      child: Text(
                        'Enter your admin credentials to continue',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Email field
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          hintText: 'admin@example.com',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xff9E9E9E),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Colors.grey, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xffD1D1D1), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xFFD32F2F), width: 1.5),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Password field
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          hintText: '***********',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xff9E9E9E),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.grey, size: 20),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xffD1D1D1), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xFFD32F2F), width: 1.5),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Login button
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                              : Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}