import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:circulahealth/components/animated_button.dart';
import 'package:circulahealth/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({super.key});

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

enum PageState { confirmations, payments }

class _ConfirmPageState extends State<ConfirmPage> {
  PageState pageState = PageState.confirmations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove default shadow since we're using BoxShadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              if (pageState == PageState.payments) {
                pageState = PageState.confirmations;
              } else {
                Navigator.pop(context);
              }
            });
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(
                16.0,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pageState == PageState.confirmations
                        ? "Confirmations"
                        : "Payments",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Lorem ipsum dolor sit amer consectetur",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  pageState == PageState.confirmations
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 180,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF87848,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      20.0,
                                    ),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Darah AB+",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "350CC - 1 Pouch",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Rumah Sakit Hermina, Ciledug",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/images/donor-bg.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 20.0,
                                bottom: 20.0,
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomAnimatedButton(
                                      borderColor: Colors.black,
                                      buttonColor: Colors.black,
                                      onButtonpressed: () {},
                                      buttonTitle: "See directions",
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  ),
                                  Expanded(
                                    child: CustomAnimatedButton(
                                      borderColor: const Color(0xFFE7E7E7),
                                      buttonColor: Colors.white,
                                      onButtonpressed: () {},
                                      buttonTitle: "How to",
                                      textColor: const Color(0xFF777777),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "Sed ut perspiciatis",
                              style: TextStyle(
                                color: Color(
                                  0xFF3E3E3E,
                                ),
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                16.0,
                              ),
                              margin: EdgeInsets.only(
                                bottom: 20.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  14.0,
                                ),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE8E8E8,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Pay with QRIS",
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  SvgPicture.asset(
                                    'assets/images/qris.svg',
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                16.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  14.0,
                                ),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE8E8E8,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Pay with E-Wallet",
                                      ),
                                      Icon(
                                        Icons.arrow_downward_sharp,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/gopay.svg',
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      SvgPicture.asset(
                                        'assets/images/ovo.svg',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              padding: const EdgeInsets.all(
                                16.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  14.0,
                                ),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE8E8E8,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Pay with Virtual Account",
                                      ),
                                      Icon(
                                        Icons.arrow_downward_sharp,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/bca.svg',
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      SvgPicture.asset(
                                        'assets/images/mandiri.svg',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                16.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  14.0,
                                ),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE8E8E8,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Pay with IDRX",
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  SvgPicture.asset(
                                    'assets/images/\$IDRX.svg',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              )),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(
                16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rp 495.321,00",
                        style: TextStyle(
                          color: Color(0xFF373737),
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                      Text(
                        "Include taxes and other fees",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 35.0),
                  Expanded(
                    child: CustomAnimatedButton(
                      onButtonpressed: () {
                        if (pageState == PageState.confirmations) {
                          setState(() {
                            pageState = PageState.payments;
                          });
                        } else {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.scale,
                            title: 'Success!',
                            desc: 'Successfully paid!',
                            btnOkOnPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapPage(),
                                ),
                              );
                            },
                            onDismissCallback: (type) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapPage(),
                                ),
                              );
                            },
                            btnOkColor: Colors.green,
                            headerAnimationLoop: false,
                          ).show();
                        }
                      },
                      buttonTitle: "Continue",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
