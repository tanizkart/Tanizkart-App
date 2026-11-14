import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/motion.dart';
import '../../../state/auth_state.dart';
import '../../../state/cart_state.dart';
import '../../main_navigation_shell.dart';
import '../../delivery/screens/delivery_orders_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController(text: ''));
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool _isOtpStage = false;
  bool _isLoading = false;

  static const String customerDummyNumber = '9876543210';
  static const String deliveryDummyNumber = '9123456789';

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _loginAsUserDirectly() {
    final auth = Provider.of<AuthState>(context, listen: false);
    auth.loginAsCustomer(phone: customerDummyNumber);
    Provider.of<CartState>(context, listen: false).setCustomerId(auth.profile.id);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
    );
  }

  void _loginAsDeliveryDirectly() {
    final auth = Provider.of<AuthState>(context, listen: false);
    auth.loginAsDelivery(phone: deliveryDummyNumber);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DeliveryOrdersScreen()),
    );
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: TanizColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthState>(context, listen: false);
    await auth.sendOtp(phone);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isOtpStage = true;
        // Pre-fill demo OTP 4821 for fast frictionless testing
        _otpControllers[0].text = '4';
        _otpControllers[1].text = '8';
        _otpControllers[2].text = '2';
        _otpControllers[3].text = '1';
      });
    }
  }

  void _verifyAndProceed() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 4-digit OTP'),
          backgroundColor: TanizColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthState>(context, listen: false);
    final verified = await auth.verifyOtp(otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (verified) {
      final cleanDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      if (cleanDigits.contains('91234') || cleanDigits.endsWith(deliveryDummyNumber)) {
        // Delivery partner route
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DeliveryOrdersScreen()),
        );
      } else {
        // Customer / Shopper route
        Provider.of<CartState>(context, listen: false).setCustomerId(auth.profile.id);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Use 4821 for testing.'),
          backgroundColor: TanizColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1E), // Deep Obsidian Slate
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // -------------------------------------------------------------
                // 1. PROFESSIONAL BRAND MARK & TYPOGRAPHY LOGO (NO LEAF EMOJI)
                // -------------------------------------------------------------
                Center(
                  child: Column(
                    children: [
                      // Official Tanizkart Brand Logo from assets/logo.png
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: TanizColors.primaryEmerald.withValues(alpha: 0.35),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.shopping_bag_rounded,
                              size: 40,
                              color: TanizColors.primaryEmerald,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Professional Text Logo
                      Text.rich(
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: 'TANIZ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                              ),
                            ),
                            TextSpan(
                              text: 'KART',
                              style: TextStyle(
                                color: TanizColors.primaryEmerald,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Production Subtitle Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on_rounded, size: 12, color: TanizColors.accentGold),
                            SizedBox(width: 4),
                            Text(
                              '10-MINUTE HYPERLOCAL QUICK COMMERCE',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // -------------------------------------------------------------
                // 2. PREMIUM HIGH-TRUST LOGIN CONTAINER CARD
                // -------------------------------------------------------------
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TanizColors.primaryEmerald.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: TanizColors.primaryEmerald,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isOtpStage ? 'Verify Mobile Number' : 'Sign In / Register',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isOtpStage
                                      ? 'Enter the 4-digit code sent to +91 ${_phoneController.text}'
                                      : 'Enter your 10-digit mobile number to continue',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Phone Number Input Stage
                      if (!_isOtpStage) ...[
                        const Text(
                          'Mobile Number',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: const Row(
                                  children: [
                                    Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 6),
                                    Text(
                                      '+91',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: const Color(0xFFCBD5E1),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    fontSize: 15.5,
                                    letterSpacing: 0.5,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '98765 43210',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.5,
                                    ),
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                ),
                              ),
                              if (_phoneController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                                  onPressed: () {
                                    setState(() => _phoneController.clear());
                                  },
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TanizColors.primaryEmerald,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 1,
                              shadowColor: TanizColors.primaryEmerald.withValues(alpha: 0.4),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Continue with OTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        // OTP Inputs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(4, (index) {
                            return SizedBox(
                              width: 58,
                              height: 58,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _otpFocusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: TanizColors.primaryEmerald, width: 2),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val.isNotEmpty && index < 3) {
                                    _otpFocusNodes[index + 1].requestFocus();
                                  } else if (val.isEmpty && index > 0) {
                                    _otpFocusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Demo Sandbox OTP Pre-filled: 4821',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyAndProceed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TanizColors.primaryEmerald,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 1,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Verify & Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() => _isOtpStage = false);
                            },
                            child: const Text(
                              'Change Mobile Number',
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // 3. FAST-ACCESS DEMO SANDBOX ACCOUNTS SECTION
                // -------------------------------------------------------------
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: TanizColors.accentGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: TanizColors.accentGold,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'QUICK TEST DEMO ACCOUNTS',
                                style: TextStyle(
                                  color: TanizColors.accentGold,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '1-Tap Login',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Select an account below to auto-fill or log in instantly:',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // DEMO 1: USER / CUSTOMER
                      TanizTappable(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _phoneController.text = customerDummyNumber;
                            _isOtpStage = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131D38),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _phoneController.text == customerDummyNumber
                                  ? TanizColors.primaryEmerald
                                  : const Color(0xFF1E293B),
                              width: _phoneController.text == customerDummyNumber ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: TanizColors.primaryEmerald.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: TanizColors.primaryEmerald.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.shopping_bag_outlined, color: TanizColors.primaryEmerald, size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          '1. Customer / Shopper',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: TanizColors.primaryEmerald.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'CUSTOMER APP',
                                            style: TextStyle(
                                              color: Color(0xFF34D399),
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Number: $customerDummyNumber',
                                      style: TextStyle(
                                        color: Color(0xFFCBD5E1),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      'Browse groceries, cart & checkout',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _loginAsUserDirectly,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: TanizColors.primaryEmerald,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // DEMO 2: DELIVERY HERO / PARTNER
                      TanizTappable(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _phoneController.text = deliveryDummyNumber;
                            _isOtpStage = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131D38),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _phoneController.text == deliveryDummyNumber
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF1E293B),
                              width: _phoneController.text == deliveryDummyNumber ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.two_wheeler_rounded, color: Color(0xFF38BDF8), size: 21),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          '2. Delivery Partner',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'RIDER FLEET',
                                            style: TextStyle(
                                              color: Color(0xFF38BDF8),
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Number: $deliveryDummyNumber',
                                      style: TextStyle(
                                        color: Color(0xFFCBD5E1),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      'Manage orders, pickup & OTP handovers',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _loginAsDeliveryDirectly,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
