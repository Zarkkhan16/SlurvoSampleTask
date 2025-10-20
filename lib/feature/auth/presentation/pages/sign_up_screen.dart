import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/core/constants/app_colors.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      context.read<AuthBloc>().add(SignUpRequested(
        email: email,
        password: password,
        name: name,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSignUpSuccess) {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account created successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              // Navigate to landing dashboard
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/landingDashboard',
                      (route) => false,
                );
              });

            } else if (state is AuthSignUpFailure) {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Image.asset(
                              AppImages.splashLogo,
                              height: 40,
                              width: 195,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Create Account",
                              style: AppTextStyle.roboto(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Name Field
                            CustomTextField(
                              hintText: "Enter your name",
                              label: "Full Name",
                              icon: Icons.person,
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                if (value.length < 3) {
                                  return 'Name must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Email Field
                            CustomTextField(
                              hintText: "Example@gmail.com",
                              label: "Email",
                              svgIcon: AppImages.emailIcon,
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Password Field
                            CustomTextField(
                              hintText: "Password",
                              label: "Password",
                              icon: Icons.lock,
                              obscureText: true,
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Confirm Password Field
                            CustomTextField(
                              hintText: "Confirm Password",
                              label: "Confirm Password",
                              icon: Icons.lock_outline,
                              obscureText: true,
                              controller: _confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // Sign Up Button
                            CustomButton(
                              text: "Sign up",
                              onPressed: isLoading ? () {} : _handleSignUp,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 20),

                            // Divider with "Or connect with"
                            Row(
                              children: const [
                                Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "Or connect with",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Social Login Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(AppImages.googleIcon),
                                const SizedBox(width: 20),
                                _buildSocialButton(AppImages.appleIcon),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom Sign In Text - Fixed at bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.white54),
                          children: [
                            TextSpan(
                              text: "Sign in",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialButton(String asset) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(asset),
      ),
    );
  }
}

// CustomTextField widget (same as SignIn)
class CustomTextField extends StatelessWidget {
  final String hintText;
  final String label;
  final IconData? icon;
  final String? svgIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final double? width;
  final double? height;
  final Color fillColor;
  final double borderRadius;
  final Color borderColor;
  final Color focusedBorderColor;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.label,
    this.icon,
    this.svgIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.width,
    this.height,
    this.fillColor = Colors.white10,
    this.borderRadius = 25,
    this.borderColor = Colors.white24,
    this.focusedBorderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 2),
            child: Text(
              label,
              style: AppTextStyle.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: height ?? 50,
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              validator: validator,
              onSaved: onSaved,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyle.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyle.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff8E8E8E),
                ),
                suffixIcon: _buildIcon(),
                filled: true,
                fillColor: fillColor,
                errorStyle: const TextStyle(height: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: focusedBorderColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildIcon() {
    if (svgIcon != null) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          svgIcon!,
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
        ),
      );
    } else if (icon != null) {
      return Icon(icon, color: Colors.white70, size: 20);
    } else {
      return null;
    }
  }
}

// CustomButton widget (same as SignIn)
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          text,
          style: AppTextStyle.roboto(
            fontWeight: FontWeight.w700,
            color: AppColors.buttonText,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}