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
    // 1. Central Responsive Matrix
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650;
    final hPadding = size.width * 0.05;

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
        // 2. Applied dynamic horizontal padding
        padding: EdgeInsets.symmetric(
          horizontal: hPadding,
          vertical: isSmallScreen ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              'How can we help you\ntoday?',
              style: AppFonts.poppinsSemiBold(
                color: AppTheme.primaryText,
                fontSize: isSmallScreen ? 20 : 24,
                height: 1.3,
              ),
            ),
            SizedBox(height: isSmallScreen ? 10 : 16),
            Text(
              'Search our knowledge base or get in touch with\nour wellness experts.',
              style: AppFonts.poppinsRegular(
                color: AppTheme.secondaryText,
                fontSize: isSmallScreen ? 13 : 15,
                height: 1.4,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildSearchBar(isSmallScreen),
            SizedBox(height: isSmallScreen ? 24 : 32),

            // Action Cards
            _buildActionCard(
              title: 'Frequently Asked Questions',
              subtitle: 'Quick answers to common inquiries',
              icon: Icons.contact_support_outlined,
              isSmallScreen: isSmallScreen,
              onTap: () {},
            ),
            _buildActionCard(
              title: 'Live Chat',
              subtitle: 'Instant support with our team (9 AM - 6 PM)',
              icon: Icons.forum_outlined,
              isSmallScreen: isSmallScreen,
              onTap: () {},
            ),
            _buildActionCard(
              title: 'Contact Support',
              subtitle: 'Submit a ticket for detailed help',
              icon: Icons.support_agent_outlined,
              isSmallScreen: isSmallScreen,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Feedback Section
            _buildFeedbackSection(isSmallScreen),
            SizedBox(height: isSmallScreen ? 24 : 32),

            // Contact Information Section
            Text(
              'Contact Information',
              style: AppFonts.poppinsSemiBold(
                color: AppTheme.primaryText,
                fontSize: isSmallScreen ? 16 : 18,
              ),
            ),
            SizedBox(height: isSmallScreen ? 10 : 16),
            _buildContactInfoGrid(isSmallScreen),
            SizedBox(height: isSmallScreen ? 24 : 32),

            // Navigation Links
            _buildNavigationLink('App Feedback', isSmallScreen: isSmallScreen),
            _buildNavigationLink(
              'Report a Technical Problem',
              isSmallScreen: isSmallScreen,
            ),
            _buildNavigationLink(
              'Wellness Service Guidelines',
              isSmallScreen: isSmallScreen,
              showDivider: false,
            ),

            SizedBox(height: isSmallScreen ? 24 : 32),
            _buildFooterBanner(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 4,
      ),
      child: TextField(
        controller: _searchController,
        style: AppFonts.poppinsRegular(
          fontSize: isSmallScreen ? 14 : 16,
          color: AppTheme.primaryText,
        ),
        decoration: InputDecoration(
          icon: Icon(
            Icons.search,
            color: AppColors.primaryColor,
            size: isSmallScreen ? 20 : 24,
          ),
          hintText: 'Search for topics, guides...',
          hintStyle: AppFonts.poppinsRegular(
            color: AppColors.primaryBlack40,
            fontSize: isSmallScreen ? 13 : 15,
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
    required bool isSmallScreen,
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
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 16 : 20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.poppinsSemiBold(
                        color: AppTheme.primaryText,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.poppinsRegular(
                        color: AppTheme.secondaryText,
                        fontSize: isSmallScreen ? 11 : 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF94A3B8),
                size: isSmallScreen ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1EADE), width: 1),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rate_review_outlined,
                color: const Color(0xFFCDA751),
                size: isSmallScreen ? 20 : 24,
              ),
              const SizedBox(width: 8),
              // 3. Extracted Text into Expanded to prevent row overflow
              Expanded(
                child: Text(
                  'Feedback Section',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppinsSemiBold(
                    color: AppTheme.primaryText,
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Your experience matters. Tell us how we can improve Tapovana Wellness.',
            style: AppFonts.poppinsRegular(
              color: AppTheme.secondaryText,
              fontSize: isSmallScreen ? 13 : 14,
              height: 1.4,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),

          Text(
            'Subject',
            style: AppFonts.poppinsSemiBold(
              color: AppTheme.primaryText,
              fontSize: isSmallScreen ? 13 : 14,
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
              style: AppFonts.poppinsRegular(
                fontSize: isSmallScreen ? 14 : 15,
                color: AppTheme.primaryText,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., App Improvement, Class Suggestion',
                hintStyle: AppFonts.poppinsRegular(
                  color: AppColors.primaryBlack40,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),

          Text(
            'Message',
            style: AppFonts.poppinsSemiBold(
              color: AppTheme.primaryText,
              fontSize: isSmallScreen ? 13 : 14,
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
              style: AppFonts.poppinsRegular(
                fontSize: isSmallScreen ? 14 : 15,
                color: AppTheme.primaryText,
              ),
              decoration: InputDecoration(
                hintText: "How can we help or what's on your mind?",
                hintStyle: AppFonts.poppinsRegular(
                  color: AppColors.primaryBlack40,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),

          SizedBox(
            width: double.infinity,
            // 4. Used minimumSize rather than strict height
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(double.infinity, isSmallScreen ? 44 : 50),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: Text(
                'Submit Request',
                style: AppFonts.poppinsSemiBold(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoGrid(bool isSmallScreen) {
    return Column(
      children: [
        _buildContactTile(
          icon: Icons.email_outlined,
          title: 'Email Us',
          subtitle: 'support@tapovana.com',
          iconColor: AppColors.primaryColor,
          isSmallScreen: isSmallScreen,
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.call_outlined,
          title: 'Call Us',
          subtitle: '+1 (800) TAPOVANA',
          iconColor: AppColors.primaryColor,
          isSmallScreen: isSmallScreen,
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.message_outlined,
          title: 'WhatsApp',
          subtitle: 'Chat with us',
          iconColor: const Color(0xFF10B981),
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: isSmallScreen ? 20 : 24),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              title,
              style: AppFonts.poppinsSemiBold(
                color: AppTheme.primaryText,
                fontSize: isSmallScreen ? 13 : 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppFonts.poppinsRegular(
                color: AppTheme.secondaryText,
                fontSize: isSmallScreen ? 11 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationLink(
    String title, {
    bool showDivider = true,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 12 : 16,
              horizontal: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 5. Defended against row overflow on long link names
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.poppinsMedium(
                      color: AppTheme.primaryText,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF94A3B8),
                  size: isSmallScreen ? 14 : 16,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _buildFooterBanner(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Container(
                width: isSmallScreen ? 110 : 140,
                height: isSmallScreen ? 110 : 140,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 24 : 32,
                horizontal: isSmallScreen ? 16 : 24,
              ),
              child: Column(
                children: [
                  Text(
                    'Tapovana Community',
                    style: AppFonts.poppinsSemiBold(
                      color: AppColors.primaryColor,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    'Join 50,000+ members on their journey to\npeace.',
                    textAlign: TextAlign.center,
                    style: AppFonts.poppinsRegular(
                      color: const Color(0xFF475569),
                      fontSize: isSmallScreen ? 11 : 13,
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
