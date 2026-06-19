import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final serviceName = appointment['service_name'] ?? 'Unknown Service';
    final dateStr = appointment['date'] ?? 'Unknown Date';
    final timeStr = appointment['time'] ?? 'Unknown Time';
    final priceStr = appointment['price'] ?? 'Unknown Price';
    final therapistName = appointment['therapist'] ?? 'Unknown Therapist';
    final roomName = appointment['room'] ?? 'Unknown Room';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Appointment Details",
          style: AppFonts.headland(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                "Confirmed",
                style: AppFonts.poppinsSemiBold(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Service Name
            Text(
              serviceName,
              style: AppFonts.headland(
                fontSize: 26,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9F9F9),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F1F1),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: "Date",
                    value: dateStr,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: Colors.grey),
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.access_time,
                    label: "Time",
                    value: timeStr,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: Colors.grey),
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.person_outline,
                    label: "Therapist",
                    value: therapistName,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: Colors.grey),
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.room_preferences_outlined,
                    label: "Room",
                    value: roomName,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: Colors.grey),
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.payment,
                    label: "Amount Paid",
                    value: priceStr,
                    valueColor: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Reschedule / Cancel Buttons (Visual Only)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reschedule functionality coming soon!")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Reschedule Appointment",
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cancel functionality coming soon!")),
                  );
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Cancel Appointment",
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 16,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value, Color? valueColor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFC9A14A)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFonts.poppinsRegular(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color ?? Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppFonts.poppinsMedium(
                fontSize: 15,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
