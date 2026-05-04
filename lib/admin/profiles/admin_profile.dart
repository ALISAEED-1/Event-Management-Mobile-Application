import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interntask/main.dart';

import '../credentials/login.dart';
import 'admin_edit_profile.dart';
import 'admin_notification.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final Color themeRed = const Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25, vertical: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Settings",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage("assets/images/profile.png"),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Admin",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 160,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdminEditProfile()),
                          );
                        },
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.white),
                        label: Text("Edit Profile",
                            style:
                                GoogleFonts.poppins(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeRed,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 25),
                leading: Icon(Icons.notifications_none_outlined,
                    color: iconColor),
                title: Text("Notifications",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black26),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminNotificationPage()),
                ),
              ),
              _customDivider(),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 25),
                leading: Icon(Icons.insert_drive_file_outlined,
                    color: iconColor),
                title: Text("Privacy Policy",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black26),
                onTap: () {},
              ),
              _customDivider(),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 25),
                leading: Icon(Icons.insert_drive_file_outlined,
                    color: iconColor),
                title: Text("Term & Conditions",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black26),
                onTap: () {},
              ),
              _customDivider(),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 25),
                leading: Icon(Icons.help_outline, color: iconColor),
                title: Text("Help & Support",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black26),
                onTap: () {},
              ),
              _customDivider(),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 25),
                leading: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                    color: iconColor),
                title: Text(isDark ? "Light Mode" : "Dark Mode",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                trailing: Switch(
                  value: isDark,
                  activeColor: themeRed,
                  onChanged: (bool value) {
                    themeNotifier.value =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                onTap: () {
                  themeNotifier.value =
                      themeNotifier.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                },
              ),
              _customDivider(),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 25),
                leading: Icon(Icons.logout, color: themeRed),
                title: Text("Logout",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: themeRed)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black26),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Loginadmin()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Divider(height: 1, thickness: 1),
    );
  }
}
