import '../models/user_model.dart';

class MockUserRepository {
  static UserProfile getUserProfile() {
    return const UserProfile(
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
  }
}
