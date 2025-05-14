import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:circulahealth/api/google_sign_in.dart';
import 'package:circulahealth/components/animated_button.dart';
import 'package:circulahealth/components/loading_component.dart';
import 'package:circulahealth/components/show_alert.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

enum Donating { have, haveNot }

class Donor extends StatefulWidget {
  Donor({super.key});

  @override
  State<Donor> createState() => _DonorState();
}

class _DonorState extends State<Donor> {
  bool haveDonatedValue = false;
  bool haveNotDonatedValue = false;
  Donating? _donating;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _homeLocationController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String? pickedBloodType = null;
  late MainProvider _mainProvider;
  var userData;

  List<String> items = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery); // or .camera

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isLoading = false;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _mainProvider = Provider.of<MainProvider>(context, listen: false);
        setState(() {
          _mainProvider.setIsLoading(true);
        });
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          setState(() {
            _mainProvider.setIsLoading(false);
          });
          return;
        }

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final theData = doc.data();
          userData = theData;
          if (theData?['hasRegistered']) {
            if (mounted) {
              setState(() {
                _mainProvider.setDonorPageState(DonorPageState.profile);
              });
            }
          } else if (theData?['hasChosenDonateBlood']) {
            if (mounted) {
              setState(() {
                _mainProvider.setDonorPageState(DonorPageState.register);
              });
            }
          }
        }
        setState(() {
          _mainProvider.setIsLoading(false);
        });
      } catch (e) {
        setState(() {
          _mainProvider.setIsLoading(false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        return mainProvider.donorPageState == DonorPageState.donor
            ? SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome, Donors!",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        child: const Text(
                          "Let's register before you help others.",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Radio(
                                  visualDensity: const VisualDensity(
                                      horizontal: VisualDensity.minimumDensity,
                                      vertical: VisualDensity.minimumDensity),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: Donating.have,
                                  groupValue: _donating,
                                  onChanged: (Donating? value) {
                                    setState(() {
                                      _donating = value;
                                      print(_donating);
                                    });
                                  },
                                ),
                              ),
                              const Text(
                                'I have donated blood before.',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Radio(
                                    visualDensity: const VisualDensity(
                                        horizontal:
                                            VisualDensity.minimumDensity,
                                        vertical: VisualDensity.minimumDensity),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    value: Donating.haveNot,
                                    groupValue: _donating,
                                    onChanged: (Donating? value) {
                                      setState(() {
                                        _donating = value;
                                        print(_donating);
                                      });
                                    },
                                  ),
                                ),
                                const Text(
                                  'I have not donated blood before.',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        margin: const EdgeInsets.only(
                          top: 80,
                        ),
                        child: CustomAnimatedButton(
                          onButtonpressed: () async {
                            FocusScope.of(context).unfocus();
                            if (_donating == null) {
                              return AwesomeDialog(
                                context: context,
                                dialogType: DialogType.info,
                                animType: AnimType.scale,
                                title: 'Info!',
                                desc: 'Please pick an option!',
                                btnOkOnPress: () {},
                                btnOkColor: Colors.green,
                                headerAnimationLoop: false,
                              ).show();
                            }
                            mainProvider.setIsLoading(true);
                            if (_donating == Donating.haveNot) {
                              showAlert(
                                  context,
                                  "In order to provide proof to be a donor in Circula.",
                                  "You must donate blood first",
                                  "Find nearest place to give blood", () {
                                setState(() {
                                  mainProvider.setSelectedIndex(2);
                                  mainProvider.setCurrentBottomTitle("Find");
                                });
                              });
                            } else {
                              await updateUserProfileData({
                                "hasChosenDonateBlood": true,
                              });
                              setState(() {
                                mainProvider.donorPageState =
                                    DonorPageState.register;
                              });
                            }
                            mainProvider.setIsLoading(false);
                          },
                          buttonTitle: "Continue",
                        ),
                      )
                    ],
                  ),
                ),
              )
            : mainProvider.donorPageState == DonorPageState.register
                ? SafeArea(
                    child: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Register as Donor",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                bottom: 10.0,
                                top: 10.0,
                              ),
                              child: Text(
                                "Full name",
                                style: TextStyle(
                                  color: Color(0xFF696969),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                hintText: 'Full name',
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 10.0,
                                          top: 20.0,
                                        ),
                                        child: Text(
                                          "Blood type",
                                          style: TextStyle(
                                            color: Color(0xFF696969),
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                30,
                                        child: DropdownButtonFormField<String>(
                                          hint: const Text("Select blood type"),
                                          value: pickedBloodType,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFDFDFDF),
                                                width: 2.0,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFDFDFDF),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              pickedBloodType = newValue!;
                                            });
                                          },
                                          items: items
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 10.0,
                                          top: 20.0,
                                        ),
                                        child: Text(
                                          "Age",
                                          style: TextStyle(
                                            color: Color(0xFF696969),
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                30,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly, // Only allows 0-9
                                          ],
                                          controller: _ageController,
                                          decoration: InputDecoration(
                                            hintText: 'Age',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFDFDFDF),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFDFDFDF),
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                bottom: 10.0,
                                top: 20.0,
                              ),
                              child: Text(
                                "Home location",
                                style: TextStyle(
                                  color: Color(0xFF696969),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextField(
                              controller: _homeLocationController,
                              decoration: InputDecoration(
                                hintText: 'Home Location',
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
                              padding: EdgeInsets.only(
                                top: 20.0,
                              ),
                              child: Text(
                                "Upload Profile Picture",
                                style: TextStyle(
                                  color: Color(0xFF696969),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (_isLoading) return;
                                _pickImage();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 50),
                                margin: const EdgeInsets.only(
                                  top: 20.0,
                                ),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFDFDFDF),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _isLoading
                                    ? const Center(
                                        child: SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.blue),
                                              strokeWidth: 4.0,
                                            )),
                                      )
                                    : _imageFile != null
                                        ? Image.file(
                                            _imageFile!,
                                            height: 200,
                                          )
                                        : const Icon(Icons.upload,
                                            color: Colors.black, size: 80.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: CustomAnimatedButton(
                                onButtonpressed: () async {
                                  try {
                                    FocusScope.of(context).unfocus();
                                    if (_isLoading) return;
                                    if (_ageController.text == "" ||
                                        _fullNameController.text == "" ||
                                        _imageFile == null ||
                                        pickedBloodType == null ||
                                        _homeLocationController.text == "") {
                                      return AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.info,
                                        animType: AnimType.scale,
                                        title: 'Info!',
                                        desc: 'Please fill all the data!',
                                        btnOkOnPress: () {},
                                        btnOkColor: Colors.green,
                                        headerAnimationLoop: false,
                                      ).show();
                                    }
                                    mainProvider.setIsLoading(true);
                                    String photoUrl = mainProvider
                                            .userCredential.user?.photoURL ??
                                        "";
                                    if (_imageFile != null) {
                                      photoUrl = await uploadProfilePicture(
                                          _imageFile ?? File(""),
                                          mainProvider
                                                  .userCredential.user?.uid ??
                                              "");
                                      await mainProvider.userCredential.user
                                          ?.updatePhotoURL(photoUrl);
                                    }
                                    await updateUserProfileData({
                                      "fullName": _fullNameController.text,
                                      "bloodType": pickedBloodType,
                                      "age":
                                          int.tryParse(_ageController.text) ??
                                              0,
                                      "homeLocation":
                                          _homeLocationController.text,
                                      "photoUrl": photoUrl,
                                      "hasRegistered": true
                                    });
                                    mainProvider.setIsLoading(false);
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user == null) return null;

                                    final doc = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .get();
                                    setState(() {
                                      if (doc.exists) {
                                        final theData = doc.data();
                                        userData = theData;
                                      }
                                      mainProvider.setDonorPageState(
                                          DonorPageState.profile);
                                    });
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                buttonTitle: "Continue",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : mainProvider.donorPageState == DonorPageState.profile
                    ? SafeArea(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            color: Color(0xFF315DF6),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(top: 100),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 65.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                userData?["fullName"] ?? "",
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                userData?["homeLocation"] ?? "",
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                              "Blood type: ",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            Text(
                                                              userData?[
                                                                      "bloodType"] ??
                                                                  "",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                              "Age: ",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            Text(
                                                              userData?["age"]
                                                                      ?.toString() ??
                                                                  "",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFE3E7FD),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          8,
                                                        ),
                                                      ),
                                                      child: const Column(
                                                        children: [
                                                          Text(
                                                            "0",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 22,
                                                            ),
                                                          ),
                                                          Text(
                                                            "Points",
                                                            style: TextStyle(
                                                              fontSize: 18,
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
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                            top: 20.0,
                                          ),
                                          child: const TabBar(
                                            tabs: [
                                              Tab(
                                                child: Text(
                                                  "Donor History",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                              ),
                                              Tab(
                                                child: Text(
                                                  "Donor Requests",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: TabBarView(
                                            children: [
                                              DonorTab(
                                                onItemClick: () {
                                                  setState(() {
                                                    mainProvider
                                                            .donorPageState =
                                                        DonorPageState.request;
                                                    mainProvider
                                                        .setShowAppBar(true);
                                                    mainProvider.setAppBarTitle(
                                                        "Sarah Taylor");
                                                  });
                                                },
                                              ),
                                              DonorTab(
                                                onItemClick: () {
                                                  setState(() {
                                                    mainProvider
                                                            .donorPageState =
                                                        DonorPageState.request;
                                                    mainProvider
                                                        .setShowAppBar(true);
                                                    mainProvider.setAppBarTitle(
                                                        "Sarah Taylor");
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -50,
                                  left: MediaQuery.of(context).size.width / 2 -
                                      45,
                                  child: userData?["photoUrl"] != null
                                      ? ClipOval(
                                          child: Image.network(
                                            userData?["photoUrl"] ?? '',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: Center(
                                                    child: Icon(Icons.error)),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(
                                            24.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              50.0,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 50.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : mainProvider.donorPageState == DonorPageState.request
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Sarah Taylor",
                                  style: TextStyle(
                                    fontSize: 48.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "Rumah Sakit Hermina, Cibuyut",
                                  style: TextStyle(
                                    fontSize: 24.0,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    "Jan 10, 2025 22:10 WIB",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "A+",
                                  style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "100 points",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 60.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CustomAnimatedButton(
                                        onButtonpressed: () {},
                                        buttonTitle: "Decline",
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                20,
                                        textColor: Colors.black,
                                        borderColor: const Color(0xFFE2E2E1),
                                        buttonColor: Colors.white,
                                      ),
                                      CustomAnimatedButton(
                                        onButtonpressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Center(
                                                  child: Text(
                                                    "Request Accepted",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 33.0,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                content: const SizedBox(
                                                  height: 300.0,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "The person requesting has been notified.\nPlease go to the hospital now.\n\nPlease contact this WhatsApp number to confirm that you are on the way to the hospital.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 18.0,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 16.0),
                                                        child: InkWell(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FaIcon(
                                                                FontAwesomeIcons
                                                                    .whatsapp,
                                                                size: 24.0,
                                                                color: Colors
                                                                    .green),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          8.0),
                                                              child: Text(
                                                                "+62 812-3456-7890",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      18.0,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  CustomAnimatedButton(
                                                    onButtonpressed: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        mainProvider
                                                            .setSelectedIndex(
                                                                2);
                                                        mainProvider
                                                            .setCurrentBottomTitle(
                                                                "Find");
                                                        mainProvider
                                                            .setDonorPageState(
                                                                DonorPageState
                                                                    .profile);
                                                        mainProvider
                                                            .setShowAppBar(
                                                                false);
                                                      });
                                                    },
                                                    buttonTitle:
                                                        "Directions to hospital",
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        buttonTitle: "Accept",
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                20,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : const SizedBox();
      },
    );
  }
}

class DonorTab extends StatelessWidget {
  final VoidCallback onItemClick;

  const DonorTab({super.key, required this.onItemClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 50,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              onItemClick();
            },
            child: const Padding(
              padding: EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                bottom: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sarah Taylor",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "A+",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rumah Sakit Hermina, Cibuyut",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "100",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            " points",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Jan 10, 2025 22:10 WIB",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Divider(
                      color: Color(0xFFBFBFBF),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
