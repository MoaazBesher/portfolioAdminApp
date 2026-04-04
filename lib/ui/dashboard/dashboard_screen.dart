import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/app_models.dart';
import '../../services/firebase_service.dart';
import '../auth/login_screen.dart';

import 'overview_tab.dart';
import 'messages_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/experience_tab.dart';
import 'tabs/education_tab.dart';
import 'tabs/certificates_tab.dart';
import 'tabs/achievements_tab.dart';
import 'tabs/skills_tab.dart';
import 'tabs/settings_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<int> _navigationHistory = [0];

  void _navigateTo(int idx) {
    if (_currentIndex == idx) return;
    setState(() {
      _currentIndex = idx;
      _navigationHistory.add(idx);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAllData();
    });
  }

  void _logout() async {
    await FirebaseService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Widget _buildBody() {
    return [
      OverviewTab(onNavigate: _navigateTo),
      const MessagesTab(),
      const ProfileTab(),
      const ProjectsTab(),
      const ExperienceTab(),
      const EducationTab(),
      const CertificatesTab(),
      const AchievementsTab(),
      const SkillsTab(),
      const SettingsTab(),
    ][_currentIndex];
  }

  final List<String> _tabTitles = [
    'Overview', 'Messages', 'Profile Info', 'Projects', 
    'Experience', 'Education', 'Certificates', 'Achievements', 
    'Skills', 'Settings'
  ];

  @override
  Widget build(BuildContext context) {
    final unread = context.select<DataProvider, int>((p) => p.unreadMessagesCount);
    // Fetch profile for the Drawer header
    final profile = context.select<DataProvider, AppProfile>((p) => p.profile);
    
    return PopScope(
      canPop: _navigationHistory.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _navigationHistory.removeLast();
          _currentIndex = _navigationHistory.last;
        });
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          _navigateTo(idx);
          Navigator.pop(context); // Close the drawer
        },
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profile.coverImage.isNotEmpty 
                      ? NetworkImage(profile.coverImage) 
                      : null,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: profile.coverImage.isEmpty 
                      ? const Icon(Icons.person, color: Colors.white, size: 30) 
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.isNotEmpty ? profile.name : 'Admin User',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'mo3azbe4er@gmail.com',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const NavigationDrawerDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Overview')),
          NavigationDrawerDestination(
            icon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.mail_outline)),
            selectedIcon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.mail)),
            label: const Text('Messages'),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(28, 16, 28, 8), child: Divider()),
          const Padding(padding: EdgeInsets.fromLTRB(28, 0, 28, 8), child: Text('Content', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          const NavigationDrawerDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile Info')),
          const NavigationDrawerDestination(icon: Icon(Icons.computer_outlined), selectedIcon: Icon(Icons.computer), label: Text('Projects')),
          const NavigationDrawerDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: Text('Experience')),
          const NavigationDrawerDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: Text('Education')),
          const NavigationDrawerDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified), label: Text('Certificates')),
          const NavigationDrawerDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: Text('Achievements')),
          const NavigationDrawerDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: Text('Skills')),
          const Padding(padding: EdgeInsets.fromLTRB(28, 16, 28, 8), child: Divider()),
          const NavigationDrawerDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
        ],
      ),
      body: _buildBody(),
    ));
  }
}
