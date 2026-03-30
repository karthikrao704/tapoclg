import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/secondary_app_bar.dart';

class SupportCenterPage extends StatelessWidget {
  const SupportCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: SupportCenterView(),
    );
  }
}

class SupportCenterView extends StatefulWidget {
  const SupportCenterView({super.key});

  @override
  State<SupportCenterView> createState() => _SupportCenterViewState();
}

class _SupportCenterViewState extends State<SupportCenterView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: SecondaryAppBar(
        title: 'Support Center',
        centerTitle: false,
        titleSpacing: 0,
        showSearch: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              'How can we help you\ntoday?',
              style: AppFonts.poppinsSemiBold(
                color: AppTheme.primaryText,
                fontSize: 24,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Search our knowledge base or get in touch with\nour wellness experts.',
              style: AppFonts.poppinsRegular(
                color: AppTheme.secondaryText,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 32),

            // Action Cards
            _buildActionCard(
              title: 'Frequently Asked Questions',
              subtitle: 'Quick answers to common inquiries',
              icon: Icons.contact_support_outlined,
              onTap: () {},
            ),
            _buildActionCard(
              title: 'Live Chat',
              subtitle: 'Instant support with our team (9 AM - 6 PM)',
              icon: Icons.forum_outlined,
              onTap: () {},
            ),
            _buildActionCard(
              title: 'Contact Support',
              subtitle: 'Submit a ticket for detailed help',
              icon: Icons.support_agent_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Feedback Section
            _buildFeedbackSection(),
            const SizedBox(height: 32),

            // Contact Information Section
            Text(
              'Contact Information',
              style: AppFonts.poppinsSemiBold(
                color: AppTheme.primaryText,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactInfoGrid(),
            const SizedBox(height: 32),

            // Navigation Links
            _buildNavigationLink('App Feedback'),
            _buildNavigationLink('Report a Technical Problem'),
            _buildNavigationLink('Wellness Service Guidelines', showDivider: false),

            const SizedBox(height: 32),
            _buildFooterBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: AppColors.primaryColor, size: 24),
          hintText: 'Search for topics, guides...',
          hintStyle: AppFonts.poppinsRegular(
            color: AppColors.primaryBlack40,
            fontSize: 15,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.poppinsSemiBold(
                        color: AppTheme.primaryText,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppFonts.poppinsRegular(
                        color: AppTheme.secondaryText,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1EADE), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined, color: Color(0xFFCDA751), size: 24),
              const SizedBox(width: 8),
              Text(
                'Feedback Section',
                style: AppFonts.poppinsSemiBold(
                  color: AppTheme.primaryText,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your experience matters. Tell us how we can improve Tapovana Wellness.',
            style: AppFonts.poppinsRegular(
              color: AppTheme.secondaryText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Subject',
            style: AppFonts.poppinsSemiBold(
              color: AppTheme.primaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'e.g., App Improvement, Class Suggestion',
                hintStyle: AppFonts.poppinsRegular(color: AppColors.primaryBlack40, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Message',
            style: AppFonts.poppinsSemiBold(
              color: AppTheme.primaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "How can we help or what's on your mind?",
                hintStyle: AppFonts.poppinsRegular(color: AppColors.primaryBlack40, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: Text(
                'Submit Request',
                style: AppFonts.poppinsSemiBold(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoGrid() {
    return Column(
      children: [
        _buildContactTile(
          icon: Icons.email_outlined,
          title: 'Email Us',
          subtitle: 'support@tapovana.com',
          iconColor: AppColors.primaryColor,
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.call_outlined,
          title: 'Call Us',
          subtitle: '+1 (800) TAPOVANA',
          iconColor: AppColors.primaryColor,
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.message_outlined,
          title: 'WhatsApp',
          subtitle: 'Chat with us',
          iconColor: const Color(0xFF10B981), // Green color matching screenshot
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppFonts.poppinsSemiBold(
                color: AppTheme.primaryText,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppFonts.poppinsRegular(
                color: AppTheme.secondaryText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationLink(String title, {bool showDivider = true}) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppFonts.poppinsMedium(
                    color: AppTheme.primaryText,
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF94A3B8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
      ],
    );
  }

  Widget _buildFooterBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF4), // Light gold tint
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background watermark circle
            Positioned(
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Tapovana Community',
                    style: AppFonts.poppinsSemiBold(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join 50,000+ members on their journey to\npeace.',
                    textAlign: TextAlign.center,
                    style: AppFonts.poppinsRegular(
                      color: const Color(0xFF475569), // Slate 600
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}