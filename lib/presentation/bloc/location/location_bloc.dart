import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationEvent extends Equatable {
  @override List<Object?> get props => [];
}
class RequestLocation extends LocationEvent {}
class LocationReceived extends LocationEvent {
  final double lat, lng;
  LocationReceived(this.lat, this.lng);
  @override List<Object?> get props => [lat, lng];
}

abstract class LocationState extends Equatable {
  @override List<Object?> get props => [];
}
class LocationInitial extends LocationState {}
class LocationLoading extends LocationState {}
class LocationAvailable extends LocationState {
  final double lat, lng;
  LocationAvailable(this.lat, this.lng);
  @override List<Object?> get props => [lat, lng];
}
class LocationDenied extends LocationState {}
class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<RequestLocation>(_onRequest);
  }

  Future<void> _onRequest(RequestLocation e, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        emit(LocationDenied());
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      emit(LocationAvailable(pos.latitude, pos.longitude));
    } catch (_) {
      // Demo fallback: Bengaluru city center
      emit(LocationAvailable(12.9716, 77.5946));
    }
  }
}
