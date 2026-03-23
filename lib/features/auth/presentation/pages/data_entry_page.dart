import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/service/mapbox_UI.dart';
import 'package:tapovana_mobile_app/core/service/mapbox_initiate.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/data_entry/data_entry_bloc.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/data_entry/data_entry_event.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/data_entry/data_entry_state.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'package:tapovana_mobile_app/features/auth/domain/entities/app_user.dart';

class DataEntryPage extends StatefulWidget {
  final String email;
  final String password;
  final String authMethod;
  final AppUser? googleUser;
  final String? firebaseUid;

  const DataEntryPage({
    super.key,
    required this.email,
    required this.password,
    this.authMethod = 'email',
    this.googleUser,
    this.firebaseUid,
  });

  @override
  State<DataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  String selectedGender = "Female";
  final nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _cityFocus = FocusNode();
  List<MapboxPlace> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  MapboxPlace? _selectedPlace;

  @override
  void initState() {
    super.initState();
    if (widget.googleUser?.name != null &&
        widget.googleUser!.name!.isNotEmpty) {
      nameController.text = widget.googleUser!.name!;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
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
    if (_selectedPlace != null && query == _selectedPlace!.displayName) return;
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
    if (place != null && mounted) _onPlaceSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataEntryBloc(AuthApiRepository()),
      child: BlocListener<DataEntryBloc, DataEntryState>(
        listener: (context, state) {
          if (state is DataEntrySuccess) {
            if (widget.authMethod == 'google') {
              // Google signup complete → call AuthCubit
              context.read<AuthCubit>().completeGoogleSignup(
                email: widget.email,
                firebaseUid: widget.firebaseUid!,
                name: nameController.text.trim(),
                gender: selectedGender,
                city: _cityController.text.trim(),
              );
            } else {
              // Email signup complete
              context.read<AuthCubit>().onSignupComplete(
                state.loginData,
                'email',
              );
            }
          }
          if (state is DataEntryFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
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
                    Container(
                      height: 8,
                      width: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A14A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 35),
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

                    // Privacy Card
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

                    // Google badge
                    if (widget.authMethod == 'google') ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            if (widget.googleUser?.photoUrl != null) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  widget.googleUser!.photoUrl!,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ] else ...[
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                "Signed in with Google as ${widget.email}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Name
                    const Text(
                      "Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
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

                    // Gender
                    const Text(
                      "Gender",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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

                    // City
                    const Text(
                      "CITY OR ZIP CODE",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    MapboxSearchResultsDropdown(
                      results: _searchResults,
                      isLoading: _isSearching,
                      onSelected: _onPlaceSelected,
                    ),
                    const SizedBox(height: 25),
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

                    // Continue Button
                    BlocBuilder<DataEntryBloc, DataEntryState>(
                      builder: (context, state) {
                        final isLoading = state is DataEntryLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final name = nameController.text.trim();
                                    final city = _cityController.text.trim();

                                    if (name.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please enter your name",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (city.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please enter your city",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (widget.authMethod == 'google') {
                                      // Google: call AuthCubit directly
                                      context
                                          .read<AuthCubit>()
                                          .completeGoogleSignup(
                                            email: widget.email,
                                            firebaseUid: widget.firebaseUid!,
                                            name: name,
                                            gender: selectedGender,
                                            city: city,
                                          );
                                    } else {
                                      // Email: use DataEntryBloc
                                      context.read<DataEntryBloc>().add(
                                        SubmitDataEntry(
                                          email: widget.email,
                                          password: widget.password,
                                          name: name,
                                          gender: selectedGender,
                                          city: city,
                                          authMethod: 'email',
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9A14A),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Continue →",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
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
