import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/model_catalog.dart';
import '../models/model_manager.dart';
import '../processing/transcription_queue.dart';

class ModelsScreen extends ConsumerWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modelManagerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ReXorder never downloads model files. Download them from the '
            'official links, then import them from local storage.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Speaker detection is optional. Import both speaker models to enable it.',
          ),
          const SizedBox(height: 12),
          for (final model in modelCatalog)
            _ModelCard(
              model: model,
              installed: state.installedModelIds.contains(model.id),
              progress:
                  state.currentModelId == model.id &&
                  state.phase == ModelImportPhase.importing,
              bytesRead: state.bytesRead,
              totalBytes: state.totalBytes,
              busy:
                  state.phase == ModelImportPhase.picking ||
                  state.phase == ModelImportPhase.importing,
            ),
          if (state.isLoading) const LinearProgressIndicator(),
          if (state.message != null) ...[
            const SizedBox(height: 8),
            Text(
              state.message!,
              style: TextStyle(
                color: state.phase == ModelImportPhase.failure
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModelCard extends ConsumerWidget {
  const _ModelCard({
    required this.model,
    required this.installed,
    required this.progress,
    required this.bytesRead,
    required this.totalBytes,
    required this.busy,
  });

  final CatalogModel model;
  final bool installed;
  final bool progress;
  final int bytesRead;
  final int totalBytes;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(modelManagerProvider.notifier);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          model.displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (model.id == 'sense-voice') ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('Recommended'),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          labelPadding: EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(installed ? 'Installed' : 'Not installed'),
              ],
            ),
            const SizedBox(height: 4),
            Text('${model.type.name} · ${formatModelSize(model.sizeBytes)}'),
            if (progress) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: totalBytes > 0 ? bytesRead / totalBytes : null,
              ),
              const SizedBox(height: 4),
              Text(
                '${formatModelSize(bytesRead)} / ${formatModelSize(totalBytes)}',
              ),
            ],
            Wrap(
              spacing: 4,
              runSpacing: 0,
              children: [
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(model.url),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Open download link'),
                ),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: model.url));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied')),
                      );
                    }
                  },
                  child: const Text('Copy link'),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () async {
                          await controller.importModel(model);
                          await ref
                              .read(transcriptionQueueProvider)
                              .processQueue();
                        },
                  child: const Text('Import…'),
                ),
                if (installed)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => controller.deleteModel(model),
                    child: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
