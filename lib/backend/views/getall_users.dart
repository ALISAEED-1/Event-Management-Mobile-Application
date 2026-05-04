
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../user/credentials/login.dart';
import '../../user/homepage/root_page.dart';
import '../models/users.dart';
import '../services/auth.dart';
import '../services/user_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController cpasswordcontroller = TextEditingController();
  bool isloading = false;
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50 ,

      body: Padding(
        padding: const EdgeInsets.only(top: 110,left:30 , right: 30),
        child: Column(
          children: [

            Text("Karyana" ,style: GoogleFonts.montserrat(
                color: Color(0xffE31A21),
                fontSize: 40,
                fontWeight: FontWeight.w700
            ),textAlign: TextAlign.center,),

            SizedBox(height: 15,),
            Text("Create Account" ,style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w500
            ),textAlign: TextAlign.center,),


            SizedBox(height: 30,),


            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 60,
                color: Colors.white,
                child: TextField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                    hintText: 'User Name',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 60,
                color: Colors.white,
                child: TextField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 60,
                color: Colors.white,
                child: TextField(
                  controller: phonecontroller,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 60,
                color: Colors.white,
                child: TextField(
                  controller: addresscontroller,
                  decoration: InputDecoration(
                    hintText: 'Address',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 60,
                color: Colors.white,
                child: TextField(
                  controller: passwordcontroller,

                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 60,
                color: Colors.white,
                child: TextField(
                  controller: cpasswordcontroller,

                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),


            SizedBox(height: 20,),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [

                  Container(
                    width: 20,
                    height: 20,
                    child: Checkbox(value: isChecked, onChanged: (bool?value){
                      setState(() {
                        isChecked = value ??false;
                      });
                    },
                      activeColor: Color(0xffE31A21),
                      checkColor: Colors.white,

                    ),
                  ),
                  SizedBox(width: 10,),
                  Text("I agree to the Terms and Conditions",style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color:Colors.black,
                  ),)
                ],
              ),
            ),

            SizedBox(height: 20,),

            isloading ? Center(child: CircularProgressIndicator(),):

            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(onPressed: () async {
                if (emailcontroller.text.trim().isEmpty ||
                    passwordcontroller.text.isEmpty ||
                    passwordcontroller.text != cpasswordcontroller.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        passwordcontroller.text != cpasswordcontroller.text
                            ? 'Passwords do not match'
                            : 'Please fill in all fields',
                      ),
                    ),
                  );
                  return;
                }

                setState(() { isloading = true; });

                try {
                  final user = await authservices().registeruser(
                    email: emailcontroller.text.trim(),
                    password: passwordcontroller.text,
                  );

                  await UserServices().createUser(UsersModel(
                    docId: user.uid,
                    name: namecontroller.text.trim(),
                    email: emailcontroller.text.trim(),
                    phone: phonecontroller.text.trim(),
                    address: addresscontroller.text.trim(),
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                  ));

                  if (!mounted) return;
                  setState(() { isloading = false; });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RootPage()),
                  );
                } catch (e) {
                  if (!mounted) return;
                  setState(() { isloading = false; });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      )

                  ),

                  child: Text("sign up",style: GoogleFonts.poppins(
                      color: Color(0xffFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                  ),)),
            ),

            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                }, child: Text("Login",style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Color(0xffE31A21),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xffE31A21),
                ),
                ),
                ),
              ],
            )

          ],
        ),
      ),

    );
  }
}
