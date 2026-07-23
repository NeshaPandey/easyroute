import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/ai_navigation_service.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/route_repository.dart';

/// Implementation of RouteRepository with live directions via Google Directions
/// or OSRM (Open Source Routing Machine) with Gemma AI step transformation.
class GoogleRouteRepositoryImpl implements RouteRepository {
  final String? googleApiKey;
  final http.Client _client;

  GoogleRouteRepositoryImpl({
    this.googleApiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<List<RouteEntity>> fetchRoutes({
    required PlaceEntity origin,
    required PlaceEntity destination,
  }) async {
    // 1. Try Google Directions API if key exists
    if (googleApiKey != null && googleApiKey!.isNotEmpty && !googleApiKey!.contains('mock')) {
      try {
        final googleRoutes = await _fetchGoogleDirections(origin, destination);
        if (googleRoutes.isNotEmpty) return googleRoutes;
      } catch (_) {
        // Fallback to OSRM
      }
    }

    // 2. Try OSRM (Open Source Routing Machine - Free)
    try {
      final osrmRoutes = await _fetchOsrmDirections(origin, destination);
      if (osrmRoutes.isNotEmpty) return osrmRoutes;
    } catch (_) {
      // Fallback to mock route calculation
    }

    // 3. Fallback to generating mock route options based on given places
    return _generateCalculatedMockRoutes(origin, destination);
  }

  Future<List<RouteEntity>> _fetchGoogleDirections(
    PlaceEntity origin,
    PlaceEntity destination,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&alternatives=true'
      '&mode=transit'
      '&key=$googleApiKey',
    );

    final response = await _client.get(url);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    if (data['status'] != 'OK') return [];

    final routesJson = data['routes'] as List;
    List<RouteEntity> resultRoutes = [];

    for (int i = 0; i < routesJson.length; i++) {
      final route = routesJson[i];
      final leg = route['legs'][0];

      final rawSteps = (leg['steps'] as List).map<Map<String, dynamic>>((s) {
        final htmlInst = s['html_instructions'] as String? ?? '';
        final cleanInst = htmlInst.replaceAll(RegExp(r'<[^>]*>'), '');
        return {
          'instruction': cleanInst,
          'distance': s['distance']['text'] ?? '',
          'duration': s['duration']['text'] ?? '',
        };
      }).toList();

      final durationMinutes = ((leg['duration']['value'] as num) / 60).round();

      // Transform raw steps into friendly instructions using Gemma AI
      final aiResult = await AiNavigationService.transformRoute(
        originName: origin.name,
        destinationName: destination.name,
        rawSteps: rawSteps,
        totalMinutes: durationMinutes,
      );

      final polylinePoints = _decodePolyline(route['overview_polyline']['points'] ?? '');

      final routeSteps = aiResult.steps.map((aiStep) {
        return RouteStepEntity(
          instruction: aiStep.friendly,
          htmlInstruction: aiStep.original,
          distanceMeters: 200,
          durationSeconds: 120,
          startLocation: LatLngEntity(origin.latitude, origin.longitude),
          endLocation: LatLngEntity(destination.latitude, destination.longitude),
          maneuver: aiStep.type,
          landmark: aiStep.emoji,
        );
      }).toList();

      final legEntity = RouteLegEntity(
        type: LegType.transit,
        instruction: aiResult.summary,
        rawInstruction: leg['start_address'] ?? '',
        distanceMeters: (leg['distance']['value'] as num).toDouble(),
        durationMinutes: durationMinutes,
        startLocation: LatLngEntity(origin.latitude, origin.longitude),
        endLocation: LatLngEntity(destination.latitude, destination.longitude),
        steps: routeSteps,
      );

      final routeType = _assignRouteType(i);

      resultRoutes.add(RouteEntity(
        id: 'route_google_$i',
        type: routeType,
        origin: origin,
        destination: destination,
        durationMinutes: durationMinutes,
        distanceMeters: (leg['distance']['value'] as num).toDouble(),
        walkingDistanceMeters: 400.0,
        estimatedCost: 15.0 + (i * 5),
        transferCount: i,
        arrivalTime: '${durationMinutes}m away',
        legs: [legEntity],
        polylinePoints: polylinePoints.isNotEmpty
            ? polylinePoints
            : [
                LatLngEntity(origin.latitude, origin.longitude),
                LatLngEntity(destination.latitude, destination.longitude),
              ],
      ));
    }

    return resultRoutes;
  }

  Future<List<RouteEntity>> _fetchOsrmDirections(
    PlaceEntity origin,
    PlaceEntity destination,
  ) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=polyline&steps=true',
    );

    final response = await _client.get(url);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    if (data['code'] != 'Ok') return [];

    final routesJson = data['routes'] as List;
    if (routesJson.isEmpty) return [];

    final route = routesJson.first;
    final leg = route['legs'][0];
    final durationMinutes = ((route['duration'] as num) / 60).round();

    final rawSteps = (leg['steps'] as List).map<Map<String, dynamic>>((s) {
      final maneuver = s['maneuver'];
      final name = s['name'] as String? ?? '';
      final instruction = '${maneuver['type'] ?? 'Walk'} ${maneuver['modifier'] ?? ''} onto $name'.trim();
      final distMeters = (s['distance'] as num).toDouble();
      final durSeconds = (s['duration'] as num).toDouble();

      return {
        'instruction': instruction,
        'distance': '${distMeters.round()}m',
        'duration': '${(durSeconds / 60).round()}m',
      };
    }).toList();

