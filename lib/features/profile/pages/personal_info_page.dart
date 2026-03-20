import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Only update if text is different and not currently being edited by user to avoid cursor jumps
    if (_nameController.text != state.fullName) _nameController.text = state.fullName;
    if (_emailController.text != state.email) _emailController.text = state.email;
    if (_phoneController.text != state.phone) _phoneController.text = state.phone;
    if (_dobController.text != state.dateOfBirth) _dobController.text = state.dateOfBirth;
    if (_genderController.text != state.gender) _genderController.text = state.gender;
    if (_countryController.text != state.country) _countryController.text = state.country;
    if (_cityController.text != state.city) _cityController.text = state.city;
    if (_addressController.text != state.streetAddress) _addressController.text = state.streetAddress;
    if (_healthConcernsController.text != state.healthConcerns) _healthConcernsController.text = state.healthConcerns;
    if (_preferredTherapiesController.text != state.preferredTherapies) _preferredTherapiesController.text = state.preferredTherapies;
    if (_allergiesController.text != state.allergies) _allergiesController.text = state.allergies;
  }

  @override
  Widget build(BuildContext context) {
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
            SnackBar(content: Text(state.successMessage!), backgroundColor: const Color(0xFF4CAF50)),
          );
          context.read<PersonalInfoBloc>().add(ClearStatusMessages());
        }
        if (!state.isLoading) {
          _updateControllers(state);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: false,
          titleSpacing: 0,
          title: const Text(
            'Personal Information',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
          ),
        ),
        body: BlocBuilder<PersonalInfoBloc, PersonalInfoState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFCDA751)));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(Icons.person_outline, 'Basic Details'),
                        _buildEditableField('FULL NAME', _nameController, hintText: 'Enter Name'),
                        _buildEditableField('EMAIL ADDRESS', _emailController, hintText: 'Enter Email address', keyboardType: TextInputType.emailAddress),
                        _buildEditableField('PHONE NUMBER', _phoneController, hintText: 'Enter Phone number', keyboardType: TextInputType.phone),
                        _buildEditableField('DATE OF BIRTH', _dobController, hintText: 'Enter Date of Birth'),
                        _buildEditableField('GENDER', _genderController, hintText: 'Enter Gender'),

                        const SizedBox(height: 32),

                        _buildSectionHeader(Icons.place_outlined, 'Address Information'),
                        _buildEditableField('COUNTRY', _countryController, hintText: 'Enter Country'),
                        _buildEditableField('CITY', _cityController, hintText: 'Enter City'),
                        _buildEditableField('STREET ADDRESS', _addressController, hintText: 'Enter Street address'),

                        const SizedBox(height: 32),

                        _buildSectionHeader(Icons.spa, 'Wellness Profile'),
                        _buildWellnessEditableField(Icons.healing, 'HEALTH CONCERNS', _healthConcernsController, hintText: 'Enter Health concerns'),
                        _buildWellnessEditableField(Icons.self_improvement, 'PREFERRED THERAPIES', _preferredTherapiesController, hintText: 'Enter Preferred therapies'),
                        _buildWellnessEditableField(Icons.warning_amber_rounded, 'ALLERGIES', _allergiesController, hintText: 'Enter Allergies'),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  _buildBottomActionButtons(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFCDA751), size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {String hintText = 'Enter value', TextInputType keyboardType = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            style: const TextStyle(
              color: Color(0xFFCDA751),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 6, bottom: 4),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessEditableField(IconData icon, String label, TextEditingController controller, {String hintText = 'Enter value'}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Icon(icon, color: const Color(0xFFCDA751), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFCDA751),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                TextField(
                  controller: controller,
                  maxLines: null,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 6, bottom: 4),
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(BuildContext context, PersonalInfoState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF8),
        border: Border(
          top: BorderSide(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: state.isSaving ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFCDA751), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFFCDA751), fontSize: 16, fontWeight: FontWeight.w600),
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
                        context.read<PersonalInfoBloc>().add(SavePersonalInfo(
                              fullName: _nameController.text,
                              email: _emailController.text,
                              phone: _phoneController.text,
                              dateOfBirth: _dobController.text,
                              gender: _genderController.text,
                              country: _countryController.text,
                              city: _cityController.text,
                              streetAddress: _addressController.text,
                              healthConcerns: _healthConcernsController.text,
                              preferredTherapies: _preferredTherapiesController.text,
                              allergies: _allergiesController.text,
                            ));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCDA751),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: state.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}