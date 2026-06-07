import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/appointments/presentation/widgets/calender_widget.dart';
import 'package:tapovana_mobile_app/core/storage/local_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/profile/profile_bloc.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/profile/profile_event.dart';
import 'package:tapovana_mobile_app/features/appointments/data/repositories/booking_repository.dart';
import 'package:tapovana_mobile_app/features/services/data/models/service_detail_model.dart';

class AppointmentBookingPage extends StatefulWidget {
  final String? serviceName;
  final String? price;
  final List<StaffDetail>? therapists;

  const AppointmentBookingPage({
    super.key,
    this.serviceName,
    this.price,
    this.therapists,
  });

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = "10:30 AM";
  String selectedTherapist = "Dr. Aris";
  String? activePass;
  int availableCredits = 0;
  bool useCredits = false;

  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  int _calculateCreditCost(double price) {
    if (price <= 1000) return 1;
    if (price <= 2000) return 2;
    if (price <= 3000) return 3;
    if (price <= 4000) return 5;
    if (price <= 6000) return 8;
    return 12;
  }

  @override
  void initState() {
    super.initState();
    _loadWellnessPass();
    if (widget.therapists != null && widget.therapists!.isNotEmpty) {
      selectedTherapist = widget.therapists!.first.fullName;
    }
  }

