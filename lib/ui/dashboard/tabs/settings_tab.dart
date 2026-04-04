import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../components/custom_text_field.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _formKey = GlobalKey<FormState>();
  
  late String siteTitle, defaultTheme, theme, profileViewsUrl;
  late int itemsPerPage;
  late String featuredProjects;

  @override
  void initState() {
    super.initState();
    final settings = context.read<DataProvider>().settings;
    siteTitle = settings.siteTitle;
    defaultTheme = settings.defaultTheme;
    theme = settings.theme;
    profileViewsUrl = settings.profileViewsUrl;
    itemsPerPage = settings.itemsPerPage;
    featuredProjects = settings.featuredProjects.join(', ');
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedSettings = AppSettings(
        siteTitle: siteTitle, 
        defaultTheme: defaultTheme, 
        theme: theme, 
        profileViewsUrl: profileViewsUrl,
        itemsPerPage: itemsPerPage, 
        featuredProjects: featuredProjects.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      );
      context.read<DataProvider>().updateSettings(updatedSettings);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!', style: TextStyle(color: Colors.white))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Global Site Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                CustomTextField(label: 'Website Title', initialValue: siteTitle, isRequired: true, onSaved: (v) => siteTitle = v!),
                CustomTextField(label: 'Default Theme (e.g. dark or light)', initialValue: defaultTheme, onSaved: (v) => defaultTheme = v!),
                CustomTextField(label: 'Current Theme Override', initialValue: theme, onSaved: (v) => theme = v!),
                CustomTextField(
                  label: 'Items Per Page (Pagination limit)', 
                  initialValue: itemsPerPage.toString(), 
                  isRequired: true, 
                  onSaved: (v) => itemsPerPage = int.tryParse(v ?? '6') ?? 6,
                ),
                CustomTextField(
                  label: 'Featured Projects IDs (Comma Separated)', 
                  initialValue: featuredProjects, 
                  maxLines: 2, 
                  onSaved: (v) => featuredProjects = v!,
                ),
                CustomTextField(
                  label: 'Profile Views Target Link (ex: Google Analytics URL)', 
                  initialValue: profileViewsUrl, 
                  onSaved: (v) => profileViewsUrl = v!,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
