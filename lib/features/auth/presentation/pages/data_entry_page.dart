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
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

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
    // 1. Fetch screen dimensions and set breakpoint
    final size = MediaQuery.sizeOf(context);
    final bool isSmallScreen = size.height < 650;

    return BlocProvider(
      create: (context) => DataEntryBloc(AuthApiRepository()),
      child: BlocListener<DataEntryBloc, DataEntryState>(
        listener: (context, state) {
          if (state is DataEntrySuccess) {
            if (widget.authMethod == 'google') {
              context.read<AuthCubit>().completeGoogleSignup(
                email: widget.email,
                firebaseUid: widget.firebaseUid!,
                name: nameController.text.trim(),
                gender: selectedGender,
                city: _cityController.text.trim(),
              );
            } else {
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                // 2. Relative horizontal padding matching previous screens
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? 15 : 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "STEP 1 OF 4",
                          style: AppFonts.poppinsSemiBold(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        Text(
                          "25%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color.fromARGB(255, 67, 72, 80),
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
                    SizedBox(height: isSmallScreen ? 20 : 35),
                    Text(
                      "Tell us about yourself",
                      style: AppFonts.headland(
                        fontSize: isSmallScreen ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We use this information to personalize your "
                      "wellness journey at Topovan Life Space.",
                      style: AppFonts.poppinsRegular(
                        fontSize: isSmallScreen ? 14 : 16.5,
                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),

                    // Privacy Card
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Privacy first",
                                  style: AppFonts.poppinsSemiBold(
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Your data is encrypted and never "
                                  "shared with third parties.",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 13,
                                    color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 10 : 15),

                    // Google badge
                    if (widget.authMethod == 'google') ...[
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            if (widget.googleUser?.photoUrl != null) ...[
                              CircleAvatar(
                                radius: isSmallScreen ? 14 : 16,
                                backgroundImage: NetworkImage(
                                  widget.googleUser!.photoUrl!,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ] else ...[
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                "Signed in with Google as ${widget.email}",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 13,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 15),
                    ],

                    // Name
                    Text(
                      "Name",
                      style: AppFonts.poppinsSemiBold(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: "e.g. Elena Vance",
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFFC9A14A),
                            width: 1,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFFC9A14A),
                            width: 1,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 20 : 28),

                    // Gender
                    Text(
                      "Gender",
                      style: AppFonts.poppinsSemiBold(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _genderButton("Female", isSmallScreen),
                        _genderButton("Male", isSmallScreen),
                        _genderButton("Prefer not to say", isSmallScreen),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 20 : 30),

                    // City
                    Text(
                      "CITY OR ZIP CODE",
                      style: AppFonts.poppinsSemiBold(
                        fontSize: isSmallScreen ? 13.5 : 15.5,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _cityController,
                        focusNode: _cityFocus,
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF6B7280),
                          ),
                          hintText: "Search for your city...",
                          hintStyle: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    MapboxSearchResultsDropdown(
                      results: _searchResults,
                      isLoading: _isSearching,
                      onSelected: _onPlaceSelected,
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 25),
                    GestureDetector(
                      onTap: _useCurrentLocation,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: const Color.fromARGB(255, 184, 84, 31),
                            size: isSmallScreen ? 18 : 20,
                          ),
                          const SizedBox(width: 6),
                          // 1. Wrap the Text in Expanded to bound its maximum width
                          Expanded(
                            child: Text(
                              "Use Current Location",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 184, 84, 31),
                                fontWeight: FontWeight.w500,
                                fontSize: isSmallScreen ? 13 : 15,
                              ),
                              // 2. Define how the text should behave if it runs out of space
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Dynamically collapsed vast whitespace for small screens
                    SizedBox(height: isSmallScreen ? 40 : 105),

                    // Continue Button
                    BlocBuilder<DataEntryBloc, DataEntryState>(
                      builder: (context, state) {
                        final isLoading = state is DataEntryLoading;
                        return SizedBox(
                          width: double.infinity,
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
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.white,
                              elevation: 3,
                              // 4. Utilized minimumSize to prevent height clipping
                              minimumSize: Size(
                                double.infinity,
                                isSmallScreen ? 50 : 60,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: isSmallScreen ? 20 : 24,
                                    height: isSmallScreen ? 20 : 24,
                                    child: const CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    "Continue →",
                                    style: AppFonts.poppinsSemiBold(
                                      fontSize: isSmallScreen ? 16 : 18,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 5. Updated _genderButton to accept the responsive flag
  Widget _genderButton(String gender, bool isSmallScreen) {
    final isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC9A14A) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ),
    );
  }
}
