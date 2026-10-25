class UserProfile {
  final String name;
  final String phone;
  final String email;
  final String memberTier;
  final int totalOrders;
  final bool isPremiumActive;
  final double premiumAnnualValue;
  final double rewardsBalance;
  final int referralsCompleted;
  final int referralsTarget;
  final double referralMilestoneReward;
  final String defaultAddress;

  const UserProfile({
    required this.name,
    required this.phone,
    this.email = 'yaswanth@tanizkart.com',
    this.memberTier = 'Tanizkart Member',
    this.totalOrders = 12,
    this.isPremiumActive = true,
    this.premiumAnnualValue = 7200.0,
    this.rewardsBalance = 2400.0,
    this.referralsCompleted = 3,
    this.referralsTarget = 4,
    this.referralMilestoneReward = 1200.0,
    this.defaultAddress = 'Flat 302, Green Meadows, Lawyerpet, Ongole',
  });

  double get referralProgress => referralsCompleted / referralsTarget;
}
