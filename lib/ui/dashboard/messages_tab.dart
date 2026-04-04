import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../core/theme/app_theme.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.messages.isEmpty) {
          return const Center(child: Text('No messages yet', style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            final msg = provider.messages[index];
            final date = DateTime.tryParse(msg.timestamp) ?? DateTime.now();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: msg.priority ? AppTheme.warningStatus : (!msg.read ? AppTheme.primaryStatus : Colors.transparent),
                  width: msg.priority || !msg.read ? 2 : 1,
                ),
              ),
              color: !msg.read ? AppTheme.primaryStatus.withOpacity(0.05) : AppTheme.panelBg,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(msg.name.isEmpty ? 'Anonymous' : msg.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: Icon(msg.read ? Icons.mark_email_read : Icons.mail, 
                                     color: msg.read ? Colors.grey : AppTheme.primaryStatus, size: 20),
                          onPressed: () => provider.toggleMessageRead(msg.id, msg.read),
                        ),
                        IconButton(
                          icon: Icon(Icons.star, color: msg.priority ? AppTheme.warningStatus : Colors.grey, size: 20),
                          onPressed: () => provider.toggleMessagePriority(msg.id, msg.priority),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                          onPressed: () => _confirmDelete(context, provider, msg.id),
                        ),
                      ],
                    ),
                    Text('Subject: ${msg.subject}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(msg.email, style: TextStyle(color: AppTheme.primaryStatus, fontSize: 13)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                      child: Text(msg.message, style: const TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 8),
                    Text(DateFormat.yMMMd().add_jm().format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, DataProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerStatus),
            onPressed: () {
              provider.deleteMessage(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      )
    );
  }
}
