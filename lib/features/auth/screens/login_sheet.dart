import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../state/auth_state.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LoginSheet(),
    );
  }

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final TextEditingController _phoneController = TextEditingController(text: '9849248210');
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool _isOtpStage = false;
  int _resendTimer = 30;
  Timer? _timer;
  bool _isSuccess = false;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    final auth = Provider.of<AuthState>(context, listen: false);
    final sent = await auth.sendOtp(phone);
    if (sent && mounted) {
      setState(() {
        _isOtpStage = true;
      });
      _startTimer();
      // Auto-fill demo OTP 4821 for convenient testing
      _otpControllers[0].text = '4';
      _otpControllers[1].text = '8';
      _otpControllers[2].text = '2';
      _otpControllers[3].text = '1';
    }
  }

  void _onVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 4-digit OTP')),
      );
      return;
    }

    final auth = Provider.of<AuthState>(context, listen: false);
    final verified = await auth.verifyOtp(otp);
    if (verified && mounted) {
      setState(() => _isSuccess = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: TanizColors.rapidGreen,
            content: Text('🎉 Login Successful! Welcome to Tanizkart'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_isSuccess)
            _buildSuccessView()
          else if (!_isOtpStage)
            _buildPhoneView()
          else
            _buildOtpView(),
        ],
      ),
    );
  }

  Widget _buildPhoneView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'India\'s Last Minute App',
                  style: TanizTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    color: TanizColors.midnightNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log in or sign up to continue',
                  style: TanizTypography.bodySmall.copyWith(
                    color: TanizColors.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Phone Input Row with 🇮🇳 +91
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: TanizColors.canvasBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TanizColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '+91',
                      style: TanizTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: TanizColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 28, color: Colors.grey.shade300),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TanizTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter Phone Number',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Consumer<AuthState>(
          builder: (context, auth, _) {
            return ElevatedButton(
              onPressed: auth.isSendingOtp ? null : _onSendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: TanizColors.primaryBlue,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: auth.isSendingOtp
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Continue',
                      style: TanizTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(height: 14),

        Center(
          child: Text(
            'By continuing, you agree to our Terms of Service & Privacy Policy',
            style: TanizTypography.bodySmall.copyWith(
              fontSize: 11,
              color: TanizColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => _isOtpStage = false),
            ),
            Text(
              'Verify Phone Number',
              style: TanizTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Enter the 4-digit code sent to +91 ${_phoneController.text}',
            style: TanizTypography.bodySmall.copyWith(
              color: TanizColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 4 OTP Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: TanizColors.canvasBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _otpControllers[index].text.isNotEmpty
                      ? TanizColors.primaryBlue
                      : TanizColors.borderSubtle,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: TanizTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: TanizColors.midnightNavy,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 3) {
                      _otpFocusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        Consumer<AuthState>(
          builder: (context, auth, _) {
            return ElevatedButton(
              onPressed: auth.isVerifyingOtp ? null : _onVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: TanizColors.rapidGreen,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: auth.isVerifyingOtp
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Verify & Continue',
                      style: TanizTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(height: 14),

        Center(
          child: _resendTimer > 0
              ? Text(
                  'Resend SMS in 00:${_resendTimer.toString().padLeft(2, '0')}',
                  style: TanizTypography.bodySmall.copyWith(
                    color: TanizColors.textSecondary,
                  ),
                )
              : TextButton(
                  onPressed: () {
                    _startTimer();
                  },
                  child: Text(
                    'Resend SMS',
                    style: TanizTypography.labelMedium.copyWith(
                      color: TanizColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: TanizColors.rapidGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 16),
            Text(
              'Verified Successfully!',
              style: TanizTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: TanizColors.midnightNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Taking you to fresh savings...',
              style: TanizTypography.bodySmall.copyWith(color: TanizColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
