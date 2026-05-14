import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_cubit.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_state.dart';
import 'package:tapovana_mobile_app/features/services/data/models/service_model.dart';
import 'package:tapovana_mobile_app/features/services/data/repositories/service_repository.dart';
import 'package:tapovana_mobile_app/features/service_details/presentation/pages/service_details_page.dart';

// --- Main Grid Widget ---
class ServiceGridSection extends StatelessWidget {
  const ServiceGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceCubit(repository: ServiceRepository())..fetchServices(),
      child: const _ServiceGridContent(),
    );
  }
}

class _ServiceGridContent extends StatelessWidget {
  const _ServiceGridContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double estimatedCardHeight = 150.0 + (110.0 * textScale);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.tealBlue,
              ),
            );
          }

          if (state is ServiceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load services',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 16,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: AppFonts.poppinsRegular(
                      fontSize: 13,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ServiceCubit>().fetchServices();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ServiceLoaded) {
            if (state.services.isEmpty) {
              return Center(
                child: Text(
                  'No services available',
                  style: AppFonts.poppinsRegular(
                    fontSize: 15,
                    color: AppTheme.secondaryText,
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                mainAxisExtent: estimatedCardHeight,
              ),
              itemCount: state.services.length,
              itemBuilder: (context, index) {
                return _ServiceCard(service: state.services[index]);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// --- Individual Card Widget ---
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailsPage(serviceId: service.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Image area
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15.0),
                    ),
                    child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                        ? Image.network(
                            service.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.category,
                        style: AppFonts.poppinsSemiBold(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom: Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.poppinsSemiBold(
                        color: AppTheme.primaryText,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      service.durationAndCategory,
                      style: AppFonts.poppinsRegular(
                        color: AppTheme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          service.formattedPrice,
                          style: AppFonts.poppinsSemiBold(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Navigate to details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ServiceDetailsPage(serviceId: service.id),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      color: AppColors.tagBackground,
      child: Center(
        child: Icon(
          Icons.spa_outlined,
          size: 40,
          color: AppColors.primaryColor.withAlpha(150),
        ),
      ),
    );
  }
}
