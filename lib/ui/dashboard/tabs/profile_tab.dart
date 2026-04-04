import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../components/custom_text_field.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  
  late String name, title, bio, greeting, email, phone, whatsapp, linkedin, coverImage, resume;

  @override
  void initState() {
    super.initState();
    final profile = context.read<DataProvider>().profile;
    name = profile.name;
    title = profile.title;
    bio = profile.bio;
    greeting = profile.greeting;
    email = profile.email;
    phone = profile.phone;
    whatsapp = profile.whatsapp;
    linkedin = profile.linkedin;
    coverImage = profile.coverImage;
    resume = profile.resume;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedProfile = AppProfile(
        name: name, title: title, bio: bio, greeting: greeting,
        email: email, phone: phone, whatsapp: whatsapp, linkedin: linkedin,
        coverImage: coverImage, resume: resume,
      );
      context.read<DataProvider>().updateProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Saved Successfully!', style: TextStyle(color: Colors.white))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveProfile,
        icon: const Icon(Icons.save),
        label: const Text('Save Changes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profile Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  CustomTextField(label: 'Full Name', initialValue: name, isRequired: true, onSaved: (v) => name = v!),
                  CustomTextField(label: 'Job Title', initialValue: title, isRequired: true, onSaved: (v) => title = v!),
                  CustomTextField(label: 'Greeting Alert/Tag', initialValue: greeting, onSaved: (v) => greeting = v!),
                  CustomTextField(label: 'About Bio', initialValue: bio, maxLines: 5, onSaved: (v) => bio = v!),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Contact Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  
                  CustomTextField(label: 'Contact Email', initialValue: email, onSaved: (v) => email = v!),
                  CustomTextField(label: 'Phone Number', initialValue: phone, onSaved: (v) => phone = v!),
                  CustomTextField(label: 'WhatsApp Number (Intl Format)', initialValue: whatsapp, onSaved: (v) => whatsapp = v!),
                  CustomTextField(label: 'LinkedIn Profile Link', initialValue: linkedin, onSaved: (v) => linkedin = v!),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Assets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  CustomTextField(label: 'Hero Profile Image URL', initialValue: coverImage, onSaved: (v) => coverImage = v!),
                  CustomTextField(label: 'Resume PDF Link', initialValue: resume, onSaved: (v) => resume = v!),
                  const SizedBox(height: 80), // Padding for FAB
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
