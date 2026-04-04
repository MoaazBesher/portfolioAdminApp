import 'package:flutter/material.dart';

class GenericListTab<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final VoidCallback onAddPressed;
  final String emptyMessage;

  const GenericListTab({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.onAddPressed,
    this.emptyMessage = 'No items found. Add one!',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddPressed,
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) => itemBuilder(context, items[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable confirm delete dialog
Future<bool> showConfirmDelete(BuildContext context, String title) async {
  return await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Text('Are you sure you want to delete "$title"?\nThis cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  ) ?? false;
}
