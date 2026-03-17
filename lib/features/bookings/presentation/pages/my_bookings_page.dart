import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/appointments/presentation/pages/appointment_booking_page.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/widgets/future_booking_card.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/widgets/upcoming_booking_card.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {

  int selectedTab = 1; // 0 = upcoming , 1 = completed

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "My Bookings",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [

          /// TOGGLE TAB
          Container(
            color: Colors.white,
            child: Row(
              children: [

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 0;
                      });
                    },
                    child: Column(
                      children: [

                        const SizedBox(height: 14),

                        Text(
                          "Upcoming",
                          style: TextStyle(
                            color: selectedTab == 0
                                ? const Color(0xFFC9A14A)
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          height: 2,
                          color: selectedTab == 0
                              ? const Color(0xFFC9A14A)
                              : Colors.transparent,
                        )
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 1;
                      });
                    },
                    child: Column(
                      children: [

                        const SizedBox(height: 14),

                        Text(
                          "Completed",
                          style: TextStyle(
                            color: selectedTab == 1
                                ? const Color(0xFFC9A14A)
                                : const Color.fromARGB(255, 132, 132, 132),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          height: 2,
                          color: selectedTab == 1
                              ? const Color(0xFFC9A14A)
                              : Colors.transparent,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          /// BOOKINGS LIST
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (selectedTab == 0) ...[
                    const Text(
                      "IMMEDIATE NEXT",
                      style: TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 1.2,
                        color: Color(0xFFC9A14A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const UpcomingBookingCard(),

                    const SizedBox(height: 35),

                    const Text(
                      "FUTURE APPOINTMENTS",
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 1.2,
                        color: Color(0xFFC9A14A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                   FutureBookingCard(
                    title: "Vedic Aromatherapy",
                    time: "Nov 02 • 02:30 PM",
                    status: "PENDING",
                    icon: "assets/bookings/leaf.png",
                  ),

                  const SizedBox(height: 12),

                  FutureBookingCard(
                    title: "Private Yoga Session",
                    time: "Nov 15 • 08:00 AM",
                    status: "CONFIRMED",
                    icon: "assets/bookings/yoga.png",
                  ),
                  ],

                  if (selectedTab == 1) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Text(
                          "No completed bookings yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}