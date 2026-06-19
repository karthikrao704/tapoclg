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
import 'package:tapovana_mobile_app/features/appointments/presentation/pages/appointment_details_page.dart';
import 'package:tapovana_mobile_app/features/more/repositories/more_repository.dart';
import 'package:tapovana_mobile_app/features/more/models/more_models.dart';
import 'package:tapovana_mobile_app/features/more/wellness_blog_details_page.dart';
import 'package:tapovana_mobile_app/features/more/vedic_package_details_page.dart';
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
  int _selectedMoodIndex = -1;
  double _mindValue = 0.75;
  double _bodyValue = 0.85;
  double _soulValue = 0.90;

  void _updateBalanceValues(int moodIndex) {
    setState(() {
      _selectedMoodIndex = moodIndex;
      switch (moodIndex) {
        case 0: // Low
          _mindValue = 0.30;
          _bodyValue = 0.40;
          _soulValue = 0.35;
          break;
        case 1: // Okay
          _mindValue = 0.55;
          _bodyValue = 0.60;
          _soulValue = 0.55;
          break;
        case 2: // Good
          _mindValue = 0.80;
          _bodyValue = 0.85;
          _soulValue = 0.80;
          break;
        case 3: // Great
          _mindValue = 0.95;
          _bodyValue = 0.95;
          _soulValue = 0.95;
          break;
      }
    });
  }

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

              // Quick Actions
              const SizedBox(height: 30),
              _buildQuickActions(),

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

                  final allAppointments = snapshot.data ?? [];
                  
                  // Filter out past appointments
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final appointments = allAppointments.where((appt) {
                    try {
                      final dateStr = appptDateStr(appt['date']);
                      if (dateStr.isNotEmpty) {
                        final parsedDate = DateTime.parse(dateStr);
                        // Return true if date is today or in the future
                        return !parsedDate.isBefore(today);
                      }
                      return true; // Keep if we can't parse it just in case
                    } catch (_) {
                      return true;
                    }
                  }).toList();

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

                        final doctorNameStr = 'with ${appt['therapist'] ?? 'Dr. Aris'}';
                        final roomStr = 'Room ${100 + (appt['id'] as int? ?? 1)}';

                        return Container(
                          width: 290,
                          margin: const EdgeInsets.only(right: 14),
                          child: AppointmentCard(
                            month: month,
                            day: day,
                            title: appt['service_name'] ?? 'Swedish Massage',
                            doctorName: doctorNameStr,
                            time: appt['time'] ?? '10:30 AM',
                            room: roomStr,
                            onTap: () {
                              final updatedAppt = Map<String, dynamic>.from(appt);
                              updatedAppt['therapist'] = updatedAppt['therapist'] ?? 'Dr. Aris';
                              updatedAppt['room'] = roomStr;
                              
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => AppointmentDetailsPage(appointment: updatedAppt),
                                ),
                              );
                            },
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

              // Expert Therapists Section
              const SizedBox(height: 30),
              _buildExpertTherapists(),

              // Yoga Daily Practice Section
              const SizedBox(height: 30),
              _buildYogaOptions(),

              // Latest Wellness Articles Section
              const SizedBox(height: 30),
              _buildLatestArticles(),

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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _selectedMoodIndex == 0 
                        ? "Level: Low" 
                        : _selectedMoodIndex == 1 
                            ? "Level: Balanced"
                            : _selectedMoodIndex == 3 
                                ? "Level: Peak"
                                : "Level: Optimal",
                    key: ValueKey(_selectedMoodIndex),
                    style: AppFonts.poppinsMedium(
                      fontSize: 11,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressRow("Mind (Dhyana)", _mindValue, mindColor, labelColor, valueColor, indicatorBg),
          const SizedBox(height: 10),
          _buildProgressRow("Body (Prana)", _bodyValue, bodyColor, labelColor, valueColor, indicatorBg),
          const SizedBox(height: 10),
          _buildProgressRow("Soul (Sattva)", _soulValue, soulColor, labelColor, valueColor, indicatorBg),
          const SizedBox(height: 20),
          _buildInteractiveMoodSelector(),
        ],
      ),
    );
  }

  Widget _buildInteractiveMoodSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white70 : const Color(0xFF6F7894);
    final moods = [
      {'icon': '😔', 'label': 'Low'},
      {'icon': '😐', 'label': 'Okay'},
      {'icon': '🙂', 'label': 'Good'},
      {'icon': '✨', 'label': 'Great'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How are you feeling today?",
          style: AppFonts.poppinsMedium(fontSize: 12, color: titleColor),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(moods.length, (index) {
            final isSelected = _selectedMoodIndex == index;
            return GestureDetector(
              onTap: () {
                _updateBalanceValues(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFC9A14A).withAlpha(50) 
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFFC9A14A) 
                        : (isDark ? Colors.white24 : Colors.black12),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      moods[index]['icon']!,
                      style: TextStyle(
                        fontSize: isSelected ? 26 : 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      moods[index]['label']!,
                      style: AppFonts.poppinsMedium(
                        fontSize: 11,
                        color: isSelected 
                            ? const Color(0xFFC9A14A) 
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
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
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Text(
                  "${(val * 100).toInt()}%",
                  style: AppFonts.poppinsMedium(fontSize: 12, color: valueColor),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return LinearProgressIndicator(
                value: val,
                backgroundColor: indicatorBg,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              );
            },
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

    final dailyProverb = getWellnessProverbForDate(DateTime.now());

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
            dailyProverb,
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

    final List<List<Color>> lightGradients = [
      [const Color(0xFFFFF7ED), const Color(0xFFFEEDD8)],
      [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
      [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
    ];

    final List<List<Color>> darkGradients = [
      [const Color(0xFF2C1B10), const Color(0xFF1F120A)],
      [const Color(0xFF102A1A), const Color(0xFF0A1F12)],
      [const Color(0xFF101B2E), const Color(0xFF0A1221)],
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
        FutureBuilder<List<VedicPackage>>(
          future: MoreRepository().getVedicPrograms(),
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

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withAlpha(20) : const Color(0xFFE9ECEF),
                  ),
                ),
                child: Center(
                  child: Text(
                    "No programs available",
                    style: AppFonts.poppinsRegular(
                      color: AppColors.primaryBlack40,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            final packages = snapshot.data!.take(5).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: List.generate(packages.length, (index) {
                  final pkg = packages[index];
                  final gradientColors = isDark 
                      ? darkGradients[index % darkGradients.length] 
                      : lightGradients[index % lightGradients.length];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => VedicPackageDetailsPage(package: pkg),
                        ),
                      );
                    },
                    child: Container(
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
                              : gradientColors[1].withAlpha(200),
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
                                  : Colors.white.withAlpha(200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pkg.duration,
                              style: AppFonts.poppinsMedium(
                                fontSize: 11,
                                color: const Color(0xFFC9A14A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            pkg.title,
                            style: AppFonts.poppinsSemiBold(
                              fontSize: 16,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pkg.description,
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
                                pkg.price,
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
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = [
      {'icon': Icons.spa_outlined, 'label': 'Massage'},
      {'icon': Icons.self_improvement_outlined, 'label': 'Yoga'},
      {'icon': Icons.local_florist_outlined, 'label': 'Ayurveda'},
      {'icon': Icons.medical_services_outlined, 'label': 'Consult'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF6EE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFEADFCA),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  action['icon'] as IconData,
                  color: const Color(0xFFC9A14A),
                  size: 28,
                ),
                onPressed: () {
                  context.go(RouteConstants.services);
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action['label'] as String,
              style: AppFonts.poppinsMedium(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildExpertTherapists() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final therapists = [
      {'name': 'Dr. Aris', 'role': 'Ayurvedic Doctor', 'rating': '4.9', 'image': 'https://i.pravatar.cc/150?u=a042581f4e29026704d'},
      {'name': 'Maya Devi', 'role': 'Yoga Instructor', 'rating': '4.8', 'image': 'https://i.pravatar.cc/150?u=a042581f4e29026024d'},
      {'name': 'Ravi Kumar', 'role': 'Massage Therapist', 'rating': '5.0', 'image': 'https://i.pravatar.cc/150?u=a04258a2462d826712d'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Our Expert Therapists",
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
            children: therapists.map((therapist) {
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(therapist['image']!),
                      backgroundColor: const Color(0xFFEADFCA),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      therapist['name']!,
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      therapist['role']!,
                      style: AppFonts.poppinsRegular(
                        fontSize: 11,
                        color: AppColors.primaryBlack40,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          therapist['rating']!,
                          style: AppFonts.poppinsMedium(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildLatestArticles() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Latest Articles",
              style: AppFonts.poppinsSemiBold(
                fontSize: 22,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.go(RouteConstants.more); // More tab has the blog section
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
        FutureBuilder<List<WellnessBlogPost>>(
          future: MoreRepository().getBlogs(),
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

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withAlpha(20) : const Color(0xFFE9ECEF),
                  ),
                ),
                child: Center(
                  child: Text(
                    "No articles available",
                    style: AppFonts.poppinsRegular(
                      color: AppColors.primaryBlack40,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            // Take only the latest 3 articles
            final articles = snapshot.data!.take(3).toList();

            return Column(
              children: articles.map((article) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => WellnessBlogDetailsPage(post: article),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: article.imagePath != null && article.imagePath!.isNotEmpty
                              ? Image.network(
                                  article.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                                )
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.article, color: Colors.grey),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  article.category,
                                  style: AppFonts.poppinsSemiBold(
                                    fontSize: 10,
                                    color: const Color(0xFFC9A14A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  article.title,
                                  style: AppFonts.poppinsMedium(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildYogaOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yogaPoses = [
      {
        'title': 'Surya Namaskar',
        'subtitle': 'Sun Salutation',
        'instruction': 'A flow of 12 postures that deeply stretches the whole body and warms up your muscles. Best performed at sunrise.',
        'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=400',
      },
      {
        'title': 'Vrikshasana',
        'subtitle': 'Tree Pose',
        'instruction': 'Stand tall, place your right foot on your left inner thigh. Bring hands to prayer position. Improves focus and balance.',
        'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=80&w=400',
      },
      {
        'title': 'Balasana',
        'subtitle': 'Child\'s Pose',
        'instruction': 'Kneel, sit on your heels, and walk your hands forward until your forehead touches the mat. Relieves back tension.',
        'image': 'https://images.unsplash.com/photo-1593164842264-854604db2260?auto=format&fit=crop&q=80&w=400',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daily Yoga Practice",
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
            children: yogaPoses.map((pose) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Image.network(
                        pose['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pose['title']!,
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC9A14A).withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "5 Mins",
                                  style: AppFonts.poppinsMedium(
                                    fontSize: 10,
                                    color: const Color(0xFFC9A14A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pose['subtitle']!,
                            style: AppFonts.poppinsMedium(
                              fontSize: 12,
                              color: const Color(0xFFC9A14A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            pose['instruction']!,
                            style: AppFonts.poppinsRegular(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
