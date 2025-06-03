import 'package:circulahealth/api/google_sign_in.dart';
import 'package:circulahealth/components/animated_button.dart';
import 'package:circulahealth/components/loading_component.dart';
import 'package:circulahealth/components/social_button.dart';
import 'package:circulahealth/map_page.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:circulahealth/sign_in.dart';
import 'package:circulahealth/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<MainProvider>(builder: (context, mainProvider, child) {
        return Stack(
          children: [
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Circula',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2170FF),
                            ),
                          ),
                          TextSpan(
                            text: 'ting Blood to Those Who Need It Most',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        "Help ensure a steady flow of life-saving blood for those who need it most.",
                        style:
                            TextStyle(color: Color(0xFF696969), fontSize: 18),
                      ),
                    ),
                    SocialButton(
                      title: "Apple",
                      topPadding: 0,
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
                    ),
                    SocialButton(
                      title: "X",
                      topPadding: 10,
                      iconString: "x_icon",
                      onButtonTap: () {},
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CustomAnimatedButton(
                        buttonTitle: "Sign up with email",
                        onButtonpressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUp(),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CustomAnimatedButton(
                        buttonTitle: "Sign in with email",
                        buttonColor: const Color(0xFFAB92FF),
                        borderColor: const Color(0xFFAB92FF),
                        onButtonpressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignIn(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/bottom_icon.svg',
                fit: BoxFit.cover,
              ),
            ),
            if (isLoading) const LoadingComponent(),
          ],
        );
      }),
    );
  }
}
