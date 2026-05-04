import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profiles/admin_profile.dart';
import 'admin_community.dart';
import 'admin_favorites.dart';
import 'admin_features.dart';
import 'admin_home.dart';

class AdminRootPage extends StatefulWidget {
  const AdminRootPage({super.key});

  @override
  State<AdminRootPage> createState() => _AdminRootPageState();
}

class _AdminRootPageState extends State<AdminRootPage> {
  int _selectedIndex = 0;
  final Color activeColor = const Color(0xFFD32F2F);

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const AdminHome();
      case 1:
        return const AdminFeatures();
      case 2:
        return const AdminCommunity();
      case 3:
        return const AdminFavorites();
      case 4:
        return const AdminProfile();
      default:
        return const AdminHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_selectedIndex),
        child: _buildPage(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: activeColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
        items: [
          _buildNavItem("assets/images/mdi_paw.png", "Home", 0),
          _buildNavItem("assets/images/basil_star-solid.png", "Features", 1),
          _buildNavItem(
              "assets/images/fluent_people-community-24-filled.png",
              "Community", 2),
          _buildNavItem("assets/images/mdi_heart.png", "Favourite", 3),
          _buildNavItem(
              "assets/images/tdesign_setting-filled.png", "Settings", 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      String assetPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        assetPath,
        width: 28,
        height: 28,
        color: _selectedIndex == index ? activeColor : Colors.grey,
      ),
      label: label,
    );
  }
}
