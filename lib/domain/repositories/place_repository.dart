import '../entities/route_entity.dart';

abstract class PlaceRepository {
  Future<List<PlaceEntity>> searchPlaces(String query);
  Future<PlaceEntity?> getPlaceFromCoordinates(double lat, double lng);
}
