// lib/domain/entities/route_entity.dart

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────
//  Core domain entities (pure Dart, no Flutter deps)
// ─────────────────────────────────────────────

class PlaceEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? placeType; // restaurant, hospital, bus_stop, etc.
  final String? iconUrl;

  const PlaceEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeType,
    this.iconUrl,
  });

  @override
  List<Object?> get props =>
      [id, name, address, latitude, longitude, placeType];
}

class RouteEntity extends Equatable {
  final String id;
  final RouteType type;
  final PlaceEntity origin;
  final PlaceEntity destination;
  final int durationMinutes;
  final double distanceMeters;
  final double walkingDistanceMeters;
  final double estimatedCost;
  final int transferCount;
  final String arrivalTime;
  final List<RouteLegEntity> legs;
  final List<LatLngEntity> polylinePoints;

  const RouteEntity({
    required this.id,
    required this.type,
    required this.origin,
    required this.destination,
    required this.durationMinutes,
    required this.distanceMeters,
    required this.walkingDistanceMeters,
    required this.estimatedCost,
    required this.transferCount,
    required this.arrivalTime,
    required this.legs,
    required this.polylinePoints,
  });

  String get durationText {
    if (durationMinutes < 60) return '${durationMinutes}m';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String get distanceText {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)}m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }

  @override
  List<Object?> get props => [id, type, durationMinutes, distanceMeters];
}

enum RouteType { fastest, cheapest, leastWalking, transit }

extension RouteTypeExtension on RouteType {
  String get label {
    switch (this) {
      case RouteType.fastest:
        return 'Fastest';
      case RouteType.cheapest:
        return 'Cheapest';
      case RouteType.leastWalking:
        return 'Least Walking';
      case RouteType.transit:
        return 'Public Transport';
    }
  }

  String get icon {
    switch (this) {
      case RouteType.fastest:
        return '⚡';
      case RouteType.cheapest:
        return '💰';
      case RouteType.leastWalking:
        return '🪑';
      case RouteType.transit:
        return '🚌';
    }
  }
}

class RouteLegEntity extends Equatable {
  final LegType type;
  final String instruction; // AI-generated natural language
  final String rawInstruction;
  final double distanceMeters;
  final int durationMinutes;
  final LatLngEntity startLocation;
  final LatLngEntity endLocation;
  final List<RouteStepEntity> steps;

  // Transit-specific
  final String? transitLine;
  final String? transitType; // BUS, SUBWAY, TRAM
  final String? boardingStop;
  final String? alightingStop;
  final int? stopCount;
  final String? vehicleColor;
  final String? vehicleIcon;
  final String? departureTime;
  final String? arrivalTime;

  const RouteLegEntity({
    required this.type,
    required this.instruction,
    required this.rawInstruction,
    required this.distanceMeters,
    required this.durationMinutes,
    required this.startLocation,
    required this.endLocation,
    required this.steps,
    this.transitLine,
    this.transitType,
    this.boardingStop,
    this.alightingStop,
    this.stopCount,
    this.vehicleColor,
    this.vehicleIcon,
    this.departureTime,
    this.arrivalTime,
  });

  @override
  List<Object?> get props => [type, instruction, distanceMeters];
}

class RouteStepEntity extends Equatable {
  final String instruction; // AI natural-language version
  final String htmlInstruction;
  final double distanceMeters;
  final int durationSeconds;
  final LatLngEntity startLocation;
  final LatLngEntity endLocation;
  final String? maneuver; // turn-left, turn-right, straight, etc.
  final String? landmark; // nearby landmark for context

  const RouteStepEntity({
    required this.instruction,
    required this.htmlInstruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.startLocation,
    required this.endLocation,
    this.maneuver,
    this.landmark,
  });

  @override
  List<Object?> get props => [instruction, distanceMeters, startLocation];
}

enum LegType { walking, transit, waiting }

class LatLngEntity extends Equatable {
  final double lat;
  final double lng;

  const LatLngEntity(this.lat, this.lng);

  @override
  List<Object?> get props => [lat, lng];
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<PlaceEntity> favorites;
  final List<PlaceEntity> recentSearches;
  final UserPreferences preferences;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.favorites = const [],
    this.recentSearches = const [],
    required this.preferences,
  });

  @override
  List<Object?> get props => [id, email, displayName];
}

class UserPreferences extends Equatable {
  final bool highContrastMode;
  final bool voiceGuidanceEnabled;
  final bool vibrationEnabled;
  final double textScale;
  final String preferredTransport; // TRANSIT, WALKING, DRIVING
  final bool avoidTolls;
  final bool avoidHighways;

  const UserPreferences({
    this.highContrastMode = false,
    this.voiceGuidanceEnabled = true,
    this.vibrationEnabled = true,
    this.textScale = 1.0,
    this.preferredTransport = 'TRANSIT',
    this.avoidTolls = false,
    this.avoidHighways = false,
  });

  UserPreferences copyWith({
    bool? highContrastMode,
    bool? voiceGuidanceEnabled,
    bool? vibrationEnabled,
    double? textScale,
    String? preferredTransport,
  }) =>
      UserPreferences(
        highContrastMode: highContrastMode ?? this.highContrastMode,
        voiceGuidanceEnabled:
            voiceGuidanceEnabled ?? this.voiceGuidanceEnabled,
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
        textScale: textScale ?? this.textScale,
        preferredTransport: preferredTransport ?? this.preferredTransport,
      );

  @override
  List<Object?> get props => [
        highContrastMode,
        voiceGuidanceEnabled,
        vibrationEnabled,
        textScale,
        preferredTransport,
      ];
}
