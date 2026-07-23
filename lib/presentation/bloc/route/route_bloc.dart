// lib/presentation/bloc/route/route_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/route_entity.dart';
import '../../../domain/repositories/route_repository.dart';

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
  final RouteRepository _routeRepository;

  RouteBloc({required RouteRepository routeRepository})
      : _routeRepository = routeRepository,
        super(RouteInitial()) {
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
      final routes = await _routeRepository.fetchRoutes(
        origin: event.origin,
        destination: event.destination,
      );
      
      if (routes.isEmpty) {
        emit(RouteError('No routes found between selected places.'));
        return;
      }

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
}
