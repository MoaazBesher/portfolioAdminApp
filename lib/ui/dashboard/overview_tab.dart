import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/data_provider.dart';
import '../../core/theme/app_theme.dart';

class OverviewTab extends StatelessWidget {
  final void Function(int)? onNavigate;
  
  const OverviewTab({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final int totalSkills = (provider.skills['technical']?.length ?? 0) + (provider.skills['soft']?.length ?? 0);

        return RefreshIndicator(
          onRefresh: provider.loadAllData,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text('Dashboard Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // Prominent Hero Section for Messages & Views
              Row(
                children: [
                  Expanded(
                    child: _buildProminentCard(
                      title: 'Unread Messages',
                      value: provider.unreadMessagesCount.toString(),
                      icon: Icons.mail_rounded,
                      color: provider.unreadMessagesCount > 0 ? AppTheme.dangerStatus : AppTheme.successStatus,
                      onTap: () => onNavigate?.call(1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProminentCard(
                      title: 'Total Profile Views',
                      value: provider.profileViews.toString(),
                      icon: Icons.remove_red_eye_rounded,
                      color: AppTheme.primaryStatus,
                      onTap: () async {
                        String rawUrl = provider.settings.profileViewsUrl.trim();
                        if (rawUrl.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a Target Link in the Settings Tab first.')));
                           return;
                        }
                        if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
                          rawUrl = 'https://$rawUrl';
                        }
                        final url = Uri.parse(rawUrl);
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch(e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch URL. Is it a valid link?')));
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Content Managers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 16),
              // Grid View for the rest
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 800 ? 4 : constraints.maxWidth > 600 ? 3 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth > 600 ? 1.0 : 1.15,
                    children: [
                      _buildStatCard('Projects', provider.projects.length.toString(), Icons.code, AppTheme.primaryStatus, onTap: () => onNavigate?.call(3)),
                      _buildStatCard('Experience', provider.experience.length.toString(), Icons.work, AppTheme.warningStatus, onTap: () => onNavigate?.call(4)),
                      _buildStatCard('Education', provider.education.length.toString(), Icons.school, AppTheme.educationStatus, onTap: () => onNavigate?.call(5)),
                      _buildStatCard('Certificates', provider.certificates.length.toString(), Icons.verified, AppTheme.successStatus, onTap: () => onNavigate?.call(6)),
                      _buildStatCard('Achievements', provider.achievements.length.toString(), Icons.emoji_events, Colors.orangeAccent, onTap: () => onNavigate?.call(7)),
                      _buildStatCard('Skills', totalSkills.toString(), Icons.star, Colors.pinkAccent, onTap: () => onNavigate?.call(8)),
                    ],
                  );
                }
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProminentCard({required String title, required String value, required IconData icon, required Color color, VoidCallback? onTap}) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(50), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withAlpha(20), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 36),
                  if (onTap != null) Icon(Icons.arrow_forward_ios, color: Colors.grey.withAlpha(100), size: 16),
                ],
              ),
              const SizedBox(height: 24),
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  if (onTap != null) Icon(Icons.arrow_outward, color: Colors.grey.withAlpha(100), size: 16),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
