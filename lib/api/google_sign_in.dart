import 'dart:io';

import 'package:circulahealth/providers/main_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';

Future<dynamic> signInWithGoogle(MainProvider mainProvider) async {
  try {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final userCred =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCred.user;
    if (user == null) return;
    // Save custom data in Firestore
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'fullName': user.displayName,
        'createdAt': Timestamp.now(),
        'provider': 'google',
        'photoUrl': '',
        'username': '',
        'homeLocation': '',
        'whatsAppNumber': '',
        'legalDocumentUrl': '',
        'gpsAllowed': false,
        'hasRegistered': false,
        'bloodType': '',
        'age': 0,
      });
    }
    mainProvider.setUserCredential(userCred);
    return userCred;
  } on Exception catch (e) {
    // TODO
    print('exception->$e');
  }
}

Future<String> signUpWithEmailPassword(
    String email, String password, MainProvider mainProvider) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;
    if (user != null) {
      // Save custom data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'fullName': user.displayName,
        'createdAt': Timestamp.now(),
        'provider': 'email',
        'photoUrl': '',
        'username': '',
        'homeLocation': '',
        'whatsAppNumber': '',
        'legalDocumentUrl': '',
        'gpsAllowed': false,
        'hasRegistered': false,
        'bloodType': '',
        'age': 0,
      });
    }
    mainProvider.setUserCredential(userCredential);
    return "success";
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      return 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      return 'The account already exists for that email.';
    } else {
      return e.message ?? "";
    }
  } catch (e) {
    return "";
  }
}

Future<String> signInWithEmailPassword(
    String email, String password, MainProvider mainProvider) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    mainProvider.setUserCredential(userCredential);
    return "success";
    // You can navigate to a new screen or show a success message here.
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return "No user found for that email.";
    } else if (e.code == 'wrong-password') {
      return "Wrong password provided.";
    } else if (e.code == 'invalid-credential') {
      return "Invalid credential";
    } else {
      return e.message ?? "";
    }
  } catch (e) {
    return e.toString();
  }
}

Future<void> updateUserProfileData(Map<String, dynamic> updatedData) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('User not logged in');
    return;
  }

  final uid = user.uid;

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(updatedData);

    print('User profile updated successfully');
  } catch (e) {
    print('Error updating profile: $e');
  }
}

Future<String> uploadProfilePicture(File file, String uid) async {
  final fileName = basename(file.path);
  final ref =
      FirebaseStorage.instance.ref().child('profile_pictures/$uid/$fileName');

  await ref.putFile(file);
  return await ref.getDownloadURL();
}
