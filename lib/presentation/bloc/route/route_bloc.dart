// lib/presentation/bloc/route/route_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/route_entity.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class RouteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchRoutes extends RouteEvent {
  final PlaceEntity origin;
  final PlaceEntity destination;
  SearchRoutes({required this.origin, required this.destination});
  @override
  List<Object?> get props => [origin, destination];
}

class SelectRoute extends RouteEvent {
  final RouteEntity route;
  SelectRoute(this.route);
  @override
  List<Object?> get props => [route];
}

class ClearRoute extends RouteEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class RouteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RouteInitial extends RouteState {}

class RouteLoading extends RouteState {}

class RouteLoaded extends RouteState {
  final List<RouteEntity> routes;
  final RouteEntity? selectedRoute;
  final PlaceEntity origin;
  final PlaceEntity destination;

  RouteLoaded({
    required this.routes,
    this.selectedRoute,
    required this.origin,
    required this.destination,
  });

  RouteLoaded copyWith({
    List<RouteEntity>? routes,
    RouteEntity? selectedRoute,
    PlaceEntity? origin,
    PlaceEntity? destination,
  }) =>
      RouteLoaded(
        routes: routes ?? this.routes,
        selectedRoute: selectedRoute ?? this.selectedRoute,
        origin: origin ?? this.origin,
        destination: destination ?? this.destination,
      );

  @override
  List<Object?> get props => [routes, selectedRoute, origin, destination];
}

class RouteError extends RouteState {
  final String message;
  RouteError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(RouteInitial()) {
    on<SearchRoutes>(_onSearchRoutes);
    on<SelectRoute>(_onSelectRoute);
    on<ClearRoute>(_onClearRoute);
  }

  Future<void> _onSearchRoutes(
    SearchRoutes event,
    Emitter<RouteState> emit,
  ) async {
    emit(RouteLoading());
    try {
      // In production, inject a RouteRepository and call it here.
      // For demonstration, we generate realistic mock routes.
      await Future.delayed(const Duration(milliseconds: 1500));
      final routes = _generateMockRoutes(event.origin, event.destination);
      emit(RouteLoaded(
        routes: routes,
        selectedRoute: routes.first,
        origin: event.origin,
        destination: event.destination,
      ));
    } catch (e) {
      emit(RouteError(
          'Could not find routes. Please check your connection and try again.'));
    }
  }

  void _onSelectRoute(SelectRoute event, Emitter<RouteState> emit) {
    final current = state;
    if (current is RouteLoaded) {
      emit(current.copyWith(selectedRoute: event.route));
    }
  }

  void _onClearRoute(ClearRoute event, Emitter<RouteState> emit) {
    emit(RouteInitial());
  }

