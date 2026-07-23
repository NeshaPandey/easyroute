import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/location/location_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';
import '../../widgets/common/voice_fab.dart';
import '../../widgets/home/place_chip.dart';
import '../../widgets/home/recent_place_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  // Demo data
  final _favorites = [
    const PlaceEntity(
      id: 'home', name: 'Home', address: 'Koramangala, Bengaluru',
      latitude: 12.9352, longitude: 77.6245, placeType: 'home',
    ),
    const PlaceEntity(
      id: 'work', name: 'Work', address: 'MG Road, Bengaluru',
      latitude: 12.9758, longitude: 77.6060, placeType: 'work',
    ),
  ];

  final _recents = [
    const PlaceEntity(
      id: 'r1', name: 'City Railway Station',
      address: 'Majestic, Bengaluru',
      latitude: 12.9767, longitude: 77.5713,
    ),
    const PlaceEntity(
      id: 'r2', name: 'Indiranagar Metro',
      address: 'Indiranagar, Bengaluru',
      latitude: 12.9784, longitude: 77.6408,
    ),
    const PlaceEntity(
      id: 'r3', name: 'Lalbagh Botanical Garden',
      address: 'Lalbagh, Bengaluru',
      latitude: 12.9507, longitude: 77.5848,
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(RequestLocation());
  }

  void _goToSearch() => context.push(RouteNames.search);

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user.displayName.split(' ').first
        : 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_greeting()}, $userName 👋',
                                style: AppTypography.headlineMedium.copyWith(
                                    color: AppColors.onSurface),
                              ),
                              const SizedBox(height: 2),
                              BlocBuilder<LocationBloc, LocationState>(
                                builder: (context, state) {
                                  if (state is LocationAvailable) {
                                    return Text(
                                      '📍 Location detected',
                                      style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.primary),
                                    );
                                  }
                                  return Text(
                                    'Getting your location…',
                                    style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.onSurfaceMuted),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // SOS quick-access
                        GestureDetector(
                          onTap: () => context.go(RouteNames.emergency),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.sosContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.emergency,
                                color: AppColors.sos, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Search bar ───────────────────────
                GestureDetector(
                  onTap: _goToSearch,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outline),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search_rounded,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Where do you want to go?',
                            style: AppTypography.bodyLarge
                                .copyWith(color: AppColors.onSurfaceLight),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.mic_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Favorites ────────────────────────
                Text('Quick access',
                    style: AppTypography.titleLarge
                        .copyWith(color: AppColors.onSurface)),
                const SizedBox(height: 12),
                Row(
                  children: _favorites
                      .map((p) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: _favorites.last == p ? 0 : 12),
                              child: PlaceChip(
                                place: p,
                                onTap: () => context.push(
                                  RouteNames.routeSelection,
                                  extra: {'destination': p},
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 28),

                // ── Route type pills ─────────────────
                Text('How do you want to travel?',
                    style: AppTypography.titleLarge
                        .copyWith(color: AppColors.onSurface)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TravelChip(
                          icon: Icons.directions_walk,
                          label: 'Walk',
                          color: AppColors.walking),
                      const SizedBox(width: 10),
                      _TravelChip(
                          icon: Icons.directions_bus,
                          label: 'Bus',
                          color: AppColors.bus),
                      const SizedBox(width: 10),
                      _TravelChip(
                          icon: Icons.subway,
                          label: 'Metro',
                          color: AppColors.metro),
                      const SizedBox(width: 10),
                      _TravelChip(
                          icon: Icons.electric_rickshaw,
                          label: 'Auto',
                          color: AppColors.auto),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Recent ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent places',
                        style: AppTypography.titleLarge
                            .copyWith(color: AppColors.onSurface)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: _recents.asMap().entries.map((entry) {
                      final i = entry.key;
                      final place = entry.value;
                      return Column(
                        children: [
                          RecentPlaceTile(
                            place: place,
                            onTap: () => context.push(
                              RouteNames.routeSelection,
                              extra: {'destination': place},
                            ),
                          ),
                          if (i < _recents.length - 1)
                            const Divider(height: 1, indent: 56),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: VoiceFab(
        onVoiceResult: (text) => context.push(RouteNames.search),
      ),
    );
  }
}

class _TravelChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TravelChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: AppTypography.labelLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}
