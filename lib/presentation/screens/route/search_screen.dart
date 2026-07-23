import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/route_entity.dart';
import '../../../domain/repositories/place_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _destCtrl = TextEditingController();
  final _destFocus = FocusNode();
  bool _isSearching = false;
  bool _isLoading = false;
  List<PlaceEntity> _suggestions = [];
  Timer? _debounceTimer;
  late final PlaceRepository _placeRepository;

  @override
  void initState() {
    super.initState();
    _placeRepository = GetIt.instance<PlaceRepository>();
    _destFocus.requestFocus();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _placeRepository.searchPlaces(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isLoading = false;
          });
        }
      }
    });
  }

  void _selectDestination(PlaceEntity dest) {
    context.push(RouteNames.routeSelection, extra: {'destination': dest});
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
                hintText: 'Search any place or address…',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_destCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _destCtrl.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null),
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
            child: _suggestions.isEmpty && _isSearching && !_isLoading
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
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, i) {
                      final place = _suggestions[i];
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
                                .copyWith(color: AppColors.onSurfaceMuted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
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
