import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../state/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final String _originalName;
  late final String _originalEmail;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthState>().profile;
    _originalName = profile.name;
    _originalEmail = profile.email;
    _nameController = TextEditingController(text: _originalName);
    _emailController = TextEditingController(text: _originalEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    // Check if anything actually changed
    if (newName == _originalName && newEmail == _originalEmail) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthState>().updateProfile(
            name: newName,
            email: newEmail,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Profile updated successfully!'),
            ],
          ),
          backgroundColor: TanizColors.rapidGreen,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to update profile. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final profile = authState.profile;
    final initials = profile.name.isNotEmpty
        ? profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: TanizColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TanizTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar header with badge
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: TanizColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TanizColors.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TanizTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TanizColors.primaryGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        size: 14,
                        color: TanizColors.navyDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: TanizColors.amberBadgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TanizColors.primaryGold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: TanizColors.goldenAmberDark),
                    const SizedBox(width: 4),
                    Text(
                      'Tanizkart Member',
                      style: TanizTypography.labelSmall.copyWith(
                        color: TanizColors.goldenAmberDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Error banner if any
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TanizColors.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TanizColors.errorRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: TanizColors.errorRed, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TanizTypography.bodySmall.copyWith(
                            color: TanizColors.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Full Name field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Full Name',
                  style: TanizTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: TanizColors.primaryBlue),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.primaryBlue, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (val.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Email Address field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email Address',
                  style: TanizTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: TanizColors.primaryBlue),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.primaryBlue, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(val.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Phone Number field (Read-only as per specification)
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'Phone Number',
                      style: TanizTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: TanizColors.greenContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 10, color: TanizColors.rapidGreenDark),
                          const SizedBox(width: 2),
                          Text(
                            'Verified',
                            style: TanizTypography.labelSmall.copyWith(
                              fontSize: 9.5,
                              color: TanizColors.rapidGreenDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TanizColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_rounded, color: TanizColors.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      profile.phoneNumber.isNotEmpty ? profile.phoneNumber : '+91 98480 22338',
                      style: TanizTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TanizColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.lock_rounded, color: TanizColors.textMuted, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your phone number is linked to your OTP login and cannot be edited directly.',
                  style: TanizTypography.caption.copyWith(
                    color: TanizColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Save Changes Button
              TanizTappable(
                onTap: _isLoading ? () {} : _handleSave,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: TanizColors.blueGoldGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: TanizColors.primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TanizTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel button
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TanizTypography.labelLarge.copyWith(
                    color: TanizColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
