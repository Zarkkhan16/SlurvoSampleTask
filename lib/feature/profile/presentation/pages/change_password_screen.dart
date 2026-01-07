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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              HeaderRow(headingName: "Change Password"),
              SizedBox(height: 30),
              _passwordField(
                "Current Password",
                controller: currentPasswordController,
              ),
              const SizedBox(height: 16),
              _passwordField(
                "New Password",
                controller: newPasswordController,
              ),
              const SizedBox(height: 16),
              _passwordField(
                "Confirm Password",
                controller: confirmPasswordController,
                confirmWith: newPasswordController,
              ),
              const Spacer(),

              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Password updated successfully",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                  if (state is PasswordChangeFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
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
                          newPassword: newPasswordController.text.trim(),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
      String label, {
        required TextEditingController controller,
        TextEditingController? confirmWith,
      }) {
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
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.cardBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      style: AppTextStyle.roboto(color: Colors.white),
    );
  }
}
