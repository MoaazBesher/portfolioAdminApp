import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/data_provider.dart';
import 'ui/dashboard/messages_tab.dart';

/// Route: '/messages'
///
/// This page is pushed when the admin taps a push notification.
/// It wraps the existing [MessagesTab] so there is a single source of truth
/// for message rendering. An optional [messageId] argument is accepted but
/// currently only used for scroll highlighting (future-proof hook).
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String? _highlightedMessageId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _highlightedMessageId = args['messageId'] as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        leading: const BackButton(),
      ),
      body: ChangeNotifierProvider.value(
        value: context.read<DataProvider>(),
        child: Builder(
          builder: (ctx) {
            // Trigger a data refresh when this page is opened from a notification.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ctx.read<DataProvider>().loadAllData();
            });

            if (_highlightedMessageId != null) {
              debugPrint('[MessagesPage] Highlighted messageId: $_highlightedMessageId');
            }

            return const MessagesTab();
          },
        ),
      ),
    );
  }
}
