import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../domain/search_hit.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  Timer? _debounce;
  String _query = '';
  List<SearchHit> _hits = const [];
  bool _searching = false;
  int _requestId = 0;

  void _onChanged(String value) {
    final query = value.trim();
    _query = query;
    _debounce?.cancel();
    final requestId = ++_requestId;
    if (query.isEmpty) {
      setState(() {
        _hits = const [];
        _searching = false;
      });
      return;
    }
    setState(() {
      _hits = const [];
      _searching = true;
    });
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final hits = await ref.read(recordingRepositoryProvider).search(query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _hits = hits;
        _searching = false;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<SearchHit>>{};
    for (final hit in _hits) {
      grouped.putIfAbsent(hit.recordingId, () => []).add(hit);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Search transcripts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              autofocus: true,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search transcripts',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _query.isEmpty
                ? const Center(child: Text('Search your transcripts'))
                : _hits.isEmpty
                ? const Center(child: Text('No results found'))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final hits in grouped.values) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: _HighlightedText(
                            hits.first.recordingTitle,
                            query: _query,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        for (final hit in hits)
                          ListTile(
                            dense: true,
                            leading: hit.segmentStartMs == null
                                ? const Icon(Icons.title_outlined)
                                : Text(_formatMmSs(hit.segmentStartMs!)),
                            title: Text(
                              hit.segmentStartMs == null
                                  ? 'Title match'
                                  : 'Transcript match',
                            ),
                            subtitle: _HighlightedText(
                              hit.text ?? hit.recordingTitle,
                              query: _query,
                            ),
                            onTap: () {
                              final timestamp = hit.segmentStartMs;
                              final suffix = timestamp == null
                                  ? ''
                                  : '?t=$timestamp';
                              context.push(
                                '/recording/${hit.recordingId}$suffix',
                              );
                            },
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText(this.text, {required this.query, this.style});

  final String text;
  final String query;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final foldedText = _foldAscii(text);
    final foldedQuery = _foldAscii(query);
    final spans = <TextSpan>[];
    var offset = 0;
    while (offset < text.length) {
      final match = foldedText.indexOf(foldedQuery, offset);
      if (match < 0 || foldedQuery.isEmpty) {
        spans.add(TextSpan(text: text.substring(offset)));
        break;
      }
      if (match > offset) {
        spans.add(TextSpan(text: text.substring(offset, match)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match, match + query.length),
          style: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      offset = match + query.length;
    }
    return Text.rich(TextSpan(children: spans), style: style);
  }
}

String _foldAscii(String value) => value.replaceAllMapped(
  RegExp('[A-Z]'),
  (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 32),
);

String _formatMmSs(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  return '${duration.inMinutes.toString().padLeft(2, '0')}:'
      '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}
