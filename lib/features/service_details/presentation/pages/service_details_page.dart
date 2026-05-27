import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/no_internet_widget.dart';
import 'package:tapovana_mobile_app/features/appointments/presentation/pages/appointment_booking_page.dart';
import 'package:tapovana_mobile_app/features/service_details/presentation/widgets/benefit_item.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_detail_cubit.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_state.dart';
import 'package:tapovana_mobile_app/features/services/data/models/service_detail_model.dart';
import 'package:tapovana_mobile_app/features/services/data/repositories/service_repository.dart';

class ServiceDetailsPage extends StatelessWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceDetailCubit(repository: ServiceRepository())
        ..fetchServiceById(serviceId),
      child: _ServiceDetailsContent(serviceId: serviceId),
    );
  }
}

class _ServiceDetailsContent extends StatelessWidget {
  final String serviceId;
  const _ServiceDetailsContent({required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Service Details",
          style: AppFonts.headland(
            color: AppTheme.primaryText,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.share_outlined, color: AppTheme.primaryText),
          )
        ],
      ),
      body: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
        builder: (context, state) {
          if (state is ServiceDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.tealBlue,
              ),
            );
          }

          if (state is ServiceDetailError) {
            return NoInternetWidget(
              errorType: state.errorType,
              onReload: () =>
                  context.read<ServiceDetailCubit>().fetchServiceById(serviceId),
            );
          }

          if (state is ServiceDetailLoaded) {
            return _buildBody(context, state.service);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ServiceDetailModel service) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                      ? Image.network(
                          service.imageUrl!,
                          height: 350,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildHeroPlaceholder(service),
                        )
                      : _buildHeroPlaceholder(service),
                ),

                /// TAG
                Positioned(
                  left: 20,
                  bottom: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: Text(
                      service.subcategory.toUpperCase(),
                      style: AppFonts.poppinsSemiBold(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                /// TITLE
                Positioned(
                  left: 20,
                  bottom: 30,
                  right: 20,
                  child: Text(
                    service.name,
                    style: AppFonts.poppinsSemiBold(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                /// OVERLAP CARD
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -102,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /// DURATION
                        Column(
                          children: [
                            Icon(Icons.access_time,
                                color: AppColors.primaryColor, size: 26),
                            const SizedBox(height: 2),
                            Text(
                              "DURATION",
                              style: AppFonts.poppinsRegular(
                                fontSize: 13,
                                color: AppColors.primaryBlack40,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              service.formattedDuration,
                              style: AppFonts.poppinsSemiBold(
                                color: AppTheme.primaryText,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),

                        /// PRICE
                        Column(
                          children: [
                            Icon(Icons.payments_outlined,
                                color: AppColors.primaryColor, size: 26),
                            const SizedBox(height: 2),
                            Text(
                              "STARTING PRICE",
                              style: AppFonts.poppinsRegular(
                                fontSize: 13,
                                color: AppColors.primaryBlack40,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              service.formattedPrice,
                              style: AppFonts.poppinsSemiBold(
                                color: AppTheme.primaryText,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 140),

            /// ABOUT TREATMENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("About Treatment"),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: AppFonts.poppinsRegular(
                      color: AppTheme.secondaryText,
                      height: 1.5,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// KEY BENEFITS
                  if (service.benefitsList.isNotEmpty) ...[
                    _sectionHeader("Key Benefits"),
                    const SizedBox(height: 14),
                    ...service.benefitsList.map(
                      (benefit) => BenefitItem(
                        title: benefit,
                        subtitle: "",
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  /// TOOLS & EQUIPMENT
                  if (service.toolsList.isNotEmpty) ...[
                    _sectionHeader("Tools & Equipment"),
                    const SizedBox(height: 14),
                    ...service.toolsList.asMap().entries.map(
                      (entry) => _expectItem(entry.key + 1, entry.value),
                    ),
                    const SizedBox(height: 40),
                  ],

                  /// EXPERT INFO
                  if (service.expertName.isNotEmpty) ...[
                    _sectionHeader("Your Expert"),
                    const SizedBox(height: 14),
                    _buildExpertCard(service),
                    const SizedBox(height: 40),
                  ],

                  /// ADDITIONAL INFO
                  if (service.requiredCertification != null ||
                      service.experienceLevel != null) ...[
                    _sectionHeader("Additional Info"),
                    const SizedBox(height: 14),
                    if (service.requiredCertification != null)
                      _infoRow(
                          Icons.verified_outlined, service.requiredCertification!),
                    if (service.experienceLevel != null)
                      _infoRow(Icons.signal_cellular_alt,
                          'Level: ${service.experienceLevel}'),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),

            /// BOOK BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentBookingPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 25),
                      const SizedBox(width: 8),
                      Text(
                        "Book Appointment",
                        style: AppFonts.poppinsSemiBold(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Hero placeholder for when no image is available.
  Widget _buildHeroPlaceholder(ServiceDetailModel service) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withAlpha(180),
            AppColors.primaryColor.withAlpha(80),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa_outlined,
              size: 64,
              color: Colors.white.withAlpha(200),
            ),
            const SizedBox(height: 8),
            Text(
              service.category,
              style: AppFonts.poppinsSemiBold(
                fontSize: 16,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Expert info card
  Widget _buildExpertCard(ServiceDetailModel service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tagBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryColor.withAlpha(50),
            backgroundImage: service.avatarUrl != null
                ? NetworkImage(service.avatarUrl!)
                : null,
            child: service.avatarUrl == null
                ? Text(
                    service.firstName.isNotEmpty
                        ? service.firstName[0].toUpperCase()
                        : '?',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 20,
                      color: AppColors.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.expertName,
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 16,
                    color: AppTheme.primaryText,
                  ),
                ),
                if (service.specialization != null)
                  Text(
                    service.specialization!,
                    style: AppFonts.poppinsRegular(
                      fontSize: 13,
                      color: AppTheme.secondaryText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Additional info row
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppFonts.poppinsRegular(
                fontSize: 15,
                color: AppTheme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Numbered list item (for tools)
  Widget _expectItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 33,
            height: 33,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              number.toString(),
              style: AppFonts.poppinsSemiBold(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppFonts.poppinsRegular(
                fontSize: 18,
                color: AppTheme.secondaryText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section header with accent line
  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 1.5,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppFonts.poppinsSemiBold(
            color: AppTheme.primaryText,
            fontSize: 26,
          ),
        ),
      ],
    );
  }
}