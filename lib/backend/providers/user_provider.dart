import 'package:flutter/material.dart'; // Changed to material for ChangeNotifier
import '../../backend/models/users.dart';

class UserProvider extends ChangeNotifier {
  // Make it nullable so it can start as null before a user is loaded
  UsersModel? _userModel;

  // Getter
  UsersModel? get user => _userModel;

  // Setter
  void setUser(UsersModel model) {
    _userModel = model;
    notifyListeners(); // This tells the UI to rebuild when data changes
  }

  // Clear user (useful for logout or resets)
  void clearUser() {
    _userModel = null;
    notifyListeners();
  }
}