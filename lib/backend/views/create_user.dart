import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../backend/models/users.dart';
import '../../backend/services/user_services.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add User", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Register New User", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 30),

            // Reusing your Container + TextField style
            _buildSimpleField(nameController, "Username"),
            const SizedBox(height: 16),
            _buildSimpleField(emailController, "Email Address"),
            const SizedBox(height: 16),
            _buildSimpleField(phoneController, "Phone Number"),
            const SizedBox(height: 24),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () async {
                  setState(() => isLoading = true);

                  UsersModel newUser =  UsersModel(
                    docId: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text,

                  );

                  await UserServices().createUser(newUser).then((val) {
                    setState(() => isLoading = false);
                    Navigator.pop(context);
                  });
                },
                child: Text("Save User", style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleField(TextEditingController controller, String hint) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        color: Colors.grey.shade300,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}