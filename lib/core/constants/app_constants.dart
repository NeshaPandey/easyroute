// lib/core/constants/app_constants.dart

class AppConstants {
  // App Info
  static const appName = 'EasyRoute';
  static const appVersion = '1.0.0';

  // API Keys (replace with your own in .env)
  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY',
  );

  // Google Maps API Endpoints
  static const directionsBaseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';
  static const geocodeBaseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  // Default Map Settings
  static const defaultZoom = 15.0;
  static const navigationZoom = 18.0;
  static const overviewZoom = 12.0;

  // Route deviation threshold (in meters)
  static const deviationThreshold = 50.0;

  // Location update interval (milliseconds)
  static const locationUpdateInterval = 3000;

  // Cache
  static const recentSearchesKey = 'recent_searches';
  static const favoritesKey = 'favorites';
  static const userPrefsKey = 'user_prefs';
  static const cachedRoutesKey = 'cached_routes';
  static const maxRecentSearches = 10;
  static const maxCachedRoutes = 5;

  // Emergency
  static const emergencyContactsKey = 'emergency_contacts';
  static const maxEmergencyContacts = 3;
}

class RouteNames {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const search = '/search';
  static const routeSelection = '/route-selection';
  static const navigation = '/navigation';
  static const stepDetail = '/step-detail';
  static const profile = '/profile';
  static const favorites = '/favorites';
  static const emergency = '/emergency';
  static const settings = '/settings';
  static const highContrast = '/high-contrast';
}

class TransportMode {
  static const walking = 'WALKING';
  static const transit = 'TRANSIT';
  static const driving = 'DRIVING';
  static const bicycling = 'BICYCLING';
}

class TransitType {
  static const bus = 'BUS';
  static const subway = 'SUBWAY';
  static const tram = 'TRAM';
  static const rail = 'RAIL';
}
