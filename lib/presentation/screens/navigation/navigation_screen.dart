import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';

class NavigationScreen extends StatefulWidget {
  final RouteEntity? route;
  const NavigationScreen({super.key, this.route});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? _mapController;
  final FlutterTts _tts = FlutterTts();
  bool _mapReady = false;
  String? _lastSpoken;

  @override
  void initState() {
    super.initState();
    _initTts();
    if (widget.route != null) {
      context.read<NavigationBloc>().add(StartNavigation(widget.route!));
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    if (_lastSpoken == text) return;
    _lastSpoken = text;
    await _tts.speak(text);
  }

  void _moveCamera(double lat, double lng, double? heading) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: AppConstants.navigationZoom,
          bearing: heading ?? 0,
          tilt: 45,
        ),
      ),
    );
  }

  Set<Polyline> _buildPolylines(RouteEntity route) {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: route.polylinePoints
            .map((p) => LatLng(p.lat, p.lng))
            .toList(),
        color: AppColors.primary,
        width: 5,
        patterns: [],
      ),
    };
  }

  Set<Marker> _buildMarkers(RouteEntity route, NavigationActive state) {
    return {
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(route.origin.latitude, route.origin.longitude),
        infoWindow: InfoWindow(title: route.origin.name),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position:
            LatLng(route.destination.latitude, route.destination.longitude),
        infoWindow: InfoWindow(title: route.destination.name),
      ),
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(state.userLat, state.userLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure),
      ),
    };
  }

  @override
  void dispose() {
    _tts.stop();
    _mapController?.dispose();
    context.read<NavigationBloc>().add(StopNavigation());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavigationBloc, NavigationState>(
      listener: (context, state) {
        if (state is NavigationActive) {
          // Move map camera to follow user
          if (_mapReady) {
            _moveCamera(state.userLat, state.userLng, state.heading);
          }
          // Speak current step
          final step = state.currentStep;
          if (step != null && state.voiceEnabled) {
            _speak(step.instruction);
          }
          // Completed
          if (state.isCompleted) {
            _speak('You have arrived at your destination!');
            _showArrivalDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is! NavigationActive || widget.route == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final route = widget.route!;
        final step = state.currentStep;

        return Scaffold(
          body: Stack(
            children: [
              // ── Map ──────────────────────────────
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(route.origin.latitude, route.origin.longitude),
                  zoom: AppConstants.navigationZoom,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  setState(() => _mapReady = true);
                  _moveCamera(state.userLat, state.userLng, state.heading);
                },
                polylines: _buildPolylines(route),
                markers: _buildMarkers(route, state),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // ── Deviation banner ─────────────────
              if (state.isDeviated)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  child: _DeviationBanner(
                      isRecalculating: state.isRecalculating),
                ),

              // ── Back / voice controls (top) ──────
              if (!state.isDeviated)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.close,
                        onTap: () {
                          context.read<NavigationBloc>().add(StopNavigation());
                          context.pop();
                        },
                      ),
                      const Spacer(),
                      _CircleButton(
                        icon: state.voiceEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        onTap: () => context.read<NavigationBloc>().add(
                              ToggleVoice(!state.voiceEnabled),
                            ),
                        color: state.voiceEnabled
                            ? AppColors.primary
                            : AppColors.onSurfaceMuted,
                      ),
                    ],
                  ),
                ),

              // ── Current step card (bottom) ────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress
                          Row(
                            children: [
                              Text(
                                'Step ${state.currentStepIndex + 1} of ${state.totalSteps}',
                                style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurfaceMuted),
                              ),
                              const Spacer(),
                              Text(
                                '${state.remainingMinutes} min remaining',
                                style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: state.totalSteps > 0
                                  ? state.currentStepIndex / state.totalSteps
                                  : 0,
                              minHeight: 4,
                              backgroundColor: AppColors.surfaceVariant,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Current instruction
                          if (step != null) ...[
                            _ManeuverIcon(maneuver: step.maneuver),
                            const SizedBox(height: 12),
                            Text(
                              step.instruction,
                              style: AppTypography.headlineMedium.copyWith(
                                  color: AppColors.onSurface, height: 1.4),
                            ),
                            if (step.landmark != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.place_outlined,
                                      size: 14,
                                      color: AppColors.onSurfaceMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Look for: ${step.landmark}',
                                    style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.onSurfaceMuted),
                                  ),
                                ],
                              ),
                            ],
                          ] else
                            Text(
                              state.isCompleted
                                  ? '🎉 You have arrived!'
                                  : 'Getting directions…',
                              style: AppTypography.headlineMedium,
                            ),

                          // Next step preview
                          if (state.nextStep != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.onSurfaceMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Then: ${state.nextStep!.instruction}',
                                      style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.onSurfaceMuted),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showArrivalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 You\'ve arrived!'),
        content: Text(
          'You have reached ${widget.route?.destination.name ?? "your destination"}.',
          style: AppTypography.bodyLarge,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.home);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _CircleButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: color ?? AppColors.onSurface),
      ),
    );
  }
}

class _ManeuverIcon extends StatelessWidget {
  final String? maneuver;
  const _ManeuverIcon({this.maneuver});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (maneuver) {
      case 'turn-right': icon = Icons.turn_right_rounded; break;
      case 'turn-left': icon = Icons.turn_left_rounded; break;
      case 'slight-right': icon = Icons.turn_slight_right_rounded; break;
      case 'slight-left': icon = Icons.turn_slight_left_rounded; break;
      case 'uturn-right': icon = Icons.u_turn_right_rounded; break;
      default: icon = Icons.straight_rounded;
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.primary, size: 28),
    );
  }
}

class _DeviationBanner extends StatelessWidget {
  final bool isRecalculating;
  const _DeviationBanner({required this.isRecalculating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isRecalculating
                  ? 'You left the route. Finding a new path…'
                  : 'You seem to have left the planned route.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.warning, fontWeight: FontWeight.w500),
            ),
          ),
          if (isRecalculating)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }
}

// Make AppConstants accessible
class AppConstants {
  static const navigationZoom = 18.0;
}
