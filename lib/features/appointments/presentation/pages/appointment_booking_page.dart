import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/appointments/presentation/widgets/calender_widget.dart';
//import 'package:tapovana_mobile_app/features/bookings/presentation/pages/my_bookings_page.dart';

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({super.key});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = "10:30 AM";
  String selectedTherapist = "Dr. Aris";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
        title: Text(
          "Book Appointment",
          style: AppFonts.headland(
            color: AppTheme.primaryText,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                therapistCard(
                  "Dr. Aris",
                  "LEAD",
                  "assets/appointments/dr_1.png",
                ),

                therapistCard(
                  "Sarah W.",
                  "Massage",
                  "assets/appointments/dr_2.png",
                ),

                therapistCard(
                  "Michael K.",
                  "Yoga",
                  "assets/appointments/dr_3.png",
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// NOTES
            const SectionTitle(icon: Icons.notes_outlined, title: "Add Notes"),

            const SizedBox(height: 12),

            TextField(
              maxLines: 3,

              decoration: InputDecoration(
                hintText:
                    "e.g., Deep tissue preference, focus on lower back...",
                hintStyle: const TextStyle(fontSize: 16),
                filled: true,
                fillColor: const Color.fromARGB(255, 241, 237, 237),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ESTIMATED TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ESTIMATED TOTAL",
                      style: AppFonts.poppinsRegular(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: AppColors.primaryBlack40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹1200.00",
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 20,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),

                Text(
                  "Oct 5, 2023\n10:30 AM (60 min)",
                  textAlign: TextAlign.right,
                  style: AppFonts.poppinsRegular(fontSize: 12, color: AppColors.primaryBlack40),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //   builder: (context) =>  MyBookingsPage(),
                  //   ),
                  // );
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

                    SizedBox(width: 8),

                    Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //therapist card
  Widget therapistCard(String name, String role, String image) {
    bool isSelected = selectedTherapist == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTherapist = name;
        });
      },

      child: Column(
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
                  child: Image.asset(
                    image,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
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
            style: AppFonts.poppinsSemiBold(fontSize: 16),
          ),

          Text(role, style: AppFonts.poppinsRegular(fontSize: 11, color: AppColors.primaryBlack40)),
        ],
      ),
    );
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

    if (isDisabled) {
      borderColor = Colors.grey.shade300;
      backgroundColor = Colors.white;
      textColor = Colors.grey;
    } else if (isSelected) {
      borderColor = const Color(0xFFC9A14A);
      backgroundColor = const Color(0xFFF5E7C5); // light gold
      textColor = const Color(0xFFC9A14A);
    } else {
      borderColor = Colors.grey.shade300;
      backgroundColor = Colors.white;
      textColor = Colors.black87;
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