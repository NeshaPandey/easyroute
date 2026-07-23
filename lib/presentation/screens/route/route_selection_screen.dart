import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/route/route_bloc.dart';
import '../../bloc/location/location_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';
import '../../widgets/route/route_card.dart';
import '../../widgets/route/route_summary_bar.dart';

class RouteSelectionScreen extends StatefulWidget {
  final PlaceEntity? origin;
  final PlaceEntity? destination;
  const RouteSelectionScreen({super.key, this.origin, this.destination});

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _searchRoutes();
  }

  void _searchRoutes() {
    final locState = context.read<LocationBloc>().state;
    final origin = widget.origin ??
        PlaceEntity(
          id: 'current',
          name: 'Your location',
          address: 'Current location',
          latitude: locState is LocationAvailable ? locState.lat : 12.9716,
          longitude: locState is LocationAvailable ? locState.lng : 77.5946,
        );
    final destination = widget.destination ??
        const PlaceEntity(
          id: 'dest',
          name: 'Destination',
          address: '',
          latitude: 12.9790,
          longitude: 77.6050,
        );

    context.read<RouteBloc>().add(
          SearchRoutes(origin: origin, destination: destination),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your route'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state is RouteLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Finding the best routes for you…',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.onSurfaceMuted)),
                ],
              ),
            );
          }

          if (state is RouteError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 48, color: AppColors.onSurfaceLight),
                    const SizedBox(height: 16),
                    Text('Could not load routes',
                        style: AppTypography.headlineMedium),
                    const SizedBox(height: 8),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.onSurfaceMuted)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _searchRoutes,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RouteLoaded) {
            return Column(
              children: [
                // Origin → destination summary
                RouteSummaryBar(
                  origin: state.origin,
                  destination: state.destination,
                ),

                // Route cards
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.routes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final route = state.routes[i];
                      return RouteCard(
                        route: route,
                        isSelected: state.selectedRoute?.id == route.id,
                        onTap: () {
                          context.read<RouteBloc>().add(SelectRoute(route));
                        },
                      );
                    },
                  ),
                ),

                // Start navigation CTA
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: ElevatedButton.icon(
                      onPressed: state.selectedRoute == null
                          ? null
                          : () => context.push(
                                RouteNames.navigation,
                                extra: state.selectedRoute,
                              ),
                      icon: const Icon(Icons.navigation_rounded),
                      label: Text(state.selectedRoute != null
                          ? 'Start — ${state.selectedRoute!.durationText}'
                          : 'Select a route'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
