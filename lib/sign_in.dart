import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:circulahealth/api/google_sign_in.dart';
import 'package:circulahealth/components/animated_button.dart';
import 'package:circulahealth/components/loading_component.dart';
import 'package:circulahealth/components/show_alert.dart';
import 'package:circulahealth/components/social_button.dart';
import 'package:circulahealth/map_page.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:circulahealth/sign_up.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isChecked = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
        child: Consumer<MainProvider>(builder: (context, mainProvider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Sign in to your account',
                                style: TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "Let's sign in to your account",
                            style: TextStyle(
                              color: Color(0xFF696969),
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            "Email",
                            style: TextStyle(
                              color: Color(0xFF696969),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Your email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFDFDFDF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFDFDFDF),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "Password",
                            style: TextStyle(
                              color: Color(0xFF696969),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '*********',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFDFDFDF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFDFDFDF),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isChecked = !isChecked;
                                      });
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isChecked
                                            ? Colors.blue
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isChecked
                                              ? Colors.blue
                                              : const Color(0xFF696969),
                                          width: 1,
                                        ),
                                      ),
                                      child: isChecked
                                          ? const Icon(Icons.check,
                                              size: 18.0, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "Remember me",
                                      style: TextStyle(
                                        color: Color(0xFF696969),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              InkWell(
                                onTap: () {},
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                    color: Color(0xFF216FFF),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: CustomAnimatedButton(
                            buttonTitle: "Sign In",
                            onButtonpressed: () async {
                              final emailRegex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (_emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty) {
                                if (!emailRegex
                                    .hasMatch(_emailController.text)) {
                                  return AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.info,
                                    animType: AnimType.scale,
                                    title: 'Alert!',
                                    desc: 'Please enter an email format!',
                                    btnOkOnPress: () {},
                                    btnOkColor: Colors.green,
                                    headerAnimationLoop: false,
                                  ).show();
                                }
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  isLoading = true;
                                });
                                var result = await signInWithEmailPassword(
                                  _emailController.text,
                                  _passwordController.text,
                                  mainProvider,
                                );
                                if (result != "success") {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.scale,
                                    title: 'Alert!',
                                    desc: result,
                                    btnOkOnPress: () {},
                                    btnOkColor: Colors.green,
                                    headerAnimationLoop: false,
                                  ).show();
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MapPage(),
                                    ),
                                  );
                                }
                              } else {
                                return AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.info,
                                  animType: AnimType.scale,
                                  title: 'Alert!',
                                  desc: 'Please fill in email and password',
                                  btnOkOnPress: () {},
                                  btnOkColor: Colors.green,
                                  headerAnimationLoop: false,
                                ).show();
                              }
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  height: 5,
                                  thickness: 1,
                                  color: Color(0xFFDDDDDD),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  "or",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFDDDDDD),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  height: 5,
                                  thickness: 1,
                                  color: Color(0xFFDDDDDD),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SocialButton(
                          title: "Apple",
                          topPadding: 10,
                          iconString: "apple_icon",
                          onButtonTap: () {},
                          isSignUp: false,
                        ),
                        SocialButton(
                          title: "Google",
                          topPadding: 10,
                          iconString: "google_icon",
                          onButtonTap: () async {
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              var result = await signInWithGoogle(mainProvider);
                              if (result != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MapPage(),
                                  ),
                                );
                              }
                              setState(() {
                                isLoading = false;
                              });
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          isSignUp: false,
                        ),
                        SocialButton(
                          title: "X",
                          topPadding: 10,
                          iconString: "x_icon",
                          onButtonTap: () {},
                          isSignUp: false,
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 20,
                          ),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "Sign up with email",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                        decorationThickness: 1,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUp(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isLoading) const LoadingComponent(),
            ],
          );
        }),
      )),
    );
  }
}
