import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/mock_user_repository.dart';

enum UserRole {
  customer,
  delivery,
}

class AuthState extends ChangeNotifier {
  bool _isAuthenticated = true; // Default true so user can explore app immediately in tests
  UserRole _userRole = UserRole.customer;
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
  UserRole get userRole => _userRole;
  bool get isDeliveryPartner => _userRole == UserRole.delivery;
  String get phoneNumber => _phoneNumber;
  String get userName => _profile.name;
  UserProfile get profile => _profile;
  String? get pendingPhone => _pendingPhone;
  bool get isSendingOtp => _isSendingOtp;
  bool get isVerifyingOtp => _isVerifyingOtp;

  void loginAsCustomer({String phone = '9876543210'}) {
    _isAuthenticated = true;
    _userRole = UserRole.customer;
    _phoneNumber = phone.startsWith('+91') ? phone : '+91 $phone';
    _profile = _profile.copyWith(name: 'Yaswanth', phone: _phoneNumber);
    notifyListeners();
  }

  void loginAsDelivery({String phone = '9123456789'}) {
    _isAuthenticated = true;
    _userRole = UserRole.delivery;
    _phoneNumber = phone.startsWith('+91') ? phone : '+91 $phone';
    _profile = _profile.copyWith(name: 'K. Rajesh (Hero)', phone: _phoneNumber);
    notifyListeners();
  }

  Future<void> updateProfile({required String name, required String email}) async {
    _profile = _profile.copyWith(name: name, email: email);
    await MockUserRepository.updateUserProfile(_profile);
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _isSendingOtp = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _pendingPhone = phone.startsWith('+91') ? phone : '+91 $phone';
    _isSendingOtp = false;
    notifyListeners();
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    _isVerifyingOtp = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _isVerifyingOtp = false;

    // Accept 4821 or any 4 digit code for smooth interactive testing
    if (otp.length == 4) {
      _isAuthenticated = true;
      if (_pendingPhone != null) {
        _phoneNumber = _pendingPhone!;
        final cleanDigits = _pendingPhone!.replaceAll(RegExp(r'\D'), '');
        if (cleanDigits.contains('91234') || cleanDigits.endsWith('9123456789')) {
          _userRole = UserRole.delivery;
          _profile = _profile.copyWith(name: 'K. Rajesh (Hero)', phone: _pendingPhone!);
        } else {
          _userRole = UserRole.customer;
          _profile = _profile.copyWith(name: 'Yaswanth', phone: _pendingPhone!);
        }
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
    _userRole = UserRole.customer;
    notifyListeners();
  }
}
