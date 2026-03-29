import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class ServiceCardWidget extends StatelessWidget {
  final String title;
  final String image;
  final String price;

  const ServiceCardWidget({
    super.key,
    required this.title,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Image.asset(
              image,
              height: 95,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          /// TEXT AREA
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITLE
                Text(
                  title,
                  style: AppFonts.poppinsSemiBold(
                    color: AppTheme.primaryText,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 2),

                /// PRICE
                Text(
                  price,
                  style: AppFonts.poppinsSemiBold(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}