  // Mock route data — replace with real Google Directions API calls
  List<RouteEntity> _generateMockRoutes(
    PlaceEntity origin,
    PlaceEntity destination,
  ) {
    final mockSteps = [
      const RouteStepEntity(
        instruction: 'Walk straight for about 3 minutes until you reach the main road.',
        htmlInstruction: 'Head north toward Main St',
        distanceMeters: 230,
        durationSeconds: 180,
        startLocation: LatLngEntity(12.9716, 77.5946),
        endLocation: LatLngEntity(12.9730, 77.5950),
        maneuver: 'straight',
        landmark: 'coffee shop on your left',
      ),
      const RouteStepEntity(
        instruction: 'Turn right at the traffic light — you\'ll see a pharmacy on the corner.',
        htmlInstruction: 'Turn right onto MG Road',
        distanceMeters: 150,
        durationSeconds: 120,
        startLocation: LatLngEntity(12.9730, 77.5950),
        endLocation: LatLngEntity(12.9735, 77.5965),
        maneuver: 'turn-right',
        landmark: 'traffic light',
      ),
      const RouteStepEntity(
        instruction: 'You\'ve reached City Bus Stop. Wait here for Bus 500 (blue bus). Board from the front door.',
        htmlInstruction: 'Board Bus 500 at City Bus Stop',
        distanceMeters: 50,
        durationSeconds: 60,
        startLocation: LatLngEntity(12.9735, 77.5965),
        endLocation: LatLngEntity(12.9738, 77.5970),
        maneuver: null,
        landmark: 'City Bus Stop',
      ),
      const RouteStepEntity(
        instruction: 'Stay on Bus 500 for 3 stops — about 12 minutes. You\'ll pass the market and the school.',
        htmlInstruction: 'Take Bus 500 for 3 stops',
        distanceMeters: 2800,
        durationSeconds: 720,
        startLocation: LatLngEntity(12.9738, 77.5970),
        endLocation: LatLngEntity(12.9780, 77.6030),
        maneuver: null,
        landmark: 'City Center stop',
      ),
      const RouteStepEntity(
        instruction: 'Get off at City Center stop. You\'ll see the large fountain in front of you.',
        htmlInstruction: 'Alight at City Center',
        distanceMeters: 0,
        durationSeconds: 30,
        startLocation: LatLngEntity(12.9780, 77.6030),
        endLocation: LatLngEntity(12.9780, 77.6030),
        maneuver: null,
        landmark: 'fountain',
      ),
      const RouteStepEntity(
        instruction: 'Walk past the fountain and continue straight for 2 minutes. Your destination is the tall blue building on the right.',
        htmlInstruction: 'Walk to destination',
        distanceMeters: 180,
        durationSeconds: 150,
        startLocation: LatLngEntity(12.9780, 77.6030),
        endLocation: LatLngEntity(12.9790, 77.6050),
        maneuver: 'straight',
        landmark: 'blue building',
      ),
    ];

    final transitLeg = RouteLegEntity(
      type: LegType.transit,
      instruction: 'Board Bus 500 from City Bus Stop and ride for 3 stops.',
      rawInstruction: 'Take Bus 500 (3 stops)',
      distanceMeters: 2800,
      durationMinutes: 12,
      startLocation: const LatLngEntity(12.9738, 77.5970),
      endLocation: const LatLngEntity(12.9780, 77.6030),
      steps: mockSteps.sublist(2, 5),
      transitLine: 'Bus 500',
      transitType: 'BUS',
      boardingStop: 'City Bus Stop',
      alightingStop: 'City Center',
      stopCount: 3,
      vehicleColor: '#1565C0',
      departureTime: '10:15 AM',
      arrivalTime: '10:27 AM',
    );

    final walkLeg1 = RouteLegEntity(
      type: LegType.walking,
      instruction: 'Walk from your location to City Bus Stop.',
      rawInstruction: 'Walk to City Bus Stop',
      distanceMeters: 430,
      durationMinutes: 6,
      startLocation: const LatLngEntity(12.9716, 77.5946),
      endLocation: const LatLngEntity(12.9738, 77.5970),
      steps: mockSteps.sublist(0, 3),
    );

    final walkLeg2 = RouteLegEntity(
      type: LegType.walking,
      instruction: 'Walk from the bus stop to your destination.',
      rawInstruction: 'Walk to destination',
      distanceMeters: 180,
      durationMinutes: 3,
      startLocation: const LatLngEntity(12.9780, 77.6030),
      endLocation: const LatLngEntity(12.9790, 77.6050),
      steps: mockSteps.sublist(5),
    );

    const polyline = [
      LatLngEntity(12.9716, 77.5946),
      LatLngEntity(12.9730, 77.5950),
      LatLngEntity(12.9735, 77.5965),
      LatLngEntity(12.9738, 77.5970),
      LatLngEntity(12.9750, 77.5990),
      LatLngEntity(12.9765, 77.6010),
      LatLngEntity(12.9780, 77.6030),
      LatLngEntity(12.9785, 77.6040),
      LatLngEntity(12.9790, 77.6050),
    ];

    return [
      RouteEntity(
        id: 'route_transit',
        type: RouteType.fastest,
        origin: origin,
        destination: destination,
        durationMinutes: 21,
        distanceMeters: 3410,
        walkingDistanceMeters: 610,
        estimatedCost: 15,
        transferCount: 0,
        arrivalTime: '10:31 AM',
        legs: [walkLeg1, transitLeg, walkLeg2],
        polylinePoints: polyline,
      ),
      RouteEntity(
        id: 'route_cheapest',
        type: RouteType.cheapest,
        origin: origin,
        destination: destination,
        durationMinutes: 28,
        distanceMeters: 3200,
        walkingDistanceMeters: 400,
        estimatedCost: 10,
        transferCount: 1,
        arrivalTime: '10:38 AM',
        legs: [walkLeg1, transitLeg, walkLeg2],
        polylinePoints: polyline,
      ),
      RouteEntity(
        id: 'route_least_walk',
        type: RouteType.leastWalking,
        origin: origin,
        destination: destination,
        durationMinutes: 25,
        distanceMeters: 3600,
        walkingDistanceMeters: 280,
        estimatedCost: 22,
        transferCount: 0,
        arrivalTime: '10:35 AM',
        legs: [walkLeg1, transitLeg, walkLeg2],
        polylinePoints: polyline,
      ),
      RouteEntity(
        id: 'route_transit_only',
        type: RouteType.transit,
        origin: origin,
        destination: destination,
        durationMinutes: 35,
        distanceMeters: 4200,
        walkingDistanceMeters: 150,
        estimatedCost: 20,
        transferCount: 2,
        arrivalTime: '10:45 AM',
        legs: [walkLeg1, transitLeg, walkLeg2],
        polylinePoints: polyline,
      ),
    ];
  }
}
