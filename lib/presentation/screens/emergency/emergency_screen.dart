import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  bool _sosSent = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  final _contacts = [
    {'name': 'Mum', 'phone': '+91 98765 43210', 'icon': Icons.favorite},
    {'name': 'Dad', 'phone': '+91 91234 56789', 'icon': Icons.person},
    {'name': 'Priya', 'phone': '+91 87654 32109', 'icon': Icons.person},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _sendSOS() {
    setState(() => _sosSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 SOS sent! Your contacts have been notified.'),
        backgroundColor: AppColors.sos,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SOS button
              Center(
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _pulse,
                      child: GestureDetector(
                        onTap: _sosSent ? null : _sendSOS,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _sosSent
                                ? AppColors.sosContainer
                                : AppColors.sos,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.sos.withOpacity(0.35),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _sosSent
                                    ? Icons.check_circle_outline
                                    : Icons.emergency,
                                color: _sosSent
                                    ? AppColors.sos
                                    : Colors.white,
                                size: 52,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _sosSent ? 'SENT' : 'SOS',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _sosSent
                                      ? AppColors.sos
                                      : Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _sosSent
                          ? 'Help is on the way. Stay safe.'
                          : 'Tap to send emergency alert',
                      style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Location sharing
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Live location sharing',
                              style: AppTypography.titleLarge
                                  .copyWith(color: AppColors.primaryDark)),
                          Text(
                            _sosSent
                                ? 'Your location is being shared with your emergency contacts.'
                                : 'Your live location will be shared when you send SOS.',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Contacts
              Text('Emergency contacts',
                  style: AppTypography.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      ..._contacts.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryContainer,
                                child: Icon(c['icon'] as IconData,
                                    color: AppColors.primary, size: 20),
                              ),
                              title: Text(c['name'] as String,
                                  style: AppTypography.titleLarge),
                              subtitle: Text(c['phone'] as String,
                                  style: AppTypography.bodyMedium
                                      .copyWith(color: AppColors.onSurfaceMuted)),
                              trailing: IconButton(
                                icon: const Icon(Icons.call_outlined,
                                    color: AppColors.success),
                                onPressed: () {},
                              ),
                            ),
                            if (i < _contacts.length - 1)
                              const Divider(height: 1, indent: 56),
                          ],
                        );
                      }),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.surfaceVariant,
                          child: const Icon(Icons.add, color: AppColors.onSurfaceMuted),
                        ),
                        title: Text('Add contact',
                            style: AppTypography.bodyLarge
                                .copyWith(color: AppColors.primary)),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
