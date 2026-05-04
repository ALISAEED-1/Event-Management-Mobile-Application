import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../admin/credentials/login.dart';
import '../credentials/signup.dart';

class RoleSelection extends StatelessWidget {
  const RoleSelection({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size to ensure the Stack has bounds
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          // Ensure the stack has a defined height to prevent the white screen crash
          height: size.height > 800 ? size.height : 800,
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Image.asset(
                  'assets/images/paw pattern 1.png',
                  fit: BoxFit.cover,
                ),
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Skip button


                    const SizedBox(height: 30),

                    // Illustration
                    Image.asset(
                      'assets/images/welcome.png',
                      height: 260,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Welcome!',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                        color: Colors.black,
                      ),
                    ),

                    // Red underline accent
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 48,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Choose how you want to continue\nSelect an option to proceed based on\nyour role and access.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.55,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Role cards row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 230,
                        child: Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.person_rounded,
                                label: 'User',
                                subtitle:
                                'Explore and access\nfeatures as a user.',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Signup()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.admin_panel_settings_rounded,
                                label: 'Admin',
                                subtitle:
                                'Manage, monitor and\ncontrol the platform.',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Loginadmin()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large icon circle
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: const Color(0xFFD32F2F),
              ),
            ),

            const SizedBox(height: 14),

            // Label
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            // Description
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.black45,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 14),

            // Arrow
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFFD32F2F),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}