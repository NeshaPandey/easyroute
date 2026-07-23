// lib/presentation/bloc/navigation/navigation_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../domain/entities/route_entity.dart';
import '../../../core/constants/app_constants.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class NavigationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartNavigation extends NavigationEvent {
  final RouteEntity route;
  StartNavigation(this.route);
  @override
  List<Object?> get props => [route];
}

class LocationUpdated extends NavigationEvent {
  final double lat;
  final double lng;
  final double? heading;
  final double? speed;
  LocationUpdated({required this.lat, required this.lng, this.heading, this.speed});
  @override
  List<Object?> get props => [lat, lng];
}

class StepCompleted extends NavigationEvent {
  final int stepIndex;
  StepCompleted(this.stepIndex);
}

class RouteDeviationDetected extends NavigationEvent {}

class RecalculatingRoute extends NavigationEvent {}

class RouteRecalculated extends NavigationEvent {
  final RouteEntity newRoute;
  RouteRecalculated(this.newRoute);
}

class StopNavigation extends NavigationEvent {}

class ToggleVoice extends NavigationEvent {
  final bool enabled;
  ToggleVoice(this.enabled);
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class NavigationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NavigationIdle extends NavigationState {}

class NavigationActive extends NavigationState {
  final RouteEntity route;
  final int currentStepIndex;
  final double userLat;
  final double userLng;
  final double? heading;
  final double? speed;
  final bool isDeviated;
  final bool isRecalculating;
  final bool voiceEnabled;
  final int remainingMinutes;
  final double remainingDistanceMeters;
  final bool isCompleted;

  NavigationActive({
    required this.route,
    required this.currentStepIndex,
    required this.userLat,
    required this.userLng,
    this.heading,
    this.speed,
    this.isDeviated = false,
    this.isRecalculating = false,
    this.voiceEnabled = true,
    required this.remainingMinutes,
    required this.remainingDistanceMeters,
    this.isCompleted = false,
  });

  RouteStepEntity? get currentStep {
    final allSteps = route.legs.expand((leg) => leg.steps).toList();
    if (currentStepIndex < allSteps.length) {
      return allSteps[currentStepIndex];
    }
    return null;
  }

  RouteStepEntity? get nextStep {
    final allSteps = route.legs.expand((leg) => leg.steps).toList();
    if (currentStepIndex + 1 < allSteps.length) {
      return allSteps[currentStepIndex + 1];
    }
    return null;
  }

  int get totalSteps =>
      route.legs.fold(0, (sum, leg) => sum + leg.steps.length);

  NavigationActive copyWith({
    RouteEntity? route,
    int? currentStepIndex,
    double? userLat,
    double? userLng,
    double? heading,
    double? speed,
    bool? isDeviated,
    bool? isRecalculating,
    bool? voiceEnabled,
    int? remainingMinutes,
    double? remainingDistanceMeters,
    bool? isCompleted,
  }) =>
      NavigationActive(
        route: route ?? this.route,
        currentStepIndex: currentStepIndex ?? this.currentStepIndex,
        userLat: userLat ?? this.userLat,
        userLng: userLng ?? this.userLng,
        heading: heading ?? this.heading,
        speed: speed ?? this.speed,
        isDeviated: isDeviated ?? this.isDeviated,
        isRecalculating: isRecalculating ?? this.isRecalculating,
        voiceEnabled: voiceEnabled ?? this.voiceEnabled,
        remainingMinutes: remainingMinutes ?? this.remainingMinutes,
        remainingDistanceMeters:
            remainingDistanceMeters ?? this.remainingDistanceMeters,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  List<Object?> get props => [
        route,
        currentStepIndex,
        userLat,
        userLng,
        heading,
        isDeviated,
        isRecalculating,
        voiceEnabled,
        remainingMinutes,
        isCompleted,
      ];
}

class NavigationError extends NavigationState {
  final String message;
  NavigationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  StreamSubscription<Position>? _locationSubscription;

  NavigationBloc() : super(NavigationIdle()) {
    on<StartNavigation>(_onStartNavigation);
    on<LocationUpdated>(_onLocationUpdated);
    on<StepCompleted>(_onStepCompleted);
    on<RouteDeviationDetected>(_onDeviationDetected);
    on<RouteRecalculated>(_onRouteRecalculated);
    on<StopNavigation>(_onStopNavigation);
    on<ToggleVoice>(_onToggleVoice);
  }

