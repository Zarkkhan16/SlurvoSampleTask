import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late String email;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final user = context.read<AuthBloc>().state as Authenticated;
    nameController = TextEditingController(text: user.user.name);
    emailController = TextEditingController(text: user.user.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                HeaderRow(headingName: "Edit Profile"),
                SizedBox(height: 30),
                _field(
                  "Email",
                  controller: emailController,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                _field(
                  "Name",
                  controller: nameController,
                ),
                const Spacer(),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated) {
                      Navigator.pop(context);
            
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Profile updated",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SessionViewButton(
                      onSessionClick: () {
                        if (!_formKey.currentState!.validate()) return;
                        context.read<AuthBloc>().add(
                              UpdateProfileRequested(
                                name: nameController.text.trim(),
                              ),
                            );
                      },
                      isLoading: state is ProfileUpdating,
                      buttonText: "Update",
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label, {
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,

      // 🔹 Cursor color
      cursorColor: Colors.white,

      style: AppTextStyle.roboto(
        color: enabled ? Colors.white : Colors.white70,
        fontSize: 16,
      ),

      // 🔹 VALIDATION (only for Name field)
      validator: (value) {
        if (!enabled) return null; // email field skip

        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Name cannot be empty';
        }
        if (text.length < 4) {
          return 'Name must be at least 4 characters';
        }
        return null;
      },

      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyle.roboto(color: Colors.white70),

        filled: true,
        fillColor: AppColors.cardBackground,

        // 🔹 Normal border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),

        // 🔹 Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),

        // 🔹 Disabled border (email field)
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),

        // 🔹 Error border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
