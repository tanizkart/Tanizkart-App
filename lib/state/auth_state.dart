import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  bool _isAuthenticated = true; // Default true so user can explore app immediately
  String _phoneNumber = '+91 98492 48210';
  final String _userName = 'Yaswanth';
  String? _pendingPhone;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;

  bool get isAuthenticated => _isAuthenticated;
  String get phoneNumber => _phoneNumber;
  String get userName => _userName;
  String? get pendingPhone => _pendingPhone;
  bool get isSendingOtp => _isSendingOtp;
  bool get isVerifyingOtp => _isVerifyingOtp;

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
