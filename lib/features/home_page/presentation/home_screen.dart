import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/components/appointment_card.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/components/service_card.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/components/tip_card.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/data/wellness_tips.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_cubit.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_state.dart';
import 'package:tapovana_mobile_app/features/services/data/repositories/service_repository.dart';
import 'package:tapovana_mobile_app/features/service_details/presentation/pages/service_details_page.dart';
import 'package:tapovana_mobile_app/core/storage/local_database.dart';
import 'package:tapovana_mobile_app/features/chatbot/presentation/components/floating_chat_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceCubit(
        repository: ServiceRepository(),
      )..fetchServices(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    final dailyTip = getWellnessTipForDate(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: const FloatingChatButton(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tip Card
              const SizedBox(height: 20),
              TipCard(
                tipText: dailyTip,
              ),

              // Daily Mind-Body Balance Tracker
              const SizedBox(height: 24),
              _buildWellnessTrackerCard(),

              // Featured Services Section
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      "Featured Services",
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      context.go(RouteConstants.services);
                    },
                    child: Text(
                      "View all",
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dynamic loading of real services from ServiceCubit
              BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  if (state is ServiceError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Failed to load services",
                              style: AppFonts.poppinsRegular(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                context.read<ServiceCubit>().fetchServices();
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text("Retry"),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ServiceLoaded) {
                    final services = state.services.take(5).toList();
                    if (services.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Center(
                          child: Text(
                            "No featured services available",
                            style: AppFonts.poppinsRegular(
                              color: AppColors.primaryBlack40,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: services.map((service) {
                          return Container(
                            width: 170,
                            margin: const EdgeInsets.only(right: 16),
                            child: ServiceCard(
                              imagePath: service.imageUrl ?? '',
                              tagLabel: service.subcategory,
                              serviceName: service.name,
                              duration: service.formattedDuration,
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (_) => ServiceDetailsPage(
                                      serviceId: service.id,
                                    ),
                                  ),
                                )
                                    .then((_) {
                                  setState(() {});
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              // Upcoming Appointments Section
              const SizedBox(height: 30),
              Text(
                "Upcoming Appointments",
                style: AppFonts.poppinsSemiBold(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic upcoming appointments (horizontally scrollable)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: LocalDatabase.getAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  final appointments = snapshot.data ?? [];
                  if (appointments.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withAlpha(20)
                              : const Color(0xFFE9ECEF),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "No upcoming appointments",
                          style: AppFonts.poppinsRegular(
                            color: AppColors.primaryBlack40,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: appointments.map((appt) {
                        final dateStr = appptDateStr(appt['date']);
                        String month = 'OCT';
                        String day = '24';
                        try {
                          if (dateStr.isNotEmpty) {
                            final parsedDate = DateTime.parse(dateStr);
                            const months = [
                              'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                              'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
                            ];
                            month = months[parsedDate.month - 1];
                            day = parsedDate.day.toString();
                          }
                        } catch (_) {}

                        return Container(
                          width: 290,
                          margin: const EdgeInsets.only(right: 14),
                          child: AppointmentCard(
                            month: month,
                            day: day,
                            title: appt['service_name'] ?? 'Swedish Massage',
                            doctorName:
                                'with ${appt['therapist'] ?? 'Dr. Aris'}',
                            time: appt['time'] ?? '10:30 AM',
                            room: 'Room ${100 + (appt['id'] as int? ?? 1)}',
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              // Recommended Vedic Programs Section
              const SizedBox(height: 30),
              _buildVedicPrograms(),

              // Quote of the Day Section
              const SizedBox(height: 30),
              _buildQuoteCard(),

              // Extra spacing at the bottom
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessTrackerCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
        : [const Color(0xFFFAF6EE), const Color(0xFFEADFCA)];

    final titleColor = isDark ? Colors.white : const Color(0xFF191F38);
    
    final badgeBg = isDark
        ? const Color(0xFFE5B368).withAlpha(40)
        : const Color(0xFFD9A04B).withAlpha(30);

    final badgeTextColor = isDark ? const Color(0xFFE5B368) : const Color(0xFFD9A04B);

    final labelColor = isDark ? Colors.white70 : const Color(0xFF6F7894);
    final valueColor = isDark ? Colors.white : const Color(0xFF191F38);

    final indicatorBg = isDark
        ? Colors.white.withAlpha(25)
        : const Color(0xFF191F38).withAlpha(20);

    final mindColor = isDark ? Colors.blue.shade300 : Colors.blue.shade600;
    final bodyColor = isDark ? Colors.amber.shade400 : Colors.orange.shade700;
    final soulColor = isDark ? Colors.teal.shade300 : Colors.teal.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(15)
              : const Color(0xFFD9A04B).withAlpha(20),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Daily Mind-Body Balance",
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 16,
                    color: titleColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: badgeTextColor, width: 0.5),
                ),
                child: Text(
                  "Level: Optimal",
                  style: AppFonts.poppinsMedium(
                    fontSize: 11,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressRow("Mind (Dhyana)", 0.75, mindColor, labelColor, valueColor, indicatorBg),
          const SizedBox(height: 10),
          _buildProgressRow("Body (Prana)", 0.85, bodyColor, labelColor, valueColor, indicatorBg),
          const SizedBox(height: 10),
          _buildProgressRow("Soul (Sattva)", 0.90, soulColor, labelColor, valueColor, indicatorBg),
        ],
      ),
    );
  }

  Widget _buildProgressRow(
    String label,
    double value,
    Color color,
    Color labelColor,
    Color valueColor,
    Color indicatorBg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppFonts.poppinsRegular(fontSize: 12, color: labelColor),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: AppFonts.poppinsMedium(fontSize: 12, color: valueColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: indicatorBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quoteBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFDFBF7);
    final quoteBorder = isDark ? Colors.white.withAlpha(15) : const Color(0xFFF3EAD8);
    final quoteTextColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF644F24);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: quoteBg,
        border: Border.all(color: quoteBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: Color(0xFFC9A14A),
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            "\"Health is a state of complete physical, mental, and social well-being, and not merely the absence of disease or infirmity.\"",
            textAlign: TextAlign.center,
            style: AppFonts.headland(
              fontSize: 15,
              color: quoteTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "— Vedic Wellness Proverb",
            style: AppFonts.poppinsMedium(
              fontSize: 11,
              color: const Color(0xFFC9A14A),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVedicPrograms() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final packages = [
      {
        'title': 'Ayurvedic Panchakarma',
        'desc': 'Complete 5-stage detoxification & cell renewal.',
        'duration': '7 Days Program',
        'price': '₹14,500',
        'gradient': isDark
            ? [const Color(0xFF2C1B10), const Color(0xFF1F120A)]
            : [const Color(0xFFFFF7ED), const Color(0xFFFEEDD8)],
      },
      {
        'title': 'Sirodhara Rejuvenation',
        'desc': 'Warm herbal oils poured onto the third eye chakra.',
        'duration': '90 Mins Session',
        'price': '₹3,200',
        'gradient': isDark
            ? [const Color(0xFF102A1A), const Color(0xFF0A1F12)]
            : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
      },
      {
        'title': 'Nadi Pariksha consultation',
        'desc': 'Pulse analysis to diagnose imbalances in Doshas.',
        'duration': '45 Mins Session',
        'price': '₹1,500',
        'gradient': isDark
            ? [const Color(0xFF101B2E), const Color(0xFF0A1221)]
            : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommended Vedic Programs",
          style: AppFonts.poppinsSemiBold(
            fontSize: 22,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: packages.map((pkg) {
              final gradientColors = pkg['gradient'] as List<Color>;
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? gradientColors[1].withAlpha(80)
                        : gradientColors[1].withValues(alpha: 0.8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withAlpha(120)
                            : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pkg['duration'] as String,
                        style: AppFonts.poppinsMedium(
                          fontSize: 11,
                          color: const Color(0xFFC9A14A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pkg['title'] as String,
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pkg['desc'] as String,
                      style: AppFonts.poppinsRegular(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pkg['price'] as String,
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 16,
                            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC9A14A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String appptDateStr(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
