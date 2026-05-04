//
// Stack(
// children: [
// ClipRRect(
// borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
// child: Image.asset("assets/images/features.png", height: 200, width: double.infinity, fit: BoxFit.cover),
// ),
// Positioned(
// top: 15,
// right: 15,
// child: GestureDetector(
// onTap: onFavTap,
// child: Icon(
// isFav ? Icons.favorite : Icons.favorite_border,
// color: isFav ? const Color(0xFFD32F2F) : Colors.white,
// size: 28,
// ),
// ),
// ),
// ],
// ),
// Padding(
// padding: const EdgeInsets.all(16.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text("Made in Melanin! Black History Month Social.....",
// style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
// const SizedBox(height: 10),
// Row(children: [
// const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87),
// const SizedBox(width: 8),
// Text("28 October 2025 6:00pm GMT", style: GoogleFonts.poppins(fontSize: 13)),
// ]),
// const SizedBox(height: 20),
// SizedBox(
// width: double.infinity,
// height: 50,
// child: ElevatedButton(
// onPressed: () {},
// style: ElevatedButton.styleFrom(
// backgroundColor: const Color(0xFFD32F2F),
// shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// ),
// child: Text("Add to my calendar", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
// ),
// ),
// ],
// ),
// ),