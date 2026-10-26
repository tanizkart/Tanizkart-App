import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class MockUserRepository {
  static const String _prefName = 'user_profile_name';
  static const String _prefEmail = 'user_profile_email';
  static const String _prefPhone = 'user_profile_phone';

  static UserProfile _current = const UserProfile(
    name: 'Yaswanth',
    phone: '+91 98480 22338',
    email: 'yaswanth@tanizkart.com',
    memberTier: 'Tanizkart Member',
    totalOrders: 12,
    isPremiumActive: true,
    premiumAnnualValue: 7200.0,
    rewardsBalance: 2400.0,
    referralsCompleted: 3,
    referralsTarget: 4,
    referralMilestoneReward: 1200.0,
    defaultAddress: 'Flat 302, Green Meadows, Lawyerpet, Ongole',
  );

  static UserProfile getUserProfile() {
    return _current;
  }

  static Future<UserProfile> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_prefName);
      final email = prefs.getString(_prefEmail);
      final phone = prefs.getString(_prefPhone);
      if (name != null || email != null || phone != null) {
        _current = _current.copyWith(
          name: name ?? _current.name,
          email: email ?? _current.email,
          phone: phone ?? _current.phone,
        );
      }
    } catch (_) {
      // In-memory fallback
    }
    return _current;
  }

  static Future<void> updateUserProfile(UserProfile updated) async {
    _current = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefName, updated.name);
      await prefs.setString(_prefEmail, updated.email);
      await prefs.setString(_prefPhone, updated.phone);
    } catch (_) {
      // In-memory fallback
    }
  }
}
