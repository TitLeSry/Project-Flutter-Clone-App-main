import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_se/auth/firebase_auth_service.dart';
import '../../components/button_field.dart';
import '../../components/text_field.dart';
import '../../widgets/logo_image.dart';
import '../../widgets/logo_zone.dart';

class AdminRegister extends StatefulWidget {
  AdminRegister({super.key});

  @override
  State<AdminRegister> createState() => _RegisterState();
}

class _RegisterState extends State<AdminRegister> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final telController = TextEditingController();
  final ageController = TextEditingController();
  final signUp_time = DateTime.now();
  final bool _obscureText = true;
  List roleList = ['manager', 'programer', 'employee', 'customer'];
  var roleChoose;
  final bool noti = true;
  // late String newValue;

  @override
  // void dispose() {
  //   userController.dispose();
  //   emailController.dispose();
  //   passwordController.dispose();
  //   confirmPasswordController.dispose();
  //   super.dispose();
  // }

  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [

          const LogoZone(),

          const LogoImage(),

          Positioned(
            top: 200,
            left: 50,
            right: 50,
            child: Container(
              width: 300,
              height: 545,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Color(0xA2000000),
                    offset: Offset(2, 2),
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              alignment: const AlignmentDirectional(0, 0),
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Sign_In",
                                  style: GoogleFonts.mitr(
                                    textStyle: const TextStyle(
                                        color: Color(0xff3C696F),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                const TextSpan(text: "  "),
                                TextSpan(
                                  text: "Register",
                                  style: GoogleFonts.mitr(
                                    textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      child: Column(
                        children: [
                          MyTextField(
                            hintText: "Enter email",
                            controller: emailController,
                            obscureText: false,
                            labelText: "Email",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyTextField(
                            hintText: "Fill in your first and last name.",
                            controller: userController,
                            obscureText: false,
                            labelText: "Username",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyTextField(
                            hintText: "Enter your age",
                            controller: ageController,
                            obscureText: false,
                            labelText: "Age",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyTextField(
                            hintText: "Enter your phone number.",
                            controller: telController,
                            obscureText: false,
                            labelText: "Telephone Number",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyTextField(
                            hintText: "Enter password",
                            controller: passwordController,
                            obscureText: true,
                            labelText: "Password",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          DropdownButton(
                            hint: Text(
                              'Please select a position :',
                              style: GoogleFonts.mitr(
                                textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 49, 93, 101),
                                  decoration: TextDecoration.underline,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            value: roleChoose,
                            onChanged: (newValue) {
                              setState(() {
                                roleChoose = newValue;
                              });
                            },
                            items: roleList.map((valueItem) {
                              return DropdownMenuItem(
                                value: valueItem,
                                child: Text(valueItem),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          MyButton(
                            onTap: _signUp,
                            hinText: 'Register',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signUp() async {
    try {
      User? user = await _auth.signUpWithEmailAndPassword(
          emailController.text, passwordController.text);
      if (user != null) {
        String uid = user.uid;
        await addUserCollection(
          userController.text.trim(),
          emailController.text.trim(),
          roleChoose,
          int.parse(ageController.text.trim()),
          Timestamp.now(),
          uid,
          telController.text,
        );
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Member registration completed",
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
        print("User is successfully created");
        Navigator.pop(context);
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title:
              "Email already be used.\nIncorrect information\nPlease check again.",
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
      }
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: "Application completed",
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    } catch (error) {
      print(error);
    }
  }

  Future addUserCollection(
    String name,
    String email,
    String role,
    int age,
    Timestamp init_time,
    String uid,
    String tel,
    // bool notification // Add uid as an argument here
  ) async {
    if (role != 'employee') {
      await FirebaseFirestore.instance.collection('user').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'age': age,
        'init_time': init_time,
        'uid': uid, // Use uid here
        'tel': tel,
      });
    } else {
      await FirebaseFirestore.instance.collection('user').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'age': age,
        'init_time': init_time,
        'uid': uid, // Use uid here
        'tel': tel,
        'isRea': false,
        'call_number': '0'
      });
    }
  }
}
