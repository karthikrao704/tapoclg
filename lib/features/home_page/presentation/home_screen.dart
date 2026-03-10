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
      // AppBar with Greeting and User Name
      // appBar: CustomAppBar(
      //   greetingMessage: "Good Morning",
      //   userName: "Shelton Coutinho",
      // ),

      // Main UI Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              // Tip Card
              const SizedBox(height: 20),
              TipCard(
                tipText:
                    "Stay hydrated today. Drinking 8 glasses of water helps maintain your skin's natural glow and boosts energy levels.",
              ),

              // Featured Services Section
              const SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    "Featured Services",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    "View All",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 170,
                    child: ServiceCard(
                      imagePath: "assets/images/example_service1.png",
                      tagLabel: "300+ Users",
                      serviceName: "Aromatherapy",
                      duration: "60 mins",
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 170,
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
              Row(
                children: [
                  Text(
                    "Upcoming Appointments",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppointmentCard(
                month: "OCT",
                day: "24",
                title: "Swedish Massage",
                doctorName: "with Dr. Sarah Wilson",
                time: "10:30 AM",
                room: "Room 204",
              ),

              // Button
              const SizedBox(height: 30),
              Row(
                children: [
                  CustomButton(
                    icon: Icons.edit_calendar,
                    label: "Book Service",
                    onPressed: () {
                      // Handle button press
                    },
                  ),
                  const Spacer(),
                  CustomButton(
                    icon: Icons.message_outlined,
                    isPrimary: false,
                    label: "Book Service",
                    onPressed: () {
                      // Handle button press
                    },
                  ),
                ],
              ),

              // Extra spacing at the bottom
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // bottomNavigationBar
      // bottomNavigationBar: CustomBottomNavbar(
      //   currentIndex: 0,
      //   onTap: (index) {
      //     // Handle navigation tap
      //   },
      // ),
    );
  }
}
