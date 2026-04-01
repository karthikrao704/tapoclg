import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/secondary_app_bar.dart';
import '../bloc/personal_info/personal_info_bloc.dart';
import '../bloc/personal_info/personal_info_event.dart';
import '../bloc/personal_info/personal_info_state.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PersonalInfoBloc()..add(LoadPersonalInfo()),
      child: const PersonalInfoView(),
    );
  }
}

class PersonalInfoView extends StatefulWidget {
  const PersonalInfoView({super.key});

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  // Controllers for editable fields
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late final TextEditingController _genderController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _healthConcernsController;
  late final TextEditingController _preferredTherapiesController;
  late final TextEditingController _allergiesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _countryController = TextEditingController();
    _cityController = TextEditingController();
    _addressController = TextEditingController();
    _healthConcernsController = TextEditingController();
    _preferredTherapiesController = TextEditingController();
    _allergiesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _healthConcernsController.dispose();
    _preferredTherapiesController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _updateControllers(PersonalInfoState state) {
    if (_nameController.text != state.fullName)
      _nameController.text = state.fullName;
    if (_emailController.text != state.email)
      _emailController.text = state.email;
    if (_phoneController.text != state.phone)
      _phoneController.text = state.phone;
    if (_dobController.text != state.dateOfBirth) {
      if (state.dateOfBirth.isNotEmpty) {
        try {
          final datePart = state.dateOfBirth.split('T').first;
          final parts = datePart.split('-');
          if (parts.length >= 3) {
            final y = parts[0];
            final m = parts[1];
            final d = parts[2];
            _dobController.text = '$d/$m/$y';
          } else {
            _dobController.text = state.dateOfBirth;
          }
        } catch (_) {
          _dobController.text = state.dateOfBirth;
        }
      } else {
        _dobController.text = state.dateOfBirth;
      }
    }
    if (_genderController.text != state.gender)
      _genderController.text = state.gender;
    if (_countryController.text != state.country)
      _countryController.text = state.country;
    if (_cityController.text != state.city) _cityController.text = state.city;
    if (_addressController.text != state.streetAddress)
      _addressController.text = state.streetAddress;
    if (_healthConcernsController.text != state.healthConcerns)
      _healthConcernsController.text = state.healthConcerns;
    if (_preferredTherapiesController.text != state.preferredTherapies)
      _preferredTherapiesController.text = state.preferredTherapies;
    if (_allergiesController.text != state.allergies)
      _allergiesController.text = state.allergies;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Establish breakpoint
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650;
    final hPadding = size.width * 0.05;

    return BlocListener<PersonalInfoBloc, PersonalInfoState>(
      listenWhen: (previous, current) =>
          previous.error != current.error ||
          previous.successMessage != current.successMessage ||
          (previous.isLoading && !current.isLoading),
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
          context.read<PersonalInfoBloc>().add(ClearStatusMessages());
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          context.read<PersonalInfoBloc>().add(ClearStatusMessages());
        }
        if (!state.isLoading) {
          _updateControllers(state);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: SecondaryAppBar(
          title: 'Personal Information',
          centerTitle: false,
          titleSpacing: 0,
          showSearch: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
          ),
        ),
        body: BlocBuilder<PersonalInfoBloc, PersonalInfoState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFCDA751)),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPadding,
                        vertical: isSmallScreen ? 16 : 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            Icons.person_outline,
                            'Basic Details',
                            isSmallScreen,
                          ),
                          _buildEditableField(
                            'FULL NAME',
                            _nameController,
                            isSmallScreen,
                            hintText: 'Enter Name',
                          ),
                          _buildEditableField(
                            'EMAIL ADDRESS',
                            _emailController,
                            isSmallScreen,
                            hintText: 'Enter Email address',
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                          ),
                          _buildEditableField(
                            'PHONE NUMBER',
                            _phoneController,
                            isSmallScreen,
                            hintText: 'Enter Phone number',
                            keyboardType: TextInputType.phone,
                          ),
                          _buildDatePickerField(
                            'DATE OF BIRTH',
                            _dobController,
                            isSmallScreen,
                            hintText: 'Select Date of Birth',
                          ),
                          _buildEditableField(
                            'GENDER',
                            _genderController,
                            isSmallScreen,
                            hintText: 'Enter Gender',
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 32),

                          _buildSectionHeader(
                            Icons.place_outlined,
                            'Address Information',
                            isSmallScreen,
                          ),
                          _buildEditableField(
                            'COUNTRY',
                            _countryController,
                            isSmallScreen,
                            hintText: 'Enter Country',
                          ),
                          _buildEditableField(
                            'CITY',
                            _cityController,
                            isSmallScreen,
                            hintText: 'Enter City',
                          ),
                          _buildEditableField(
                            'STREET ADDRESS',
                            _addressController,
                            isSmallScreen,
                            hintText: 'Enter Street address',
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 32),

                          _buildSectionHeader(
                            Icons.spa,
                            'Wellness Profile',
                            isSmallScreen,
                          ),
                          _buildWellnessEditableField(
                            Icons.healing,
                            'HEALTH CONCERNS',
                            _healthConcernsController,
                            isSmallScreen,
                            hintText: 'Enter Health concerns',
                          ),
                          _buildWellnessEditableField(
                            Icons.self_improvement,
                            'PREFERRED THERAPIES',
                            _preferredTherapiesController,
                            isSmallScreen,
                            hintText: 'Enter Preferred therapies',
                          ),
                          _buildWellnessEditableField(
                            Icons.warning_amber_rounded,
                            'ALLERGIES',
                            _allergiesController,
                            isSmallScreen,
                            hintText: 'Enter Allergies',
                          ),

                          SizedBox(height: isSmallScreen ? 8 : 16),
                        ],
                      ),
                    ),
                  ),
                ),
                // 2. Extracted bottom action buttons to sit flush at the bottom of the screen
                _buildBottomActionButtons(context, state, isSmallScreen),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryColor,
            size: isSmallScreen ? 20 : 24,
          ),
          const SizedBox(width: 8),
          // 1. Wrap the Text in Expanded to bound its maximum width
          Expanded(
            child: Text(
              title,
              // 2. Add truncation rules for safety
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.poppinsSemiBold(
                color: AppTheme.primaryText,
                fontSize: isSmallScreen ? 15 : 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isSmallScreen, {
    String hintText = 'Enter value',
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.poppinsSemiBold(
              color: AppColors.primaryColor,
              fontSize: isSmallScreen ? 10 : 11,
              letterSpacing: 0.5,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            style: AppFonts.poppinsMedium(
              color: readOnly ? AppColors.primaryBlack40 : AppTheme.primaryText,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 6, bottom: 4),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: AppFonts.poppinsRegular(
                color: const Color(0xFFB0BEC5),
                fontSize: isSmallScreen ? 13 : 15,
              ),
              suffixIcon: readOnly
                  ? Icon(
                      Icons.lock_outline,
                      size: isSmallScreen ? 14 : 16,
                      color: const Color(0xFFCBD5E1),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    DateTime initialDate = DateTime(2000, 1, 1);
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      } catch (_) {
        try {
          initialDate = DateTime.parse(_dobController.text);
        } catch (_) {}
      }
    }

    final int? selectedYear = await _showYearPicker(initialDate.year);
    if (selectedYear == null) return;

    final int? selectedMonth = await _showMonthPicker(initialDate.month);
    if (selectedMonth == null) return;

    final int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    final int initialDay =
        (initialDate.year == selectedYear && initialDate.month == selectedMonth)
        ? initialDate.day.clamp(1, daysInMonth)
        : 1;

    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear, selectedMonth, initialDay),
      firstDate: DateTime(selectedYear, selectedMonth, 1),
      lastDate:
          DateTime(
            selectedYear,
            selectedMonth,
            daysInMonth,
          ).isAfter(DateTime.now())
          ? DateTime.now()
          : DateTime(selectedYear, selectedMonth, daysInMonth),
      helpText: 'Select day',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCDA751),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<int?> _showYearPicker(int initialYear) async {
    final now = DateTime.now();
    int selectedYear = initialYear;
    // 3. Dynamic Dialog bounds
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return showDialog<int>(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCDA751),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: AlertDialog(
            title: Text(
              'Select Year',
              style: AppFonts.poppinsSemiBold(fontSize: 18),
            ),
            content: SizedBox(
              // Erased hardcoded 300x300 constraint
              width: screenWidth * 0.8,
              height: screenHeight * 0.4,
              child: YearPicker(
                firstDate: DateTime(1920),
                lastDate: now,
                selectedDate: DateTime(selectedYear),
                onChanged: (DateTime dateTime) {
                  Navigator.of(context).pop(dateTime.year);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFFCDA751)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int?> _showMonthPicker(int initialMonth) async {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final screenWidth = MediaQuery.sizeOf(context).width;

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Month',
            style: AppFonts.poppinsSemiBold(fontSize: 18),
          ),
          content: SizedBox(
            // Erased hardcoded 300 bounds
            width: screenWidth * 0.9,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio:
                    2.0, // Tweaked aspect ratio slightly for better small screen fit
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final isSelected = index + 1 == initialMonth;
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(index + 1),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFCDA751)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      months[index].substring(0, 3),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFCDA751)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDatePickerField(
    String label,
    TextEditingController controller,
    bool isSmallScreen, {
    String hintText = 'Select date',
  }) {
    return GestureDetector(
      onTap: _pickDateOfBirth,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFonts.poppinsSemiBold(
                color: AppColors.primaryColor,
                fontSize: isSmallScreen ? 10 : 11,
                letterSpacing: 0.5,
              ),
            ),
            TextField(
              controller: controller,
              readOnly: true,
              enabled: false,
              style: AppFonts.poppinsMedium(
                color: AppTheme.primaryText,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(top: 6, bottom: 4),
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: AppFonts.poppinsRegular(
                  color: const Color(0xFFB0BEC5),
                  fontSize: isSmallScreen ? 13 : 15,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: isSmallScreen ? 16 : 18,
                  color: AppColors.primaryColor,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessEditableField(
    IconData icon,
    String label,
    TextEditingController controller,
    bool isSmallScreen, {
    String hintText = 'Enter value',
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF2E6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFCDA751),
              size: isSmallScreen ? 16 : 20,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.poppinsSemiBold(
                    color: AppColors.primaryColor,
                    fontSize: isSmallScreen ? 10 : 11,
                    letterSpacing: 0.5,
                  ),
                ),
                TextField(
                  controller: controller,
                  maxLines: null,
                  style: AppFonts.poppinsMedium(
                    color: AppTheme.primaryText,
                    fontSize: isSmallScreen ? 13 : 15,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 6, bottom: 4),
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: AppFonts.poppinsRegular(
                      color: const Color(0xFFB0BEC5),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(
    BuildContext context,
    PersonalInfoState state,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFBFAF8),
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
      ),
      child: SafeArea(
        top: false, // Only apply safe area logic to the bottom of the screen
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: state.isSaving
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  side: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppFonts.poppinsSemiBold(
                    color: AppColors.primaryColor,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: state.isSaving
                    ? null
                    : () {
                        context.read<PersonalInfoBloc>().add(
                          SavePersonalInfo(
                            fullName: _nameController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            dateOfBirth: _dobController.text,
                            gender: _genderController.text,
                            country: _countryController.text,
                            city: _cityController.text,
                            streetAddress: _addressController.text,
                            healthConcerns: _healthConcernsController.text,
                            preferredTherapies:
                                _preferredTherapiesController.text,
                            allergies: _allergiesController.text,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: state.isSaving
                    ? SizedBox(
                        height: isSmallScreen ? 16 : 20,
                        width: isSmallScreen ? 16 : 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Center(
                        child: Text(
                          'Save Changes',
                          style: AppFonts.poppinsSemiBold(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
