import 'package:circulahealth/api/google_sign_in.dart';
import 'package:circulahealth/components/animated_button.dart';
import 'package:circulahealth/components/loading_component.dart';
import 'package:circulahealth/components/show_alert.dart';
import 'package:circulahealth/components/social_button.dart';
import 'package:circulahealth/map_page.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:circulahealth/sign_in.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
                                text: 'Start Your Journey with Circula',
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
                            "Sign up and start making an impact",
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
                              fontSize: 20,
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
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '**********',
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
                          padding: const EdgeInsets.only(top: 20),
                          child: CustomAnimatedButton(
                            buttonTitle: "Sign Up",
                            onButtonpressed: () async {
                              if (_emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                var theResult = await signUpWithEmailPassword(
                                    _emailController.text,
                                    _passwordController.text,
                                    mainProvider);
                                if (theResult != "success") {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  showAlert(context, theResult, "Failed", "OK",
                                      () {});
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignIn(),
                                    ),
                                  );
                                }
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
                              FocusScope.of(context).unfocus();
                              await signInWithGoogle(mainProvider);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapPage(),
                                ),
                              );
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                        ),
                        SocialButton(
                          title: "X",
                          topPadding: 10,
                          iconString: "x_icon",
                          onButtonTap: () {},
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
                                  text: "Already have an account? ",
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "Sign in",
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
                                                  const SignIn(),
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
