import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_event.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_state.dart';

import '../../../bottom_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      context.read<AuthBloc>().add(LoginRequested(email, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              BottomNavController.currentIndex.value = 0;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/MainScreen',
                (route) => false,
              );
            } else if (state is AuthLoginSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login successful!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
              BottomNavController.currentIndex.value = 0;
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/MainScreen',
                  (route) => false,
                );
              });
            } else if (state is AuthLoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is Unauthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/SignInScreen',
                (route) => false,
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
                              "Welcome",
                              style: AppTextStyle.roboto(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 30),
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
                            CustomTextField(
                              hintText: "Password",
                              label: "Password",
                              icon: Icons.password,
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Navigate to forgot password screen
                                },
                                child: Text(
                                  "Forget password?",
                                  style: AppTextStyle.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            CustomButton(
                              text: "Sign in",
                              onPressed: isLoading ? () {} : _handleSignIn,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 20),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/SignUpScreen');
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.white54),
                          children: [
                            TextSpan(
                              text: "sign up",
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

// CustomTextField widget
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

// CustomButton widget
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
