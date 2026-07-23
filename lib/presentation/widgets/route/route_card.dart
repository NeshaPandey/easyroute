// lib/presentation/widgets/route/route_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';

class RouteCard extends StatelessWidget {
  final RouteEntity route;
  final bool isSelected;
  final VoidCallback onTap;

  const RouteCard({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type + badge
            Row(
              children: [
                Text(route.type.icon,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(route.type.label,
                    style: AppTypography.titleLarge.copyWith(
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.onSurface)),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Selected',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // Key stats row
            Row(
              children: [
                _Stat(
                    icon: Icons.access_time_rounded,
                    label: route.durationText,
                    color: AppColors.primary),
                const SizedBox(width: 20),
                _Stat(
                    icon: Icons.straighten_rounded,
                    label: route.distanceText,
                    color: AppColors.onSurfaceMuted),
                const SizedBox(width: 20),
                _Stat(
                    icon: Icons.directions_walk_rounded,
                    label:
                        '${(route.walkingDistanceMeters / 1000).toStringAsFixed(1)}km walk',
                    color: AppColors.walking),
              ],
            ),
            const SizedBox(height: 12),
            // Transport legs visual
            _LegVisualizer(route: route),
            const SizedBox(height: 12),
            // Cost + arrival row
            Row(
              children: [
                const Icon(Icons.currency_rupee_rounded,
                    size: 14, color: AppColors.onSurfaceMuted),
                Text(
                  route.estimatedCost == 0
                      ? 'Free'
                      : '~₹${route.estimatedCost.toStringAsFixed(0)}',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.onSurfaceMuted),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.schedule_rounded,
                    size: 14, color: AppColors.onSurfaceMuted),
                const SizedBox(width: 4),
                Text(
                  'Arrive ${route.arrivalTime}',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.onSurfaceMuted),
                ),
                if (route.transferCount > 0) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.transfer_within_a_station_rounded,
                      size: 14, color: AppColors.onSurfaceMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${route.transferCount} transfer${route.transferCount > 1 ? 's' : ''}',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.onSurfaceMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Stat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(label,
              style:
                  AppTypography.labelLarge.copyWith(color: AppColors.onSurface)),
        ],
      );
}

class _LegVisualizer extends StatelessWidget {
  final RouteEntity route;
  const _LegVisualizer({required this.route});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: route.legs.asMap().entries.map((entry) {
        final leg = entry.value;
        final isLast = entry.key == route.legs.length - 1;
        Color color;
        IconData icon;
        switch (leg.type) {
          case LegType.transit:
            color = leg.transitType == 'SUBWAY'
                ? AppColors.metro
                : AppColors.bus;
            icon = leg.transitType == 'SUBWAY'
                ? Icons.subway_rounded
                : Icons.directions_bus_rounded;
          case LegType.walking:
            color = AppColors.walking;
            icon = Icons.directions_walk_rounded;
          case LegType.waiting:
            color = AppColors.onSurfaceLight;
            icon = Icons.hourglass_empty_rounded;
        }
        return Flexible(
          flex: (leg.distanceMeters / route.distanceMeters * 10).round().clamp(1, 10),
          child: Row(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
                width: double.infinity,
              ),
              if (!isLast)
                Icon(icon, size: 14, color: color),
            ],
          ),
        );
      }).toList(),
    );
  }
}
