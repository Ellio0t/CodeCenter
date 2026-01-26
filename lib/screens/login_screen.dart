import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin(Future<void> Function() loginMethod) async {
    if (_isLoading) return; // Prevent double clicks

    setState(() => _isLoading = true);
    try {
      await loginMethod().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception("Connection timed out. Please check your internet.");
        },
      );
      // Navigation is handled by auth state stream in main.dart
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains("Exception:")) {
         errorMessage = errorMessage.replaceAll("Exception:", "").trim();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onEmailLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _handleLogin(() => _authService.signInWithEmail(email, password));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                    ? [const Color(0xFF121212), const Color(0xFF1E1E1E)] 
                    : [const Color(0xFFF5F5F5), Colors.white],
              ),
            ),
          ),
          // Neon Glows
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10D34E).withOpacity(0.3),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676).withOpacity(0.2),
                ),
              ),
            ),
          ),

          // 2. Glassmorphism Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Close Button (X)
                        Align(
                          alignment: Alignment.topLeft,
                          child: InkWell(
                            onTap: () {
                              if (!_isLoading) {
                                _handleLogin(_authService.signInAnonymously);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54, size: 20),
                            ),
                          ),
                        ),

                        // App Logo
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF10D34E).withOpacity(0.2),
                            border: Border.all(color: const Color(0xFF10D34E), width: 2),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF10D34E).withOpacity(0.4), blurRadius: 16),
                            ]
                          ),
                          child: Image.asset(
                            AppConfig.shared.logoImage,
                            width: 72, 
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                        
                        const SizedBox(height: 16), 
                        Text(
                          "Welcome Back",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith( 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 4), 
                        Text(
                          "Sign in to access exclusive codes and cashback",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith( 
                            color: Colors.grey,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.3, end: 0, delay: 100.ms),

                        const SizedBox(height: 20), 

                        // Email Field
                        _buildTextField(
                          controller: _emailController,
                          hint: "Email",
                          icon: Icons.email_outlined,
                          isDark: isDark,
                        ).animate().fadeIn().slideX(begin: -0.2, end: 0, delay: 200.ms),

                        const SizedBox(height: 12), 

                        // Password Field
                        _buildTextField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          isObscure: true,
                          isDark: isDark,
                        ).animate().fadeIn().slideX(begin: 0.2, end: 0, delay: 300.ms),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {}, // TODO: Implement Forgot Password
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16), 

                        // Login Button
                         SizedBox(
                          width: double.infinity,
                          height: 45, 
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onEmailLoginPressed, // Use validated handler
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10D34E),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: const Color(0xFF10D34E).withOpacity(0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                : const Text("LOG IN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ).animate().fadeIn().scale(delay: 400.ms),

                        const SizedBox(height: 16), 
                        
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "Or continue with",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : Colors.black38
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)),
                          ],
                        ),

                        const SizedBox(height: 16), 

                        // Social Buttons
                        InkWell(
                          onTap: () => _handleLogin(_authService.signInWithGoogle),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10), 
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Classic Google G (Network Image)
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/480px-Google_%22G%22_logo.svg.png',
                                  height: 20, 
                                  width: 20,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(FontAwesomeIcons.google, color: Color(0xFF4285F4), size: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.5, end: 0, delay: 500.ms),

                        const SizedBox(height: 16), 
                        
                        // Subtle Guest Button
                        TextButton(
                           onPressed: () => _handleLogin(_authService.signInAnonymously),
                           style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           ),
                           child: Text(
                             "Continue as Guest",
                             style: TextStyle(
                               color: const Color(0xFF10D34E),
                               fontSize: 15, 
                               fontWeight: FontWeight.bold,
                               decoration: TextDecoration.underline,
                               decorationColor: const Color(0xFF10D34E),
                             ),
                           ),
                        ),

                        const SizedBox(height: 12), 

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
                            GestureDetector(
                              onTap: () => {}, // TODO: Implement Toggle Sign Up
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Color(0xFF10D34E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 3. Bottom Text/Logo "from Elliot" (Hidden when keyboard is open)
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              bottom: 30, // Slightly lower than splash to avoid keyboard interference initially
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'from',
                    style: TextStyle(
                      color: Colors.grey, 
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Image.asset(
                    'images/elliot.png',
                    height: 45, 
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon,
    bool isObscure = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), // Reduced font
          prefixIcon: Icon(icon, color: const Color(0xFF10D34E), size: 20), // Reduced icon
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical padding
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
