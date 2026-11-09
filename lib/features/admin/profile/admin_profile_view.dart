import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/routes_path.dart';
import '../../../core/storage/session_storage.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionStorage>();
    final user = session.user;
    final remail = user?['remail']?.toString() ?? user?['email']?.toString() ?? 'Staff Admin';
    final role = user?['role']?.toString() ?? 'Administrator';
    final tabs = (user?['tabs'] as List? ?? []).map((e) => e.toString()).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.textDark.withValues(alpha: 0.1),
                    child: const Icon(Icons.shield_outlined, size: 36, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 14),
                  Text(remail, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(color: AppColors.indigo, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  if (tabs.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Assigned Permissions / Tabs (${tabs.length}):', style: AppTextStyles.caption),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tabs.map((t) {
                        return Chip(
                          label: Text(t, style: const TextStyle(fontSize: 10)),
                          backgroundColor: AppColors.inputBg,
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () async {
                await session.clear();
                Get.offAllNamed(RoutesPath.login);
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Log Out Admin Session', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
