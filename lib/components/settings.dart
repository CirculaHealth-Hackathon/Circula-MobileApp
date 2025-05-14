import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:circulahealth/api/google_sign_in.dart';
import 'package:circulahealth/components/animated_button.dart';
import 'package:circulahealth/components/show_alert.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final ImagePicker _picker = ImagePicker();
  late MainProvider _mainProvider;
  File? _profileImageFile;
  File? _legalDocumentFile;
  bool _isLoading = false;
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _fullNameController = new TextEditingController();
  TextEditingController _ageController = new TextEditingController();
  bool allowGPS = false;
  TextEditingController _homeLocationController = new TextEditingController();
  TextEditingController _whatsAppNumberController = new TextEditingController();
  String profilePictureUrl = "";
  String legalDocumentUrl = "";
  var userData;
  String? pickedBloodType = null;

  List<String> items = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery); // or .camera

      if (pickedFile != null) {
        String theUrl = "";
        theUrl = await uploadProfilePicture(File(pickedFile.path),
            _mainProvider.userCredential.user?.uid ?? "");
        setState(() {
          _profileImageFile = File(pickedFile.path);
          profilePictureUrl = theUrl;
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

  Future<void> _pickLegalDocumentImage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery); // or .camera

      if (pickedFile != null) {
        String theUrl = "";
        theUrl = await uploadProfilePicture(File(pickedFile.path),
            _mainProvider.userCredential.user?.uid ?? "");
        setState(() {
          _legalDocumentFile = File(pickedFile.path);
          legalDocumentUrl = theUrl;
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
        if (user == null) return;

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final theData = doc.data();
          userData = theData;
          setState(() {
            _fullNameController.text = userData?["fullName"] ?? "";
            _ageController.text = userData?["age"]?.toString() ?? "";
            if (userData["bloodType"] != "") {
              pickedBloodType = userData["bloodType"];
            }
            _homeLocationController.text = userData?["homeLocation"] ?? "";
            profilePictureUrl = userData?["photoUrl"] ?? "";
            _usernameController.text = userData?["username"] ?? "";
            _whatsAppNumberController.text = userData?["whatsAppNumber"] ?? "";
            allowGPS = userData?['gpsAllowed'] ?? false;
            legalDocumentUrl = userData?['legalDocumentUrl'] ?? "";
          });
        }
        setState(() {
          _mainProvider.setIsLoading(false);
        });
      } catch (e) {
        print(e);
        setState(() {
          _mainProvider.setIsLoading(false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, mainProvider, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 130.0,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        profilePictureUrl != ""
                            ? _isLoading
                                ? Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        top: 20.0,
                                      ),
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(500000),
                                      ),
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (_isLoading) return;
                                      _pickImage();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Center(
                                        child: ClipOval(
                                          child: Image.network(
                                            profilePictureUrl,
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                width: 150,
                                                height: 150,
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
                                                width: 150,
                                                height: 150,
                                                child: Center(
                                                    child: Icon(Icons.error)),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                            : Center(
                                child: InkWell(
                                  onTap: () {
                                    if (_isLoading) return;
                                    _pickImage();
                                  },
                                  child: Container(
                                    // padding: const EdgeInsets.symmetric(vertical: 50),
                                    margin: const EdgeInsets.only(
                                      top: 20.0,
                                    ),
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFDFDFDF),
                                        width: 2.0,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(500000),
                                    ),
                                    child: _isLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                                strokeWidth: 4.0,
                                              ),
                                            ),
                                          )
                                        : _profileImageFile != null
                                            ? CircleAvatar(
                                                radius: 75,
                                                backgroundImage: FileImage(
                                                  _profileImageFile!,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.upload,
                                                color: Colors.black,
                                                size: 80.0,
                                              ),
                                  ),
                                ),
                              ),
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 10.0,
                            top: 10.0,
                          ),
                          child: Text(
                            "Username",
                            style: TextStyle(
                              color: Color(0xFF696969),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Username',
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
                            top: 10.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        "Full Name",
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
                                        hintText: 'Full Name',
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
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        "Age",
                                        style: TextStyle(
                                          color: Color(0xFF696969),
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    TextField(
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly, // Only allows 0-9
                                      ],
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                bottom: 10.0,
                                top: 10.0,
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
                              width: MediaQuery.of(context).size.width,
                              child: DropdownButtonFormField<String>(
                                hint: const Text("Select blood type"),
                                value: pickedBloodType,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFDFDFDF),
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
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
                                items: items.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                bottom: 10.0,
                                top: 10.0,
                              ),
                              child: Text(
                                "Home Location",
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
                                bottom: 10.0,
                                top: 10.0,
                              ),
                              child: Text(
                                "WhatsApp Number",
                                style: TextStyle(
                                  color: Color(0xFF696969),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextField(
                              controller: _whatsAppNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Only allows 0-9
                              ],
                              decoration: InputDecoration(
                                hintText: 'WhatsApp Number',
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
                                bottom: 10.0,
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (_isLoading) return;
                                      _pickLegalDocumentImage();
                                    },
                                    child: Container(
                                      // padding: const EdgeInsets.symmetric(vertical: 50),
                                      margin: const EdgeInsets.only(
                                        top: 20.0,
                                      ),
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFDFDFDF),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(500000),
                                      ),
                                      child: _isLoading
                                          ? const Center(
                                              child: SizedBox(
                                                width: 80,
                                                height: 80,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.blue),
                                                  strokeWidth: 4.0,
                                                ),
                                              ),
                                            )
                                          : legalDocumentUrl != ""
                                              ? InkWell(
                                                  onTap: () {
                                                    if (_isLoading) return;
                                                    _pickLegalDocumentImage();
                                                  },
                                                  child: Center(
                                                    child: ClipOval(
                                                      child: Image.network(
                                                        legalDocumentUrl,
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return Container(
                                                            width: 150,
                                                            height: 150,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border:
                                                                  Border.all(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            child: const Center(
                                                                child:
                                                                    CircularProgressIndicator()),
                                                          );
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return const SizedBox(
                                                            width: 150,
                                                            height: 150,
                                                            child: Center(
                                                                child: Icon(Icons
                                                                    .error)),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.upload,
                                                  color: Colors.black,
                                                  size: 80.0,
                                                ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const Expanded(
                                    child: Text(
                                      "Upload legal document as donor proof",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Allow GPS access for this app"),
                                    Text(
                                      "Must be turned on",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 15.0,
                                ),
                                Switch(
                                  value: allowGPS,
                                  onChanged: (value) {
                                    setState(() {
                                      allowGPS = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 115,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.1), // Strong dark shadow
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, -1), // Shadow only at the top
                      ),
                    ],
                  ),
                  child: CustomAnimatedButton(
                    onButtonpressed: () async {
                      if (_isLoading) return;
                      if (_usernameController.text == "" ||
                          _fullNameController.text == "" ||
                          _ageController.text == "" ||
                          pickedBloodType == null ||
                          _homeLocationController.text == "" ||
                          _whatsAppNumberController.text == "" ||
                          legalDocumentUrl == "") {
                        return AwesomeDialog(
                          context: context,
                          dialogType: DialogType.infoReverse,
                          animType: AnimType.scale,
                          title: 'Alert!',
                          desc: 'Please fill all the required fields!',
                          btnOkOnPress: () {},
                          btnOkColor: Colors.green,
                          headerAnimationLoop: false,
                        ).show();
                      }
                      try {
                        mainProvider.setIsLoading(true);
                        await updateUserProfileData({
                          "fullName": _fullNameController.text,
                          "bloodType": pickedBloodType,
                          "age": int.tryParse(_ageController.text) ?? 0,
                          "homeLocation": _homeLocationController.text,
                          "photoUrl": profilePictureUrl,
                          "hasRegistered": true,
                          "legalDocumentUrl": legalDocumentUrl,
                          "username": _usernameController.text,
                          "whatsAppNumber": _whatsAppNumberController.text,
                          "gpsAllowed": allowGPS
                        });
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.scale,
                          title: 'Success!',
                          desc: 'Successfully updated your profile data!',
                          btnOkOnPress: () {},
                          btnOkColor: Colors.green,
                          headerAnimationLoop: false,
                        ).show();
                        mainProvider.setIsLoading(false);
                      } catch (e) {
                        mainProvider.setIsLoading(false);
                      }
                    },
                    buttonTitle: "Save Profile",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
