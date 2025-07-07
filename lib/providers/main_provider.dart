import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum DonorPageState { donor, register, profile, request }

class MainProvider with ChangeNotifier {
  int selectedIndex = 2;
  String currentBottomTitle = "Find";
  bool showAppBar = false;
  String appBarTitle = "";
  DonorPageState? donorPageState = DonorPageState.donor;
  bool isLoading = false;
  var userCredential;

  void setSelectedIndex(int newIndex) {
    selectedIndex = newIndex;
    notifyListeners();
  }

  void setCurrentBottomTitle(String newTitle) {
    currentBottomTitle = newTitle;
    notifyListeners();
  }

  void setShowAppBar(bool newValue) {
    showAppBar = newValue;
    notifyListeners();
  }

  void setAppBarTitle(String newValue) {
    appBarTitle = newValue;
    notifyListeners();
  }

  void setDonorPageState(DonorPageState newValue) {
    donorPageState = newValue;
    notifyListeners();
  }

  void setIsLoading(bool newValue) {
    isLoading = newValue;
    notifyListeners();
  }

  void setUserCredential(currentUserCredential) {
    userCredential = currentUserCredential;
    notifyListeners();
  }
}
