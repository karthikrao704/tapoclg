import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/components/appointment_card.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/components/custom_button.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/components/service_card.dart';
import 'package:tapovana_mobile_app/features/home_page/presentation/components/tip_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main UI Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tip Card
              const SizedBox(height: 20),
              const TipCard(
                tipText:
                    "Stay hydrated today. Drinking 8 glasses of water helps maintain your skin's natural glow and boosts energy levels.",
              ),

              // Featured Services Section
              const SizedBox(height: 30),

              // Refactored: Allows the title to scale and "View All" to remain safe
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      "Featured Services",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "View All",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Refactored: Replaced SizedBox(width) with Expanded for fluid scaling
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Handles dynamic text heights cleanly
                children: const [
                  Expanded(
                    child: ServiceCard(
                      imagePath: "assets/images/example_service1.png",
                      tagLabel: "300+ Users",
                      serviceName: "Aromatherapy",
                      duration: "60 mins",
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ), // Slightly reduced for better fit on tiny screens
                  Expanded(
                    child: ServiceCard(
                      imagePath: "assets/images/example_service2.png",
                      tagLabel: "Popular",
                      serviceName: "Hot Stone Massage",
                      duration: "90 mins",
                    ),
                  ),
                ],
              ),

              // Upcoming Appointments Section
              const SizedBox(height: 30),
              Text(
                "Upcoming Appointments",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const AppointmentCard(
                month: "OCT",
                day: "24",
                title: "Swedish Massage",
                doctorName: "with Dr. Sarah Wilson",
                time: "10:30 AM",
                room: "Room 204",
              ),

              // Buttons
              const SizedBox(height: 20),
              Row(
                // Intentionally using intrinsic heights or start alignment
                // in case button text wraps on high accessibility settings
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomButton(
                      icon: Icons.edit_calendar,
                      label: "Book Service",
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      icon: Icons.message_outlined,
                      isPrimary: false,
                      label: "Support",
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              // Extra spacing at the bottom
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
