import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/appointments/presentation/pages/appointment_booking_page.dart';
import 'package:tapovana_mobile_app/features/service_details/presentation/widgets/benefit_item.dart';
import 'package:tapovana_mobile_app/features/service_details/presentation/widgets/service_card_widget.dart';

class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(  
      backgroundColor: const Color(0xFFFFFFFF),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Service Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.share_outlined, color: Colors.black),
          )
        ],
      ),

      body: SingleChildScrollView(
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
                  child: Image.asset(
                    "assets/service/swedish_image.png",
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
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
                      color: const Color(0xFFC9A14A),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: const Text(
                      "SIGNATURE TREATMENT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                /// TITLE
                const Positioned(
                  left: 20,
                  bottom: 30,
                  child: Text(
                    "Swedish Massage",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
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
                          offset: Offset(0,4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        /// DURATION
                        Column(
                          children: const [
                            Icon(Icons.access_time,
                                color: Color(0xFFC9A14A), size: 26),
                            SizedBox(height: 2),
                            Text(
                              "DURATION",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              "60 Minutes",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
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
                          children: const [
                            Icon(Icons.payments_outlined,
                                color: Color(0xFFC9A14A), size: 26),
                            SizedBox(height: 2),
                            Text(
                              "STARTING PRICE",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              "₹500.00",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
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

                    /// ABOUT TREATMENT
                    // const Text(
                    //   "About Treatment",
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.w700,
                    //     fontSize: 16,
                    //   ),
                    // ),
                    sectionHeader("About Treatment"),

                    const SizedBox(height: 8),

                    const Text(
                      "Our Swedish Massage is the foundation of relaxation therapy. Using long, gliding strokes in the direction of blood returning to the heart, this classic treatment is designed to relax the entire body. Beyond relaxation, it is exceptionally beneficial for increasing the level of oxygen in the blood, decreasing muscle toxins, and improving circulation.",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        height: 1.5,
                        fontSize: 17
                      ),
                    ),

                    const SizedBox(height: 80),

                    /// KEY BENEFITS
                    // const Text(
                    //   "Key Benefits",
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.w700,
                    //     fontSize: 16,
                    //   ),
                    // ),
                    sectionHeader("Key Benefits"),

                    const SizedBox(height: 14),


                    BenefitItem(
                      title: "Stress Reduction",
                      subtitle: "Lowers cortisol levels and promotes emotional well-being.",
                    ),

                    BenefitItem(
                      title: "Improved Flexibility",
                      subtitle: "Gentle stretching techniques improve joint range of motion.",
                    ),

                    BenefitItem(
                      title: "Pain Management",
                      subtitle: "Relieves muscle tension and helps manage localized muscle pain.",
                    ),

                    const SizedBox(height: 70),

                    /// WHAT TO EXPECT
                    sectionHeader("What to Expect"),

                    const SizedBox(height: 14),

                    expectItem(1,"Arrival and consultation with our certified therapist to discuss your pressure preferences."),
                    expectItem(2,"Transition to aromatherapy-infused treatment room with soft lighting and ambient music."),
                    expectItem(3,"A full 60-minute session using premium organic oils tailored  to your skin type."),

                    const SizedBox(height: 24),

                    /// YOU MIGHT ALSO LIKE
                    const Text(
                      "You might also like",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        Expanded(
                          child: ServiceCardWidget(
                            title: "Deep Tissue",
                            image: "assets/service/deep_tissue.png",
                            price: "\$140.00",
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ServiceCardWidget(
                            title: "Aromatherapy",
                            image: "assets/service/aromatherapy.png",
                            price: "\$130.00",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
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
                        builder: (context) =>  AppointmentBookingPage(),
                      ),
                    );
                    },
                
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A14A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.calendar_month_outlined, size: 25),
                      SizedBox(width: 8),
                      Text(
                        "Book Appointment",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  )
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

          ),
        ),
      ),
    );
  }

 
  /// EXPECT ITEM
Widget expectItem(int number, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// NUMBER BOX
        Container(
          width: 33,
          height: 33,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFC9A14A),
            borderRadius: BorderRadius.circular(11), // square with rounded edges
          ),
          child: Text(
            number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 12),

        /// TEXT
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}


Widget sectionHeader(String title) {
  return Row(
    children: [
      Container(
        width: 35,
        height: 1.5,
        decoration: BoxDecoration(
          color: const Color(0xFFC9A14A),
          borderRadius: BorderRadius.circular(2),
        ),
      ),

      const SizedBox(width: 8),

      Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
}