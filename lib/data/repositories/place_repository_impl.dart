import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/place_repository.dart';

/// Implementation of PlaceRepository that supports Google Places API,
/// OpenStreetMap Nominatim fallback, and offline demo fallback.
class HybridPlaceRepositoryImpl implements PlaceRepository {
  final String? googleApiKey;
  final http.Client _client;

  HybridPlaceRepositoryImpl({
    this.googleApiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  static const List<PlaceEntity> _fallbackPlaces = [
    PlaceEntity(
      id: 'p1',
      name: 'MG Road Metro Station',
      address: 'MG Road, Bengaluru',
      latitude: 12.9758,
      longitude: 77.6060,
    ),
    PlaceEntity(
      id: 'p2',
      name: 'Lalbagh Botanical Garden',
      address: 'Lalbagh, Bengaluru',
      latitude: 12.9507,
      longitude: 77.5848,
    ),
    PlaceEntity(
      id: 'p3',
      name: 'Bengaluru City Railway Station',
      address: 'Majestic, Bengaluru',
      latitude: 12.9767,
      longitude: 77.5713,
    ),
    PlaceEntity(
      id: 'p4',
      name: 'Cubbon Park',
      address: 'Cubbon Park, Bengaluru',
      latitude: 12.9763,
      longitude: 77.5929,
    ),
    PlaceEntity(
      id: 'p5',
      name: 'Indiranagar',
      address: 'Indiranagar, Bengaluru',
      latitude: 12.9784,
      longitude: 77.6408,
    ),
    PlaceEntity(
      id: 'p6',
      name: 'Koramangala',
      address: 'Koramangala, Bengaluru',
      latitude: 12.9352,
      longitude: 77.6245,
    ),
  ];

  @override
  Future<List<PlaceEntity>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    // 1. Try Google Places if API Key is configured
    if (googleApiKey != null && googleApiKey!.isNotEmpty && !googleApiKey!.contains('mock')) {
      try {
        final googleResults = await _searchGooglePlaces(query);
        if (googleResults.isNotEmpty) return googleResults;
      } catch (_) {
        // Fallback to Nominatim
      }
    }

    // 2. Try OpenStreetMap Nominatim (Free, no key required)
    try {
      final nominatimResults = await _searchNominatim(query);
      if (nominatimResults.isNotEmpty) return nominatimResults;
    } catch (_) {
      // Fallback to offline matching
    }

    // 3. Fallback to matching offline demo places
    return _fallbackPlaces
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<PlaceEntity>> _searchGooglePlaces(String query) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$googleApiKey',
    );
    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        return results.map((item) {
          final location = item['geometry']['location'];
          return PlaceEntity(
            id: item['place_id'] as String? ?? '',
            name: item['name'] as String? ?? '',
            address: item['formatted_address'] as String? ?? '',
            latitude: (location['lat'] as num).toDouble(),
            longitude: (location['lng'] as num).toDouble(),
            placeType: (item['types'] as List?)?.firstOrNull?.toString(),
          );
        }).toList();
      }
    }
    return [];
  }

  Future<List<PlaceEntity>> _searchNominatim(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=8',
    );
    final response = await _client.get(
      url,
      headers: {'User-Agent': 'EasyRouteFlutterApp/1.0'},
    );

    if (response.statusCode == 200) {
      final results = jsonDecode(response.body) as List;
      return results.map((item) {
        final displayName = item['display_name'] as String? ?? '';
        final nameParts = displayName.split(',');
        final title = nameParts.first.trim();
        final address = nameParts.skip(1).join(',').trim();

        return PlaceEntity(
          id: item['place_id']?.toString() ?? UniqueKey().toString(),
          name: title.isNotEmpty ? title : displayName,
          address: address.isNotEmpty ? address : displayName,
          latitude: double.parse(item['lat'].toString()),
          longitude: double.parse(item['lon'].toString()),
          placeType: item['type']?.toString(),
        );
      }).toList();
    }
    return [];
  }

  @override
  Future<PlaceEntity?> getPlaceFromCoordinates(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json',
      );
      final response = await _client.get(
        url,
        headers: {'User-Agent': 'EasyRouteFlutterApp/1.0'},
      );
      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);
        final displayName = item['display_name'] as String? ?? 'Current Location';
        final nameParts = displayName.split(',');

        return PlaceEntity(
          id: item['place_id']?.toString() ?? 'current_loc',
          name: nameParts.first.trim(),
          address: displayName,
          latitude: lat,
          longitude: lng,
        );
      }
    } catch (_) {}

    return PlaceEntity(
      id: 'current_loc',
      name: 'Current Location',
      address: 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}',
      latitude: lat,
      longitude: lng,
    );
  }
}
