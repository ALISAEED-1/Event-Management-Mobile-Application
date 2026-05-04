//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// import '../models/users.dart';
// import '../providers/user_provider.dart';
// import '../services/user_services.dart';
//
// class EditProfile extends StatefulWidget {
//   const EditProfile({super.key});
//
//   @override
//   State<EditProfile> createState() => _EditProfileState();
// }
//
// class _EditProfileState extends State<EditProfile> {
//
//   TextEditingController namecontroller = TextEditingController();
//   TextEditingController phonecontroller = TextEditingController();
//   TextEditingController addresscontroller = TextEditingController();
//   bool isloading = false;
//
//   @override
//   void initState ()
//   {
//     super.initState();
//
//     final userprovider = context.read<UserProvider>();
//
//     namecontroller = TextEditingController(
//         text: userprovider.getuser().name.toString()
//     );
//     phonecontroller = TextEditingController(
//         text: userprovider.getuser().phone.toString()
//     );
//     addresscontroller = TextEditingController(
//         text: userprovider.getuser().address.toString()
//     );
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.red.shade50 ,
//       body: Padding(
//         padding: const EdgeInsets.only(top: 180, right:30 ,left: 30),
//         child: Column(
//           children: [
//             Text("Karyana" ,style: GoogleFonts.montserrat(
//                 color: Color(0xffE31A21),
//                 fontSize: 40,
//                 fontWeight: FontWeight.w700
//             ),textAlign: TextAlign.center,),
//
//             SizedBox(height: 15,),
//             Text("Edit Profile" ,style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 30,
//                 fontWeight: FontWeight.w500
//             ),textAlign: TextAlign.center,),
//
//             SizedBox(height: 30,),
//
//             ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: Container(
//                 height: 60,
//                 color: Colors.white,
//                 child: TextField(
//                   controller: namecontroller,
//                   decoration: InputDecoration(
//                     hintText: 'User Name',
//                     border: InputBorder.none,
//                     enabledBorder: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10,),
//
//             ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: Container(
//                 height: 60,
//                 color: Colors.white,
//                 child: TextField(
//                   controller: phonecontroller,
//                   decoration: InputDecoration(
//                     hintText: 'Phone Number',
//                     border: InputBorder.none,
//                     enabledBorder: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10,),
//
//             ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: Container(
//                 height: 60,
//                 color: Colors.white,
//                 child: TextField(
//                   controller: addresscontroller,
//                   decoration: InputDecoration(
//                     hintText: 'Address',
//                     border: InputBorder.none,
//                     enabledBorder: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 30,),
//
//             isloading ? Center(child: CircularProgressIndicator(),):
//             ElevatedButton(onPressed: ()async{
//
//
//               try{
//                 isloading = true;
//                 setState(() {
//                 });
//                 final userProvider = context.read<UserProvider>();
//                 await UserServices()
//                     .updateUser(UsersModel(
//                   docId: userProvider.getuser().docId!,
//                   name: namecontroller.text.toString(),
//                   phone: phonecontroller.text.toString(),
//                   address: addresscontroller.text.toString(),
//                 )).then((value)async
//                 {
//                   isloading = false;
//                   setState(() {
//
//                   });
//                   UsersModel usermodel = await UserServices()
//                       .getuserbyID(
//                     userProvider.getuser().docId!,
//                   );
//                   userProvider.setuser(usermodel);
//
//                   Navigator.pop(context);
//                 }
//                 );
//               }
//               catch(e)
//               {
//                 isloading =false;
//                 setState(() {
//
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(e.toString()))
//                 );
//               }
//
//             },
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xff000000),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     )
//
//                 ),
//
//                 child: Text("Update Profile",style: GoogleFonts.poppins(
//                     color: Color(0xffFFFFFF),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600
//                 )
//                 )
//             ),
//
//
//
//
//
//           ],
//         ),
//       ),
//     );
//   }
// }
