// lib/presentation/widgets/route/route_summary_bar.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';

class RouteSummaryBar extends StatelessWidget {
  final PlaceEntity origin;
  final PlaceEntity destination;
  const RouteSummaryBar({super.key, required this.origin, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              const Icon(Icons.circle, size: 10, color: AppColors.primary),
              Container(width: 1.5, height: 28, color: AppColors.outline),
              const Icon(Icons.location_on_rounded,
                  size: 16, color: AppColors.sos),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(origin.name,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.onSurfaceMuted)),
                const SizedBox(height: 8),
                Text(destination.name,
                    style: AppTypography.titleLarge
                        .copyWith(color: AppColors.onSurface)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
