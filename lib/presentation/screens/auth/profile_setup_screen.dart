import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/toast_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      'full_name': _nameController.text.trim(),
      'location': _locationController.text.trim(),
    };

    // Add email if provided
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      payload['email'] = email;
    }

    try {
      await ApiClient.instance.put(
        ApiEndpoints.profile, // /auth/me
        data: payload,
      );

      if (mounted) {
        ToastService.showSuccess(context, "Profile setup complete!");
        context.go('/dashboard');
      }
    } on DioException catch (e) {
      if (mounted) {
        ToastService.showError(context, getFriendlyErrorMessage(e));
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Center(
                        child: Builder(
                          builder: (context) => Icon(
                            LucideIcons.userPlus,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Complete Profile',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let\'s build your KukuFiti profile',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Input Fields
                      CustomInput(
                        label: 'Full Name',
                        hintText: 'e.g., John Doe',
                        controller: _nameController,
                        prefixIcon: const Icon(LucideIcons.user, size: 20),
                        validator: (value) => value == null || value.isEmpty ? 'Enter your full name' : null,
                      ),
                      const SizedBox(height: 20),

                      CustomInput(
                        label: 'Location / Farm Address',
                        hintText: 'e.g., Nakuru, Kenya',
                        controller: _locationController,
                        prefixIcon: const Icon(LucideIcons.mapPin, size: 20),
                        validator: (value) => value == null || value.isEmpty ? 'Enter your location' : null,
                      ),
                      const SizedBox(height: 20),

                      CustomInput(
                        label: 'Email (Optional)',
                        hintText: 'yourname@example.com',
                        controller: _emailController,
                        prefixIcon: const Icon(LucideIcons.mail, size: 20),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 32),

                      // Finish Button
                      CustomButton(
                        text: 'Finish Setup',
                        onPressed: _handleSaveProfile,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
