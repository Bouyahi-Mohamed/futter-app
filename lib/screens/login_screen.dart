import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../viewmodels/auth_view_model.dart';
import '../widgets/nature_decorations.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _labibController;

  @override
  void initState() {
    super.initState();
    _labibController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _labibController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF66BB6A), // Labib green
              Color(0xFF42A5F5), // Sky blue
              Color(0xFFFFD54F), // Sun yellow
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating leaves background
            const Positioned.fill(
              child: FloatingLeaves(leafCount: 20, speed: 0.3),
            ),
            
            // Floating Labib in background
            AnimatedBuilder(
              animation: _labibController,
              builder: (context, child) {
                return Positioned(
                  top: 50 + math.sin(_labibController.value * math.pi) * 20,
                  right: 20,
                  child: Opacity(
                    opacity: 0.3,
                    child: Transform.rotate(
                      angle: math.sin(_labibController.value * math.pi) * 0.1,
                      child: Image.asset(
                        'assets/images/labib/labib_hero.png',
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image not found
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.eco, size: 60, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Labib waving with animation
                        AnimatedBuilder(
                          animation: _labibController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, math.sin(_labibController.value * math.pi) * 10),
                              child: Transform.rotate(
                                angle: math.sin(_labibController.value * math.pi) * 0.05,
                                child: Hero(
                                  tag: 'labib_hero',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/labib/labib_hero.png',
                                      width: 150,
                                      height: 150,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback if image not found
                                        return Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF66BB6A),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.eco,
                                            size: 80,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Greeting from Labib
                        Text(
                          'مرحباً! أنا لبيب',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),

                        // App title
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.eco, color: Color(0xFF66BB6A), size: 32),
                              const SizedBox(width: 12),
                              Text(
                                'حماية البيئة مع لبيب',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: const Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email Field with nature icon
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Text('🌱', style: TextStyle(fontSize: 24)),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field with lock icon
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Text('🔒', style: TextStyle(fontSize: 24)),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: const Text('نسيت كلمة المرور؟'),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button with leaf decoration
                        if (authViewModel.isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await authViewModel.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                if (success && mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  );
                                } else if (mounted && authViewModel.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(authViewModel.errorMessage!)),
                                  );
                                }
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('دخول مع لبيب'),
                                SizedBox(width: 8),
                                Text('🍃', style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Encouraging message from Labib
                        const Center(
                          child: LabibSpeechBubble(
                            message: 'هيا نحمي البيئة معاً! 🌍',
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Signup section
                        Text(
                          'ليس لديك حساب؟',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // Signup Button - same style as login
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignupScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF66BB6A),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('انضم إلى فريق لبيب'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
