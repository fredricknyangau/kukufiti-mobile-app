import 'package:mobile/presentation/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/data_providers.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../core/models/broiler_models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          profileAsync.when(
            data: (profile) => IconButton(
              icon: const Icon(LucideIcons.edit2),
              onPressed: () => _showEditProfileDialog(context, ref, profile),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          final name = profile.fullName ?? 'User';
          final email = profile.email;
          final phone = profile.phoneNumber ?? 'Not set';
          final location = profile.location ?? 'Not set';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        child: Icon(LucideIcons.user, size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Farmer', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(LucideIcons.mail),
                        title: const Text('Email'),
                        subtitle: Text(email),
                      ),
                      const CustomDivider(),
                      ListTile(
                        leading: const Icon(LucideIcons.phone),
                        title: const Text('Phone'),
                        subtitle: Text(phone),
                      ),
                      const CustomDivider(),
                      ListTile(
                        leading: const Icon(LucideIcons.mapPin),
                        title: const Text('Farm Location'),
                        subtitle: Text(location),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Logout',
                  variant: CustomButtonVariant.destructive,
                  icon: const Icon(LucideIcons.logOut, size: 20),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, User profile) {
    final nameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phoneNumber);
    final locationController = TextEditingController(text: profile.location);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInput(label: 'Full Name', controller: nameController),
              const SizedBox(height: 12),
              CustomInput(label: 'Phone Number', controller: phoneController),
              const SizedBox(height: 12),
              CustomInput(label: 'Location', controller: locationController),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            CustomButton(
              text: 'Save',
              isLoading: isLoading,
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                setState(() => isLoading = true);
                try {
                  await ApiClient.instance.put(ApiEndpoints.profile, data: {
                    'full_name': nameController.text.trim(),
                    'phone_number': phoneController.text.trim(),
                    'location': locationController.text.trim(),
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ref.invalidate(profileProvider);
                    ToastService.showSuccess(context, 'Profile updated');
                  }
                } catch (e) {
                  if (ctx.mounted) ToastService.showError(context, 'Failed to update profile');
                } finally {
                  if (ctx.mounted) setState(() => isLoading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
