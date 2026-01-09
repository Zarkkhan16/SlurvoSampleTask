import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_event.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_state.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // scale factors
    final textScale = width / 375; // base iPhone width
    final verticalSpace = height * 0.02;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.005,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeaderRow(
                        headingName: "Change Password",
                        onBackButton: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Future.delayed(const Duration(milliseconds: 200))
                              .then((_) => Navigator.pop(context));
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      _passwordField(
                        "Current Password",
                        controller: currentPasswordController,
                        textScale: MediaQuery.of(context).size.width / 375,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      _passwordField(
                        "New Password",
                        controller: newPasswordController,
                        textScale: MediaQuery.of(context).size.width / 375,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      _passwordField(
                        "Confirm Password",
                        controller: confirmPasswordController,
                        confirmWith: newPasswordController,
                        textScale: MediaQuery.of(context).size.width / 375,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
              ),
            ),

            // 🔹 Fixed Bottom Button
            Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.04,
                right: MediaQuery.of(context).size.width * 0.04,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 20,
              ),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password updated successfully"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    Future.delayed(const Duration(milliseconds: 200))
                        .then((_) => Navigator.pop(context));
                  }
                  if (state is PasswordChangeFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SessionViewButton(
                    buttonText: "Update Password",
                    isLoading: state is PasswordChanging,
                    onSessionClick: state is PasswordChanging
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;
                            context.read<AuthBloc>().add(
                                  ChangePasswordRequested(
                                    currentPassword:
                                        currentPasswordController.text.trim(),
                                    newPassword:
                                        newPasswordController.text.trim(),
                                  ),
                                );
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(
    String label, {
    required TextEditingController controller,
    TextEditingController? confirmWith,
    required double textScale,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white),
    );

    return TextFormField(
      controller: controller,
      obscureText: true,
      cursorColor: Colors.white,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (label == "New Password" && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (confirmWith != null && value != confirmWith.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      style: AppTextStyle.roboto(
        color: Colors.white,
        fontSize: 14 * textScale,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyle.roboto(
          color: Colors.white70,
          fontSize: 13 * textScale,
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
        errorStyle: AppTextStyle.roboto(
          color: Colors.red,
          fontSize: 11 * textScale,
        ),
      ),
    );
  }
}
