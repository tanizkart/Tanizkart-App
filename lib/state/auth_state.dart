import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/mock_user_repository.dart';

class AuthState extends ChangeNotifier {
  bool _isAuthenticated = true; // Default true so user can explore app immediately
  String _phoneNumber = '+91 98480 22338';
  String? _pendingPhone;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  late UserProfile _profile;

  AuthState() {
    _profile = MockUserRepository.getUserProfile();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final loaded = await MockUserRepository.loadUserProfile();
    _profile = loaded;
    _phoneNumber = loaded.phone;
    notifyListeners();
  }

  bool get isAuthenticated => _isAuthenticated;
  String get phoneNumber => _phoneNumber;
  String get userName => _profile.name;
  UserProfile get profile => _profile;
  String? get pendingPhone => _pendingPhone;
  bool get isSendingOtp => _isSendingOtp;
  bool get isVerifyingOtp => _isVerifyingOtp;

  Future<void> updateProfile({required String name, required String email}) async {
    _profile = _profile.copyWith(name: name, email: email);
    await MockUserRepository.updateUserProfile(_profile);
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _isSendingOtp = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _pendingPhone = phone.startsWith('+91') ? phone : '+91 $phone';
    _isSendingOtp = false;
    notifyListeners();
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    _isVerifyingOtp = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));
    _isVerifyingOtp = false;

    // Accept 4821 or any 4 digit code for smooth interactive testing
    if (otp.length == 4) {
      _isAuthenticated = true;
      if (_pendingPhone != null) {
        _phoneNumber = _pendingPhone!;
        _profile = _profile.copyWith(phone: _pendingPhone!);
        await MockUserRepository.updateUserProfile(_profile);
      }
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
