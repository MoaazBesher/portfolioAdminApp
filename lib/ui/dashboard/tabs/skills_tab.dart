import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../components/custom_text_field.dart';

class SkillsTab extends StatefulWidget {
  const SkillsTab({super.key});

  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {
  late Map<String, List<Skill>> skills;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DataProvider>();
    skills = _copySkills(provider.skills);
    provider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    context.read<DataProvider>().removeListener(_onProviderChange);
    super.dispose();
  }

  void _onProviderChange() {
    final provider = context.read<DataProvider>();
    setState(() {
      skills = _copySkills(provider.skills);
    });
  }

  Map<String, List<Skill>> _copySkills(Map<String, List<Skill>> source) {
    return {
      'technical': List<Skill>.from(source['technical'] ?? []),
      'soft': List<Skill>.from(source['soft'] ?? []),
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
                  skills[category]!.add(Skill(name: name, value: int.parse(value)));
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

  void _editSkill(String category, int index) {
    final skill = skills[category]![index];
    String name = skill.name;
    String value = skill.value.toString();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${category.toUpperCase()} Skill'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'Skill Name', initialValue: name, isRequired: true, onSaved: (v) => name = v!),
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
                  skills[category]![index] = Skill(name: name, value: int.parse(value));
                });
                context.read<DataProvider>().updateSkills(skills);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteSkill(String category, int index) {
    setState(() {
      skills[category]!.removeAt(index);
    });
    context.read<DataProvider>().updateSkills(skills);
  }

  void _reorderSkill(String category, int oldIndex, int newIndex) {
    setState(() {
      final list = skills[category]!;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    });
    context.read<DataProvider>().updateSkills(skills);
  }

  Widget _buildSkillCategory(String category) {
    final catSkills = skills[category] ?? [];
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
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: catSkills.length,
              onReorder: (oldIndex, newIndex) => _reorderSkill(category, oldIndex, newIndex),
              proxyDecorator: (child, index, animation) => Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: child,
              ),
              itemBuilder: (context, index) {
                final skill = catSkills[index];
                return ListTile(
                  key: ValueKey(skill.name),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.drag_handle, color: Colors.grey),
                  title: Text(skill.name),
                  subtitle: LinearProgressIndicator(value: skill.value / 100),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${skill.value}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                        onPressed: () => _editSkill(category, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                        onPressed: () => _deleteSkill(category, index),
                      ),
                    ],
                  ),
                );
              },
            ),
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
