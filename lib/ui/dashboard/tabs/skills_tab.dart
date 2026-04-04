import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/data_provider.dart';
import '../../components/custom_text_field.dart';

class SkillsTab extends StatefulWidget {
  const SkillsTab({super.key});

  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {
  late Map<String, Map<String, int>> skills;

  @override
  void initState() {
    super.initState();
    // Copy to allow local edits
    final source = context.read<DataProvider>().skills;
    skills = {
      'technical': Map<String, int>.from(source['technical'] ?? {}),
      'soft': Map<String, int>.from(source['soft'] ?? {}),
    };
  }

  void _addSkill(String category) {
    String name = '';
    String value = '50';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${category.toUpperCase()} Skill'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'Skill Name', isRequired: true, onSaved: (v) => name = v!),
              CustomTextField(
                label: 'Proficiency (%)', 
                initialValue: value, 
                isRequired: true, 
                onSaved: (v) => value = v!,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Must be a number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                setState(() {
                  skills[category]![name] = int.parse(value);
                });
                context.read<DataProvider>().updateSkills(skills);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteSkill(String category, String name) {
    setState(() {
      skills[category]!.remove(name);
    });
    context.read<DataProvider>().updateSkills(skills);
  }

  Widget _buildSkillCategory(String category) {
    final catSkills = skills[category] ?? {};
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${category.toUpperCase()} SKILLS', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                  onPressed: () => _addSkill(category),
                ),
              ],
            ),
            const Divider(),
            if (catSkills.isEmpty) const Text('No skills added.', style: TextStyle(color: Colors.grey)),
            ...catSkills.entries.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(e.key),
              subtitle: LinearProgressIndicator(value: e.value / 100),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${e.value}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteSkill(category, e.key),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Skills Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildSkillCategory('technical'),
            _buildSkillCategory('soft'),
          ],
        ),
      ),
    );
  }
}
