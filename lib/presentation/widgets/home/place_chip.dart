// lib/presentation/widgets/home/place_chip.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';

class PlaceChip extends StatelessWidget {
  final PlaceEntity place;
  final VoidCallback onTap;
  const PlaceChip({super.key, required this.place, required this.onTap});

  IconData get _icon {
    switch (place.placeType) {
      case 'home': return Icons.home_rounded;
      case 'work': return Icons.work_rounded;
      default: return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name,
                      style: AppTypography.labelLarge
                          .copyWith(color: AppColors.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(place.address,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.onSurfaceMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
