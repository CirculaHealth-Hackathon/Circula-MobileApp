import 'package:circulahealth/api/dio.dart';
import 'package:circulahealth/models/chat_messages.dart';
import 'package:circulahealth/models/posts.dart';
import 'package:circulahealth/models/user.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:dio/dio.dart";

Future<dynamic> signInWithGoogle(MainProvider mainProvider) async {
  try {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    GoogleSignInAccount? _user;
    await GoogleSignIn().signOut();

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final Dio _dio = setupDio();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final body = {
      'email': googleUser?.email,
    };
    if (googleUser != null) {
      await _dio.post(
        "https://circula-nestjs-production.up.railway.app/users/google-register",
        data: body,
      );

      mainProvider.setUserCredential(googleUser.email);
    }

    return googleUser;
  } on Exception catch (e) {
    // TODO
    print('exception->$e');
  }
}

Future<String> signUpWithEmailPassword(
    String email, String password, MainProvider mainProvider) async {
  final Dio _dio = setupDio();
  try {
    final body = {
      'email': email,
      'password': password,
      'provider': 'email',
    };
    await _dio.post(
      "https://circula-nestjs-production.up.railway.app/users/register",
      data: body,
    );
    return "success";
  } catch (e) {
    return "Email is already registered!";
  }
}

Future<String> signInWithEmailPassword(
    String email, String password, MainProvider mainProvider) async {
  final Dio _dio = setupDio();
  try {
    final body = {
      'email': email,
      'password': password,
    };
    var response = await _dio.post(
      "https://circula-nestjs-production.up.railway.app/users/login",
      data: body,
    );
    if (response.data["message"] == "Invalid credentials") {
      return "Invalid credentials!";
    }
    mainProvider.setUserCredential(email);
    return "success";
  } catch (e) {
    return "Invalid credentials!";
  }
}

Future<UserDetails?> getUserDetails(String email) async {
  final Dio _dio = setupDio();
  try {
    var response = await _dio.get(
      "https://circula-nestjs-production.up.railway.app/users/user?email=$email",
    );
    var result = UserDetails.fromJson(response.data);
    return result;
  } catch (e) {
    return null;
  }
}

Future<void> addMessage(
    String senderEmail, String receiverEmail, String message) async {
  final Dio _dio = setupDio();
  try {
    final body = {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'message': message
    };
    await _dio.post(
      "https://circula-nestjs-production.up.railway.app/chat/add-message",
      data: body,
    );
  } catch (e) {
    return null;
  }
}

Future<void> addReport(String senderEmail, String message, String type) async {
  final Dio _dio = setupDio();
  try {
    final body = {'senderEmail': senderEmail, 'type': type, 'message': message};
    await _dio.post(
      "https://circula-nestjs-production.up.railway.app/report/add-report",
      data: body,
    );
  } catch (e) {
    return null;
  }
}

Future<List<dynamic>> getChatMessages(String email) async {
  final Dio _dio = setupDio();
  try {
    var response = await _dio.get(
      "https://circula-nestjs-production.up.railway.app/chat/messages?email=$email",
    );
    List<dynamic> chatMessages = response.data
        .map((json) => ChatMessagesResponse.fromJson(json))
        .toList();
    return chatMessages;
  } catch (e) {
    return [];
  }
}

Future<List<dynamic>> getPosts() async {
  final Dio _dio = setupDio();
  try {
    var response = await _dio.get(
      "https://circula-nestjs-production.up.railway.app/users/get-posts",
    );
    List<dynamic> posts =
        response.data.map((json) => PostsResponse.fromJson(json)).toList();
    return posts;
  } catch (e) {
    return [];
  }
}

Future<String?> updateUserProfileData(Map<String, dynamic> updatedData) async {
  final Dio _dio = setupDio();
  try {
    var response = await _dio.post(
      "https://circula-nestjs-production.up.railway.app/users/update-details",
      data: updatedData,
    );
    return "success";
  } catch (e) {
    return null;
  }
}

// Future<String> uploadProfilePicture(File file, String uid) async {
//   final fileName = basename(file.path);
//   final ref =
//       FirebaseStorage.instance.ref().child('profile_pictures/$uid/$fileName');

//   await ref.putFile(file);
//   return await ref.getDownloadURL();
// }
