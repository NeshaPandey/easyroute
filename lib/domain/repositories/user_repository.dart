import '../entities/route_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getUser(String uid);
  Future<void> saveUser(UserEntity user);
  Future<void> updatePreferences(String uid, UserPreferences preferences);
  Future<void> addFavorite(String uid, PlaceEntity place);
  Future<void> removeFavorite(String uid, String placeId);
  Future<void> addRecentSearch(String uid, PlaceEntity place);
}