  Future<void> _onStartNavigation(
    StartNavigation event,
    Emitter<NavigationState> emit,
  ) async {
    // Get initial location
    try {
      final position = await Geolocator.getCurrentPosition();
      final state = NavigationActive(
        route: event.route,
        currentStepIndex: 0,
        userLat: position.latitude,
        userLng: position.longitude,
        heading: position.heading,
        speed: position.speed,
        remainingMinutes: event.route.durationMinutes,
        remainingDistanceMeters: event.route.distanceMeters,
      );
      emit(state);
      _startLocationTracking();
    } catch (e) {
      emit(NavigationError('Could not get your location. Please enable GPS.'));
    }
  }

  void _startLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update every 5 meters moved
      ),
    ).listen((position) {
      add(LocationUpdated(
        lat: position.latitude,
        lng: position.longitude,
        heading: position.heading,
        speed: position.speed,
      ));
    });
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<NavigationState> emit,
  ) {
    final current = state;
    if (current is! NavigationActive) return;

    // Check if user has advanced to next step
    final allSteps = current.route.legs.expand((l) => l.steps).toList();
    int newStepIndex = current.currentStepIndex;

    if (newStepIndex < allSteps.length) {
      final currentStep = allSteps[newStepIndex];
      final distToStepEnd = Geolocator.distanceBetween(
        event.lat,
        event.lng,
        currentStep.endLocation.lat,
        currentStep.endLocation.lng,
      );

      // Advance step when within 20 meters of step end
      if (distToStepEnd < 20 && newStepIndex < allSteps.length - 1) {
        newStepIndex++;
      }

      // Check if reached destination
      final distToDestination = Geolocator.distanceBetween(
        event.lat,
        event.lng,
        current.route.destination.latitude,
        current.route.destination.longitude,
      );

      if (distToDestination < 30) {
        emit(current.copyWith(isCompleted: true, currentStepIndex: newStepIndex));
        return;
      }

      // Check for route deviation
      bool isDeviated = _checkDeviation(
        event.lat,
        event.lng,
        allSteps,
        newStepIndex,
      );

      // Recalculate remaining time (rough estimate)
      final remainingSteps = allSteps.skip(newStepIndex).toList();
      final remainingSecs = remainingSteps.fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds,
      );

      emit(current.copyWith(
        userLat: event.lat,
        userLng: event.lng,
        heading: event.heading,
        speed: event.speed,
        currentStepIndex: newStepIndex,
        isDeviated: isDeviated,
        remainingMinutes: (remainingSecs / 60).ceil(),
      ));

      if (isDeviated && !current.isDeviated) {
        add(RouteDeviationDetected());
      }
    }
  }

  bool _checkDeviation(
    double userLat,
    double userLng,
    List<RouteStepEntity> steps,
    int currentStepIndex,
  ) {
    if (currentStepIndex >= steps.length) return false;

    final step = steps[currentStepIndex];
    // Check distance to the line between step start and end
    final distToStart = Geolocator.distanceBetween(
      userLat,
      userLng,
      step.startLocation.lat,
      step.startLocation.lng,
    );
    final distToEnd = Geolocator.distanceBetween(
      userLat,
      userLng,
      step.endLocation.lat,
      step.endLocation.lng,
    );

    // If far from both start and end, consider deviated
    return distToStart > AppConstants.deviationThreshold &&
        distToEnd > AppConstants.deviationThreshold + step.distanceMeters * 0.3;
  }

  void _onStepCompleted(StepCompleted event, Emitter<NavigationState> emit) {
    final current = state;
    if (current is! NavigationActive) return;
    emit(current.copyWith(currentStepIndex: event.stepIndex + 1));
  }

  void _onDeviationDetected(
    RouteDeviationDetected event,
    Emitter<NavigationState> emit,
  ) {
    final current = state;
    if (current is! NavigationActive) return;
    emit(current.copyWith(isDeviated: true, isRecalculating: true));
    // In a real app, trigger route recalculation here via use case
  }

  void _onRouteRecalculated(
    RouteRecalculated event,
    Emitter<NavigationState> emit,
  ) {
    final current = state;
    if (current is! NavigationActive) return;
    emit(current.copyWith(
      route: event.newRoute,
      currentStepIndex: 0,
      isDeviated: false,
      isRecalculating: false,
    ));
  }

  void _onStopNavigation(StopNavigation event, Emitter<NavigationState> emit) {
    _locationSubscription?.cancel();
    emit(NavigationIdle());
  }

  void _onToggleVoice(ToggleVoice event, Emitter<NavigationState> emit) {
    final current = state;
    if (current is! NavigationActive) return;
    emit(current.copyWith(voiceEnabled: event.enabled));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
