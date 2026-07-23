// lib/presentation/widgets/home/recent_place_tile.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';

class RecentPlaceTile extends StatelessWidget {
  final PlaceEntity place;
  final VoidCallback onTap;
  const RecentPlaceTile({super.key, required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.history_rounded,
            color: AppColors.onSurfaceMuted, size: 20),
      ),
      title: Text(place.name, style: AppTypography.titleLarge),
      subtitle: Text(place.address,
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.onSurfaceMuted)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.onSurfaceLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
