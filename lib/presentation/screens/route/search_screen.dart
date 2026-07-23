import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _destCtrl = TextEditingController();
  final _destFocus = FocusNode();
  bool _isSearching = false;
  List<PlaceEntity> _suggestions = [];

  // Demo suggestions
  final _allPlaces = [
    const PlaceEntity(id: 'p1', name: 'MG Road Metro Station',
        address: 'MG Road, Bengaluru', latitude: 12.9758, longitude: 77.6060),
    const PlaceEntity(id: 'p2', name: 'Lalbagh Botanical Garden',
        address: 'Lalbagh, Bengaluru', latitude: 12.9507, longitude: 77.5848),
    const PlaceEntity(id: 'p3', name: 'Bengaluru City Railway Station',
        address: 'Majestic, Bengaluru', latitude: 12.9767, longitude: 77.5713),
    const PlaceEntity(id: 'p4', name: 'Cubbon Park',
        address: 'Cubbon Park, Bengaluru', latitude: 12.9763, longitude: 77.5929),
    const PlaceEntity(id: 'p5', name: 'Indiranagar',
        address: 'Indiranagar, Bengaluru', latitude: 12.9784, longitude: 77.6408),
    const PlaceEntity(id: 'p6', name: 'Koramangala',
        address: 'Koramangala, Bengaluru', latitude: 12.9352, longitude: 77.6245),
    const PlaceEntity(id: 'p7', name: 'Whitefield',
        address: 'Whitefield, Bengaluru', latitude: 12.9698, longitude: 77.7500),
    const PlaceEntity(id: 'p8', name: 'Electronic City',
        address: 'Electronic City, Bengaluru', latitude: 12.8399, longitude: 77.6770),
    const PlaceEntity(id: 'p9', name: 'Nearest Hospital',
        address: 'St. Martha\'s Hospital, Bengaluru', latitude: 12.9763, longitude: 77.5929),
    const PlaceEntity(id: 'p10', name: 'Nearest Metro Station',
        address: 'MG Road Metro, Bengaluru', latitude: 12.9758, longitude: 77.6060),
  ];

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() { _suggestions = []; _isSearching = false; });
      return;
    }
    setState(() {
      _isSearching = true;
      _suggestions = _allPlaces
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectDestination(PlaceEntity dest) {
    context.push(RouteNames.routeSelection, extra: {'destination': dest});
  }

  @override
  void initState() {
    super.initState();
    _destFocus.requestFocus();
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search destination'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _destCtrl,
              focusNode: _destFocus,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search any place or say "hospital near me"',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _destCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _destCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Quick suggestions row
          if (!_isSearching) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text('Quick searches',
                      style: AppTypography.labelLarge
                          .copyWith(color: AppColors.onSurfaceMuted)),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: ['Hospital', 'Metro station', 'ATM', 'Pharmacy', 'Bus stop']
                    .map((q) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(q),
                            onPressed: () {
                              _destCtrl.text = q;
                              _onSearchChanged(q);
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
            const Divider(),
          ],

          // Results
          Expanded(
            child: _suggestions.isEmpty && _isSearching
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48, color: AppColors.onSurfaceLight),
                        const SizedBox(height: 12),
                        Text('No places found',
                            style: AppTypography.bodyLarge
                                .copyWith(color: AppColors.onSurfaceMuted)),
                        const SizedBox(height: 4),
                        Text('Try a different search term',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.onSurfaceLight)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _suggestions.isEmpty
                        ? _allPlaces.length
                        : _suggestions.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, i) {
                      final place = _suggestions.isEmpty
                          ? _allPlaces[i]
                          : _suggestions[i];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_outlined,
                              color: AppColors.primary, size: 20),
                        ),
                        title: Text(place.name,
                            style: AppTypography.titleLarge),
                        subtitle: Text(place.address,
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.onSurfaceMuted)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.onSurfaceLight),
                        onTap: () => _selectDestination(place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
