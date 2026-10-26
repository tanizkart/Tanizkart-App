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
  String get phoneNumber => phone;

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? memberTier,
    int? totalOrders,
    bool? isPremiumActive,
    double? premiumAnnualValue,
    double? rewardsBalance,
    int? referralsCompleted,
    int? referralsTarget,
    double? referralMilestoneReward,
    String? defaultAddress,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      memberTier: memberTier ?? this.memberTier,
      totalOrders: totalOrders ?? this.totalOrders,
      isPremiumActive: isPremiumActive ?? this.isPremiumActive,
      premiumAnnualValue: premiumAnnualValue ?? this.premiumAnnualValue,
      rewardsBalance: rewardsBalance ?? this.rewardsBalance,
      referralsCompleted: referralsCompleted ?? this.referralsCompleted,
      referralsTarget: referralsTarget ?? this.referralsTarget,
      referralMilestoneReward: referralMilestoneReward ?? this.referralMilestoneReward,
      defaultAddress: defaultAddress ?? this.defaultAddress,
    );
  }
}
