import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/presentation/auth/signin/signin_state.dart';
import '../../../core/utils/dialogs/show_loading.dart';
import '../../../core/utils/pattern_painter.dart';
import '../../../core/utils/routes.dart';
import '../../../providers/providers.dart';

class SigninScreen extends ConsumerWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signinViewModelProvider);
    final viewModel = ref.read(signinViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<SigninState>(signinViewModelProvider, (prev, next) {
      if (next.isLoading && !(prev?.isLoading ?? false)) {
        AppLoadingDialog.show(
          context,
          message: "Loading your mobile experience...",
        );
      } else if (!next.isLoading && (prev?.isLoading ?? false)) {
        AppLoadingDialog.hide(context);
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (next.isSuccess && !(prev?.isSuccess ?? false)) {
        Future.microtask(() {
          context.go(Routes.home);
        });
      }
    });

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Background pattern at top with logo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black : const Color(0xFF2D2D2D),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: PatternPainter(isDark: true),
                    size: Size.infinite,
                  ),
                  // Logo centered
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(40, 40),
                          painter: LogoPainter(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main white card with custom curve
          Positioned(
            top: 260,
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Login title
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: viewModel.updateEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white : Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Password input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: viewModel.updatePassword,
                          obscureText: !state.isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white : Colors.black,
                                width: 1.5,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: viewModel.togglePasswordVisibility,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => viewModel.signInWithEmail(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: state.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: isDark ? Colors.black : Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider with "or"
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Sign In text
                    Center(
                      child: Text(
                        'Sign in with',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Button
                        InkWell(
                          onTap: state.isLoading
                              ? null
                              : () => viewModel.signInWithGoogle(),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/google.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Apple Button
                        InkWell(
                          onTap: state.isLoading
                              ? null
                              : () {
                                  // Call Apple sign in if implemented
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Apple sign in coming soon',
                                      ),
                                    ),
                                  );
                                },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.apple,
                                size: 28,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // "Don't have any account?" section
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have any account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(Routes.signUp),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
