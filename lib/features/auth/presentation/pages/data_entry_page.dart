// lib/features/auth/pages/data_entry_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/core/service/mapbox_UI.dart';
import 'package:tapovana_mobile_app/core/service/mapbox_initiate.dart';

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  State<DataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  String selectedGender = "Female";

  final _cityController = TextEditingController();
  final _cityFocus = FocusNode();
  List<MapboxPlace> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  MapboxPlace? _selectedPlace;

  @override
  void dispose() {
    _cityController.dispose();
    _cityFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_selectedPlace != null && query != _selectedPlace!.displayName) {
      _selectedPlace = null;
    }

    _debounce?.cancel();

    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    if (_selectedPlace != null && query == _selectedPlace!.displayName) {
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await MapboxGeocodingService.searchPlaces(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _onPlaceSelected(MapboxPlace place) {
    setState(() {
      _selectedPlace = place;
      _cityController.text = place.displayName;
      _searchResults = [];
    });
    _cityFocus.unfocus();
  }

  Future<void> _useCurrentLocation() async {
    final place = await showMapboxLocationPicker(context);
    if (place != null && mounted) {
      _onPlaceSelected(place);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                /// STEP HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "STEP 1 OF 4",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      "25%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromARGB(255, 67, 72, 80),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// PROGRESS BAR
                Container(
                  height: 8,
                  width: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A14A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 35),

                /// TITLE
                const Text(
                  "Tell us about yourself",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "We use this information to personalize your "
                  "wellness journey at Topovan Life Space.",
                  style: TextStyle(
                    fontSize: 16.5,
                    color: Color.fromARGB(255, 71, 75, 84),
                  ),
                ),

                const SizedBox(height: 20),

                /// PRIVACY CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Privacy first",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Your data is encrypted and never "
                              "shared with third parties.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// NAME
                const Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),

                const SizedBox(height: 8),

                const TextField(
                  decoration: InputDecoration(
                    hintText: "e.g. Elena Vance",
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFC9A14A),
                        width: 0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// GENDER
                const Text(
                  "Gender",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _genderButton("Female"),
                    _genderButton("Male"),
                    _genderButton("Prefer not to say"),
                  ],
                ),

                const SizedBox(height: 30),

                /// CITY LABEL
                const Text(
                  "CITY OR ZIP CODE",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.5,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 8),

                /// CITY SEARCH FIELD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _cityController,
                    focusNode: _cityFocus,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Search for your city...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                /// SEARCH RESULTS
                MapboxSearchResultsDropdown(
                  results: _searchResults,
                  isLoading: _isSearching,
                  onSelected: _onPlaceSelected,
                ),

                const SizedBox(height: 25),

                /// USE CURRENT LOCATION
                GestureDetector(
                  onTap: _useCurrentLocation,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.my_location,
                        color: Color.fromARGB(255, 184, 84, 31),
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Use Current Location",
                        style: TextStyle(
                          color: Color.fromARGB(255, 184, 84, 31),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 105),

                /// CONTINUE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(RouteConstants.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A14A),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Continue →",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String gender) {
    final isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC9A14A) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
