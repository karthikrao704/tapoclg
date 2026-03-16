import 'package:flutter/material.dart';

class FutureBookingCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final String icon;   

  const FutureBookingCard({
    super.key,
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [

          /// ICON BOX
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 254, 251),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              icon, 
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: const [

                    Text(
                      "Reschedule",
                      style: TextStyle(
                        color: Color.fromARGB(255, 216, 160, 38),
                        fontSize: 12.5,
                      ),
                    ),

                    SizedBox(width: 12),

                    Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color.fromARGB(255, 88, 87, 87),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// STATUS
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: status == "CONFIRMED"
                  ? Color(0xFFC9A14A)
                  : Color(0xFFC9A14A),

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}