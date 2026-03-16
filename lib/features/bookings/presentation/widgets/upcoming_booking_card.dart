import 'package:flutter/material.dart';

class UpcomingBookingCard extends StatefulWidget {
  const UpcomingBookingCard({super.key});

  @override
  State<UpcomingBookingCard> createState() => _UpcomingBookingCardState();
}

class _UpcomingBookingCardState extends State<UpcomingBookingCard> {
  bool isRescheduleSelected = true;
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            child: Image.asset(
              "assets/bookings/deeptissue.png",
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
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

                    const Text(
                      "Deep Tissue Revive",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:Color.fromARGB(255, 254, 246, 230),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "CONFIRMED",
                        style: TextStyle(
                          fontSize: 11,
                          color:const Color(0xFFC9A14A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// DATE
                Row(
                  children: const [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFFC9A14A),
                    ),

                    SizedBox(width: 6),

                    Text(
                      "Monday, Oct 24 • 10:00 AM",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 96, 103, 120),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// THERAPIST
                Row(
                  children: const [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Color(0xFFC9A14A),
                    ),

                    SizedBox(width: 6),

                    Text(
                      "Therapist: Sarah Jennings",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 96, 103, 120),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 27),

  Row(
    children: [

        /// RESCHEDULE
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isRescheduleSelected = true;
              });
            },
            child: Container(
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isRescheduleSelected
                    ? const Color(0xFFC9A14A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFC9A14A),
                ),
              ),
              child: Text(
                "Reschedule",
                style: TextStyle(
                  color: isRescheduleSelected
                      ? Colors.white
                      : const Color(0xFFC9A14A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

    /// CANCEL
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isRescheduleSelected = false;
                  });
                },
                child: Container(
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isRescheduleSelected
                        ? const Color(0xFFC9A14A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFC9A14A),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: !isRescheduleSelected
                          ? Colors.white
                          : const Color(0xFFC9A14A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
       
              ],
            ),
          ),
        ],
      ),
    );
  }

}