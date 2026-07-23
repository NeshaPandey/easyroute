import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/user_repository.dart';

// ─── Serialization Extensions ───────────────────────────────────────────────

extension PlaceEntityExtension on PlaceEntity {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeType': placeType,
      'iconUrl': iconUrl,
    };
  }

  static PlaceEntity fromMap(Map<String, dynamic> map) {
    return PlaceEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      placeType: map['placeType'],
      iconUrl: map['iconUrl'],
    );
  }
}

extension UserPreferencesExtension on UserPreferences {
  Map<String, dynamic> toMap() {
    return {
      'highContrastMode': highContrastMode,
      'voiceGuidanceEnabled': voiceGuidanceEnabled,
      'vibrationEnabled': vibrationEnabled,
      'textScale': textScale,
      'preferredTransport': preferredTransport,
      'avoidTolls': avoidTolls,
      'avoidHighways': avoidHighways,
    };
  }

  static UserPreferences fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      highContrastMode: map['highContrastMode'] ?? false,
      voiceGuidanceEnabled: map['voiceGuidanceEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      textScale: (map['textScale'] as num?)?.toDouble() ?? 1.0,
      preferredTransport: map['preferredTransport'] ?? 'TRANSIT',
      avoidTolls: map['avoidTolls'] ?? false,
      avoidHighways: map['avoidHighways'] ?? false,
    );
  }
}

extension UserEntityExtension on UserEntity {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'favorites': favorites.map((e) => e.toMap()).toList(),
      'recentSearches': recentSearches.map((e) => e.toMap()).toList(),
      'preferences': preferences.toMap(),
    };
  }

  static UserEntity fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      favorites: (map['favorites'] as List?)
              ?.map((e) => PlaceEntityExtension.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      recentSearches: (map['recentSearches'] as List?)
              ?.map((e) => PlaceEntityExtension.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      preferences: map['preferences'] != null
          ? UserPreferencesExtension.fromMap(Map<String, dynamic>.from(map['preferences']))
          : const UserPreferences(),
    );
  }
}

// ─── Demo User Repository Implementation ──────────────────────────────────────

class DemoUserRepository implements UserRepository {
  final Map<String, UserEntity> _users = {};

  @override
  Future<UserEntity> getUser(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_users.containsKey(uid)) {
      _users[uid] = UserEntity(
        id: uid,
        email: 'user@gmail.com',
        displayName: 'EasyRoute User',
        preferences: const UserPreferences(),
      );
    }
    return _users[uid]!;
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users[user.id] = user;
  }

  @override
  Future<void> updatePreferences(String uid, UserPreferences preferences) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = await getUser(uid);
    _users[uid] = UserEntity(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      favorites: user.favorites,
      recentSearches: user.recentSearches,
      preferences: preferences,
    );
  }

  @override
  Future<void> addFavorite(String uid, PlaceEntity place) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = await getUser(uid);
    if (!user.favorites.contains(place)) {
      final updatedFavorites = List<PlaceEntity>.from(user.favorites)..add(place);
      _users[uid] = UserEntity(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        favorites: updatedFavorites,
        recentSearches: user.recentSearches,
        preferences: user.preferences,
      );
    }
  }

  @override
  Future<void> removeFavorite(String uid, String placeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = await getUser(uid);
    final updatedFavorites = user.favorites.where((element) => element.id != placeId).toList();
    _users[uid] = UserEntity(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      favorites: updatedFavorites,
      recentSearches: user.recentSearches,
      preferences: user.preferences,
    );
  }

  @override
  Future<void> addRecentSearch(String uid, PlaceEntity place) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = await getUser(uid);
    final updatedRecent = List<PlaceEntity>.from(user.recentSearches)
      ..removeWhere((e) => e.id == place.id)
      ..insert(0, place);
    if (updatedRecent.length > 5) {
      updatedRecent.removeLast();
    }
    _users[uid] = UserEntity(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      favorites: user.favorites,
      recentSearches: updatedRecent,
      preferences: user.preferences,
    );
  }
}

// ─── Firestore User Repository Implementation ──────────────────────────────────

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<UserEntity> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found in Firestore.');
    }
    return UserEntityExtension.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    await _usersCollection.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updatePreferences(String uid, UserPreferences preferences) async {
    await _usersCollection.doc(uid).update({
      'preferences': preferences.toMap(),
    });
  }

  @override
  Future<void> addFavorite(String uid, PlaceEntity place) async {
    await _usersCollection.doc(uid).update({
      'favorites': FieldValue.arrayUnion([place.toMap()]),
    });
  }

  @override
  Future<void> removeFavorite(String uid, String placeId) async {
    final user = await getUser(uid);
    final updatedFavorites = user.favorites.where((element) => element.id != placeId).map((e) => e.toMap()).toList();
    await _usersCollection.doc(uid).update({
      'favorites': updatedFavorites,
    });
  }

  @override
  Future<void> addRecentSearch(String uid, PlaceEntity place) async {
    final user = await getUser(uid);
    final updatedRecent = List<PlaceEntity>.from(user.recentSearches)
      ..removeWhere((e) => e.id == place.id)
      ..insert(0, place);
    if (updatedRecent.length > 5) {
      updatedRecent.removeLast();
    }
    await _usersCollection.doc(uid).update({
      'recentSearches': updatedRecent.map((e) => e.toMap()).toList(),
    });
  }
}
