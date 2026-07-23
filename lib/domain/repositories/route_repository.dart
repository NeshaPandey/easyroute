import '../entities/route_entity.dart';

abstract class RouteRepository {
  Future<List<RouteEntity>> fetchRoutes({
    required PlaceEntity origin,
    required PlaceEntity destination,
  });
}
