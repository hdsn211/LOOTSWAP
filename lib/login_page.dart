import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // =========================
  // LOOTSWAP COLORS
  // =========================

  // Dark navy background from the LOOTSWAP theme
  static const Color backgroundColor = Color(0xFF141C3A);

  // Main teal
  static const Color primaryTeal = Color(0xFF277F91);

  // Dark teal
  static const Color darkTeal = Color(0xFF1E6474);

  // Yellow/gold accent
  static const Color accentYellow = Color(0xFFDEB944);

  // White text
  static const Color whiteText = Color(0xFFFFFFFF);

  // Light blue/gray secondary text
  static const Color secondaryTextColor = Color(0xFFD9E0F5);

  // Input background
  static const Color inputColor = Color(0xFFF5F5F5);

  // Input text
  static const Color inputTextColor = Color(0xFF333333);

  // =========================
  // CONTROLLERS
  // =========================

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // =========================
  // FIREBASE LOGIN
  // =========================

  Future<void> signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account was found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;

        default:
          message = 'Login failed. Please try again.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================
  // MESSAGE
  // =========================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkTeal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // =========================
  // TEXT FIELD
  // =========================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: inputTextColor,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,

          prefixIcon: Icon(
            icon,
            color: primaryTeal,
          ),

          hintText: hintText,

          hintStyle: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 14,
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 10,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: primaryTeal,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // =========================
                // LOOTSWAP LOGO
                // =========================

                SizedBox(
                  height: 220,
                  width: 220,

                  child: Image.asset(
                    'assets/logo.png',

                    fit: BoxFit.contain,

                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            size: 90,
                            color: primaryTeal,
                          ),

                          const SizedBox(height: 5),

                          Icon(
                            Icons.swap_horiz,
                            size: 45,
                            color: accentYellow,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // APP NAME
                // =========================

                Text(
                  'LOOTSWAP',

                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: whiteText,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                // =========================
                // TAGLINE
                // =========================

                Text(
                  "Don't Need It? Swap It!",

                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 40),

                // =========================
                // EMAIL
                // =========================

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                // =========================
                // PASSWORD
                // =========================

                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 22),

                // =========================
                // LOGIN BUTTON
                // =========================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),

                  child: SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      onPressed: _isLoading ? null : signIn,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,

                        disabledBackgroundColor:
                            const Color(0xFF5B667A),

                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: _isLoading
                          ? const SizedBox(
                              height: 25,
                              width: 25,

                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Log In',

                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // =========================
                // REGISTER
                // =========================

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      'Not a member? ',

                      style: GoogleFonts.poppins(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },

                      child: Text(
                        'Register now',

                        style: GoogleFonts.poppins(
                          color: accentYellow,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
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