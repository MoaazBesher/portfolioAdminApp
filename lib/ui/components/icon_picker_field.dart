import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final Map<String, dynamic> commonIcons = {
  'graduation-cap': FontAwesomeIcons.graduationCap,
  'briefcase': FontAwesomeIcons.briefcase,
  'trophy': FontAwesomeIcons.trophy,
  'certificate': FontAwesomeIcons.certificate,
  'code': FontAwesomeIcons.code,
  'laptop': FontAwesomeIcons.laptop,
  'star': FontAwesomeIcons.star,
  'medal': FontAwesomeIcons.medal,
  'award': FontAwesomeIcons.award,
  'building': FontAwesomeIcons.building,
  'chart-line': FontAwesomeIcons.chartLine,
  'users': FontAwesomeIcons.users,
  'check': FontAwesomeIcons.check,
  'hammer': FontAwesomeIcons.hammer,
  'crown': FontAwesomeIcons.crown,
  'terminal': FontAwesomeIcons.terminal,
  'globe': FontAwesomeIcons.globe,
  'book': FontAwesomeIcons.book,
  'pen': FontAwesomeIcons.pen,
  'palette': FontAwesomeIcons.palette,
  'camera': FontAwesomeIcons.camera,
  'video': FontAwesomeIcons.video,
  'database': FontAwesomeIcons.database,
  'server': FontAwesomeIcons.server,
  'mobile': FontAwesomeIcons.mobile,
  'flask': FontAwesomeIcons.flask,
  'bolt': FontAwesomeIcons.bolt,
};

class IconPickerField extends StatefulWidget {
  final String label;
  final String initialValue;
  final void Function(String) onChanged;

  const IconPickerField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<IconPickerField> createState() => _IconPickerFieldState();
}

class _IconPickerFieldState extends State<IconPickerField> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Choose an Icon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: commonIcons.length,
                itemBuilder: (context, index) {
                  final key = commonIcons.keys.elementAt(index);
                  final iconData = commonIcons[key];
                  final isSelected = key == _currentValue;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _currentValue = key;
                      });
                      widget.onChanged(key);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor.withAlpha(50) : Colors.transparent,
                        border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withAlpha(50)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: FaIcon(iconData, color: isSelected ? Theme.of(context).primaryColor : Colors.white)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: _showPicker,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            filled: true,
            fillColor: Colors.white.withAlpha(10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withAlpha(20), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_currentValue.isEmpty ? 'Tap to select an icon' : _currentValue),
              FaIcon((commonIcons[_currentValue] as dynamic) ?? FontAwesomeIcons.circleQuestion, size: 20, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