  Future<void> _loadWellnessPass() async {
    final pass = await LocalDatabase.getWellnessPass();
    final credits = await LocalDatabase.getWellnessCredits() ?? 0;
    if (mounted) {
      setState(() {
        activePass = pass;
        availableCredits = credits;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double originalPriceValue = 0.0;
    if (widget.price != null) {
      final cleanStr = widget.price!.replaceAll(RegExp(r'[^0-9.]'), '');
      originalPriceValue = double.tryParse(cleanStr) ?? 0.0;
    }
    final int creditCost = _calculateCreditCost(originalPriceValue);
    final bool hasEnoughCredits = availableCredits >= creditCost;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Book Appointment",
          style: AppFonts.headland(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SELECT DATE
            const SectionTitle(
              icon: Icons.calendar_month_outlined,
              title: "Select Date",
            ),

            const SizedBox(height: 10),

            CalendarWidget(
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),

            const SizedBox(height: 20),

            /// TIME SLOT
            const SectionTitle(icon: Icons.access_time, title: "Time Slot"),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                TimeSlot(
                  time: "09:00 AM",
                  isSelected: selectedTime == "09:00 AM",
                  onTap: () {
                    setState(() {
                      selectedTime = "09:00 AM";
                    });
                  },
                ),

                TimeSlot(
                  time: "10:30 AM",
                  isSelected: selectedTime == "10:30 AM",
                  onTap: () {
                    setState(() {
                      selectedTime = "10:30 AM";
                    });
                  },
                ),

                TimeSlot(
                  time: "01:00 PM",
                  isSelected: selectedTime == "01:00 PM",
                  onTap: () {
                    setState(() {
                      selectedTime = "01:00 PM";
                    });
                  },
                ),

                TimeSlot(
                  time: "02:30 PM",
                  isSelected: selectedTime == "02:30 PM",
                  onTap: () {
                    setState(() {
                      selectedTime = "02:30 PM";
                    });
                  },
                ),
                TimeSlot(
                  time: "04:00 PM",
                  isSelected: selectedTime == "04:00 PM",
                  onTap: () {
                    setState(() {
                      selectedTime = "04:00 PM";
                    });
                  },
                ),
                TimeSlot(
                  time: "05:30 PM",
                  isSelected: selectedTime == "05:30 PM",
                  onTap: () {
                    setState(() {
                      selectedTime = "05:30 PM";
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// THERAPIST
            const SectionTitle(icon: Icons.person_outline, title: "Therapist"),

            const SizedBox(height: 14),

            if (widget.therapists != null && widget.therapists!.isNotEmpty)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceEvenly,
                children: widget.therapists!.map((staff) {
                  return SizedBox(
                    width: 105,
                    child: therapistCard(
                      staff.fullName,
                      staff.email,
                      imageUrl: staff.avatarUrl,
                    ),
                  );
                }).toList(),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  therapistCard(
                    "Dr. Aris",
                    "LEAD",
                    assetImage: "assets/appointments/dr_1.png",
                  ),

                  therapistCard(
                    "Sarah W.",
                    "Massage",
                    assetImage: "assets/appointments/dr_2.png",
                  ),

                  therapistCard(
                    "Michael K.",
                    "Yoga",
                    assetImage: "assets/appointments/dr_3.png",
                  ),
                ],
              ),

            const SizedBox(height: 40),

            /// NOTES
            const SectionTitle(icon: Icons.notes_outlined, title: "Add Notes"),

            const SizedBox(height: 12),

            TextField(
              controller: _noteController,
              maxLines: 3,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText:
                    "e.g., Deep tissue preference, focus on lower back...",
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color.fromARGB(255, 241, 237, 237),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            if (availableCredits > 0) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: useCredits
                        ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                        : (Theme.of(context).brightness == Brightness.dark
                            ? [const Color(0xFF1E293B), const Color(0xFF1E293B)]
                            : [const Color(0xFFF8FAFC), const Color(0xFFF8FAFC)]),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: useCredits ? const Color(0xFFC9A14A) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: useCredits ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: useCredits ? const Color(0xFFC9A14A) : (hasEnoughCredits ? Colors.amber.shade700 : Colors.grey),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pay with Wellness Credits",
                            style: AppFonts.poppinsSemiBold(
                              fontSize: 14,
                              color: useCredits ? Colors.white : (hasEnoughCredits ? Theme.of(context).colorScheme.onSurface : Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasEnoughCredits
                                ? "Cost: $creditCost ${creditCost == 1 ? 'Credit' : 'Credits'} ($availableCredits remaining)"
                                : "Cost: $creditCost ${creditCost == 1 ? 'Credit' : 'Credits'} ($availableCredits remaining) - Insufficient",
                            style: AppFonts.poppinsRegular(
                              fontSize: 12,
                              color: useCredits
                                  ? Colors.white70
                                  : (hasEnoughCredits ? (Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.secondaryText) : Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: useCredits,
                      activeThumbColor: const Color(0xFFC9A14A),
                      activeTrackColor: const Color(0xFFC9A14A).withValues(alpha: 0.3),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade200,
                      onChanged: hasEnoughCredits
                          ? (value) {
                              setState(() {
                                useCredits = value;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            /// PRICE BREAKDOWN & ESTIMATED TOTAL
            Builder(
              builder: (context) {
                double originalPrice = 0.0;
                if (widget.price != null) {
                  final cleanStr = widget.price!.replaceAll(RegExp(r'[^0-9.]'), '');
                  originalPrice = double.tryParse(cleanStr) ?? 0.0;
                }

                double discountPercentage = 0.0;
                String passLabel = '';
                if (activePass != null) {
                  final passUpper = activePass!.toUpperCase();
                  if (passUpper.contains('SILVER')) {
                    discountPercentage = 0.10;
                    passLabel = 'Silver Pass (10%)';
                  } else if (passUpper.contains('GOLD')) {
                    discountPercentage = 0.20;
                    passLabel = 'Gold Pass (20%)';
                  } else if (passUpper.contains('DIAMOND')) {
                    discountPercentage = 0.30;
                    passLabel = 'Diamond Pass (30%)';
                  }
                }

                double discountAmount = originalPrice * discountPercentage;
                double finalPrice = originalPrice - discountAmount;

                String formattedOriginal = '₹${originalPrice.toStringAsFixed(2)}';
                String formattedDiscount = '-₹${discountAmount.toStringAsFixed(2)}';
                String formattedFinal = '₹${finalPrice.toStringAsFixed(2)}';

                if (originalPrice == originalPrice.roundToDouble()) {
                  formattedOriginal = '₹${originalPrice.toInt()}';
                }
                if (discountAmount == discountAmount.roundToDouble()) {
                  formattedDiscount = '-₹${discountAmount.toInt()}';
                }
                if (finalPrice == finalPrice.roundToDouble()) {
                  formattedFinal = '₹${finalPrice.toInt()}';
                }

                if (useCredits) {
                  formattedOriginal = '$creditCost ${creditCost == 1 ? 'Credit' : 'Credits'}';
                  formattedDiscount = '';
                  formattedFinal = '$creditCost ${creditCost == 1 ? 'Credit' : 'Credits'}';
                  discountAmount = 0.0;
                }

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "BILL DETAILS",
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              Text(
                                "${_formatDate(selectedDate)} at $selectedTime",
                                style: AppFonts.poppinsRegular(
                                  fontSize: 11,
                                  color: AppColors.primaryBlack40,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Subtotal",
                                style: AppFonts.poppinsRegular(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                formattedOriginal,
                                style: AppFonts.poppinsMedium(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          if (discountAmount > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_offer_outlined,
                                      color: AppColors.primaryColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      passLabel,
                                      style: AppFonts.poppinsMedium(
                                        fontSize: 14,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  formattedDiscount,
                                  style: AppFonts.poppinsMedium(
                                    fontSize: 14,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ESTIMATED TOTAL",
                                    style: AppFonts.poppinsSemiBold(
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  if (useCredits)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        "$creditCost Wellness ${creditCost == 1 ? 'Credit' : 'Credits'} will be deducted",
                                        style: AppFonts.poppinsRegular(
                                          fontSize: 11,
                                          color: const Color(0xFFC9A14A),
                                        ),
                                      ),
                                    )
                                  else if (discountAmount > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        "Wellness Pass discount applied",
                                        style: AppFonts.poppinsRegular(
                                          fontSize: 11,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                formattedFinal,
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: 20,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// CONFIRM BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final profileBloc = context.read<ProfileBloc>();
                          final profileState = profileBloc.state;

                          final String finalPriceToSave = useCredits
                              ? "$creditCost ${creditCost == 1 ? 'Credit' : 'Credits'}"
                              : (discountAmount > 0
                                  ? "$formattedFinal (${activePass!.toUpperCase().replaceAll(' PASS', '')} Pass)"
                                  : (widget.price ?? "₹1200"));

                          // Show progress loader
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC9A14A)),
                              ),
                            ),
                          );

                          // Prepare database payload
                          final userName = profileState.name.isNotEmpty
                              ? profileState.name
                              : 'Guest User';
                          final profilePic = profileState.profilePhotoUrl;
                          final serviceName = widget.serviceName ?? "Swedish Massage";
                          final dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                          final note = _noteController.text;

                          String? passDetails;
                          if (useCredits) {
                            final mType = profileState.membershipType.toUpperCase();
                            if (mType.contains('SILVER')) {
                              passDetails = 'SILVER';
                            } else if (mType.contains('GOLD')) {
                              passDetails = 'GOLD';
                            } else if (mType.contains('DIAMOND')) {
                              passDetails = 'DIAMOND';
                            } else {
                              passDetails = profileState.membershipType;
                            }
                          }

                          // Sync to PostgreSQL DB (via Node.js backend)
                          final syncSuccess = await BookingRepository.createBooking(
                            userName: userName,
                            profilePic: profilePic,
                            serviceName: serviceName,
                            bookingDate: dateStr,
                            bookingTime: selectedTime,
                            therapistName: selectedTherapist,
                            note: note.isNotEmpty ? note : null,
                            totalAmount: finalPriceToSave,
                            passDetails: passDetails,
                          );

                          // Close loader
                          navigator.pop();

                          if (useCredits) {
                            await LocalDatabase.saveWellnessCredits(availableCredits - creditCost);
                          }

                          await LocalDatabase.insertAppointment(
                            serviceName: serviceName,
                            date: dateStr,
                            time: selectedTime,
                            therapist: selectedTherapist,
                            price: finalPriceToSave,
                          );

                          try {
                            profileBloc.add(LoadProfile());
                          } catch (e) {
                            debugPrint('Could not reload ProfileBloc: $e');
                          }

                          if (syncSuccess) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text("Booking Confirmed & Synced for $serviceName!"),
                                backgroundColor: AppColors.primaryColor,
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Booking Saved Locally (Cloud Sync Failed)."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                          navigator.pop(); // Go back
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A14A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Confirm Booking",
                              style: AppFonts.poppinsSemiBold(
                                fontSize: 16,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //therapist card
  Widget therapistCard(String name, String role, {String? imageUrl, String? assetImage}) {
    bool isSelected = selectedTherapist == name;

    Widget imageWidget;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          assetImage ?? "assets/appointments/dr_1.png",
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    } else {
      imageWidget = Image.asset(
        assetImage ?? "assets/appointments/dr_1.png",
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTherapist = name;
        });
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFC9A14A)
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageWidget,
                ),
              ),

              /// TICK ICON
              if (isSelected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC9A14A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            name,
            style: AppFonts.poppinsSemiBold(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          Text(
            role,
            style: AppFonts.poppinsRegular(fontSize: 10, color: AppColors.primaryBlack40),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}

//sectiontitle
class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 26, color: const Color(0xFFC9A14A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppFonts.poppinsSemiBold(fontSize: 19),
        ),
      ],
    );
  }
}

//timeslot
class TimeSlot extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const TimeSlot({
    super.key,
    required this.time,
    required this.isSelected,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    Color textColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDisabled) {
      borderColor = isDark ? Colors.white24 : Colors.grey.shade300;
      backgroundColor = isDark ? Colors.transparent : Colors.white;
      textColor = Colors.grey;
    } else if (isSelected) {
      borderColor = const Color(0xFFC9A14A);
      backgroundColor = isDark ? const Color(0x33C9A14A) : const Color(0xFFF5E7C5); // light gold
      textColor = const Color(0xFFC9A14A);
    } else {
      borderColor = isDark ? Colors.white24 : Colors.grey.shade300;
      backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;
      textColor = isDark ? Colors.white70 : Colors.black87;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: 115,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          time,
          style: AppFonts.poppinsMedium(
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }
}