    // Call Gemma AI service
    final aiResult = await AiNavigationService.transformRoute(
      originName: origin.name,
      destinationName: destination.name,
      rawSteps: rawSteps,
      totalMinutes: durationMinutes,
    );

    final polylinePoints = _decodePolyline(route['geometry'] ?? '');

    final routeSteps = aiResult.steps.map((aiStep) {
      return RouteStepEntity(
        instruction: aiStep.friendly,
        htmlInstruction: aiStep.original,
        distanceMeters: 250,
        durationSeconds: 150,
        startLocation: LatLngEntity(origin.latitude, origin.longitude),
        endLocation: LatLngEntity(destination.latitude, destination.longitude),
        maneuver: aiStep.type,
        landmark: aiStep.emoji,
      );
    }).toList();

    final legEntity = RouteLegEntity(
      type: LegType.walking,
      instruction: aiResult.summary,
      rawInstruction: 'Direct Route',
      distanceMeters: (route['distance'] as num).toDouble(),
      durationMinutes: durationMinutes,
      startLocation: LatLngEntity(origin.latitude, origin.longitude),
      endLocation: LatLngEntity(destination.latitude, destination.longitude),
      steps: routeSteps,
    );

    return [
      RouteEntity(
        id: 'route_osrm_fastest',
        type: RouteType.fastest,
        origin: origin,
        destination: destination,
        durationMinutes: durationMinutes,
        distanceMeters: (route['distance'] as num).toDouble(),
        walkingDistanceMeters: 300,
        estimatedCost: 0,
        transferCount: 0,
        arrivalTime: '${durationMinutes}m',
        legs: [legEntity],
        polylinePoints: polylinePoints,
      ),
      RouteEntity(
        id: 'route_osrm_transit',
        type: RouteType.transit,
        origin: origin,
        destination: destination,
        durationMinutes: (durationMinutes * 1.2).round(),
        distanceMeters: (route['distance'] as num).toDouble(),
        walkingDistanceMeters: 200,
        estimatedCost: 15,
        transferCount: 1,
        arrivalTime: '${(durationMinutes * 1.2).round()}m',
        legs: [legEntity],
        polylinePoints: polylinePoints,
      ),
    ];
  }

  RouteType _assignRouteType(int index) {
    switch (index) {
      case 0: return RouteType.fastest;
      case 1: return RouteType.cheapest;
      case 2: return RouteType.leastWalking;
      default: return RouteType.transit;
    }
  }

  List<RouteEntity> _generateCalculatedMockRoutes(
    PlaceEntity origin,
    PlaceEntity destination,
  ) {
    final polyline = [
      LatLngEntity(origin.latitude, origin.longitude),
      LatLngEntity(
        (origin.latitude + destination.latitude) / 2 + 0.002,
        (origin.longitude + destination.longitude) / 2 - 0.002,
      ),
      LatLngEntity(destination.latitude, destination.longitude),
    ];

    final mockSteps = [
      RouteStepEntity(
        instruction: 'Walk straight from ${origin.name} toward the main road.',
        htmlInstruction: 'Head toward Main St',
        distanceMeters: 300,
        durationSeconds: 240,
        startLocation: LatLngEntity(origin.latitude, origin.longitude),
        endLocation: LatLngEntity(origin.latitude + 0.001, origin.longitude + 0.001),
        maneuver: 'straight',
        landmark: 'landmark on your left',
      ),
      RouteStepEntity(
        instruction: 'Continue toward ${destination.name}. Your destination will be on the right.',
        htmlInstruction: 'Arrive at ${destination.name}',
        distanceMeters: 1200,
        durationSeconds: 900,
        startLocation: LatLngEntity(origin.latitude + 0.001, origin.longitude + 0.001),
        endLocation: LatLngEntity(destination.latitude, destination.longitude),
        maneuver: 'arrive',
        landmark: destination.name,
      ),
    ];

    final leg = RouteLegEntity(
      type: LegType.walking,
      instruction: 'Head from ${origin.name} to ${destination.name}',
      rawInstruction: 'Direct Route',
      distanceMeters: 1500,
      durationMinutes: 19,
      startLocation: LatLngEntity(origin.latitude, origin.longitude),
      endLocation: LatLngEntity(destination.latitude, destination.longitude),
      steps: mockSteps,
    );

    return [
      RouteEntity(
        id: 'route_mock_fastest',
        type: RouteType.fastest,
        origin: origin,
        destination: destination,
        durationMinutes: 19,
        distanceMeters: 1500,
        walkingDistanceMeters: 400,
        estimatedCost: 15,
        transferCount: 0,
        arrivalTime: '19m away',
        legs: [leg],
        polylinePoints: polyline,
      ),
      RouteEntity(
        id: 'route_mock_transit',
        type: RouteType.transit,
        origin: origin,
        destination: destination,
        durationMinutes: 25,
        distanceMeters: 1800,
        walkingDistanceMeters: 150,
        estimatedCost: 10,
        transferCount: 1,
        arrivalTime: '25m away',
        legs: [leg],
        polylinePoints: polyline,
      ),
    ];
  }

  List<LatLngEntity> _decodePolyline(String encoded) {
    if (encoded.isEmpty) return [];
    List<LatLngEntity> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLngEntity(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
}
