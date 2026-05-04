import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    // Dynamic theme colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // AppBar is removed here
      body: SafeArea(
        child: Column(
          children: [
            // --- CUSTOM APP BAR INSIDE BODY ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Notification",
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // --- NOTIFICATION LIST ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: 8,
                itemBuilder: (context, index) {
                  bool isUnread = index < 3;
                  return _buildNotificationItem(isUnread, isDark, textColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(bool isUnread, bool isDark, Color? textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Dynamic background: Light grey for light mode, Dark grey/black for dark mode
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              "assets/images/notification.png",
              width: 60,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),

          // Notification Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lorem ipsum dolor sit amet consectetur.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor?.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Status and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                "4:00pm",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: textColor?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}