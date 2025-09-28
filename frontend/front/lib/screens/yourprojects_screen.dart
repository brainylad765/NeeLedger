import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/upload_provider.dart';

class YourProjectsScreen extends StatefulWidget {
  YourProjectsScreen({Key? key}) : super(key: key);
  static const routeName = '/your-projects';

  @override
  State<YourProjectsScreen> createState() => _YourProjectsScreenState();
}

class _YourProjectsScreenState extends State<YourProjectsScreen> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (context, provider, child) {
        if (provider.projects.isEmpty && !_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('No Projects'),
                content: const Text(
                  'No files uploaded. Initiate by uploading your files in uploads section.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Your Projects')),
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.projects.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (ctx, i) {
              final name = provider.projects[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                leading: const CircleAvatar(child: Icon(Icons.work)),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Status: Pending\n2025-09-10',
                  maxLines: 2,
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // push to project detail in future
                },
              );
            },
          ),
        );
      },
    );
  }
}
