import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _voiceEnabled = true;
  bool _highContrast = false;
  bool _darkMode = false;
  double _textScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    (user?.displayName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'User',
                          style: AppTypography.headlineMedium
                              .copyWith(color: Colors.white)),
                      Text(user?.email ?? '',
                          style: AppTypography.bodyMedium
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Accessibility
          _SectionHeader('Accessibility'),
          _SettingsTile(
            icon: Icons.record_voice_over_outlined,
            title: 'Voice guidance',
            subtitle: 'Spoken directions during navigation',
            trailing: Switch(
              value: _voiceEnabled,
              onChanged: (v) => setState(() => _voiceEnabled = v),
            ),
          ),
          _SettingsTile(
            icon: Icons.contrast,
            title: 'High contrast mode',
            subtitle: 'Stronger colors for better visibility',
            trailing: Switch(
              value: _highContrast,
              onChanged: (v) => setState(() => _highContrast = v),
            ),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark mode',
            subtitle: 'Easier on the eyes at night',
            trailing: Switch(
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields_rounded,
                        color: AppColors.onSurfaceMuted, size: 20),
                    const SizedBox(width: 12),
                    Text('Text size',
                        style: AppTypography.titleLarge),
                    const Spacer(),
                    Text('${(_textScale * 100).toInt()}%',
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
                Slider(
                  value: _textScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 3,
                  onChanged: (v) => setState(() => _textScale = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Navigation preferences
          _SectionHeader('Navigation preferences'),
          _SettingsTile(
            icon: Icons.directions_bus_outlined,
            title: 'Preferred transport',
            subtitle: 'Public transit',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'Favourite places',
            subtitle: 'Home, Work and saved locations',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.emergency_outlined,
            title: 'Emergency contacts',
            subtitle: 'Manage SOS contacts',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go(RouteNames.emergency),
          ),
          const SizedBox(height: 16),

          // About
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App version',
            subtitle: 'EasyRoute 1.0.0',
            trailing: const SizedBox.shrink(),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // Sign out
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go(RouteNames.login);
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: const Text('Sign out',
                style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title,
            style: AppTypography.labelLarge
                .copyWith(color: AppColors.onSurfaceMuted)),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          title: Text(title, style: AppTypography.titleLarge),
          subtitle: subtitle != null
              ? Text(subtitle!,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.onSurfaceMuted))
              : null,
          trailing: trailing,
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}
