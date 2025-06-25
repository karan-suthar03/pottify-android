import 'package:flutter/material.dart';

import '../../models/song.dart';
import '../../services/api_service.dart';
import '../home/search_bar.dart' as custom;
import '../home/search_results_page.dart';

class SearchTabPage extends StatefulWidget {
  final void Function(Song, List<Song>)? onSongSelected;
  const SearchTabPage({super.key, this.onSongSelected});

  @override
  State<SearchTabPage> createState() => _SearchTabPageState();
}

class _SearchTabPageState extends State<SearchTabPage> {
  List<Song> _results = const [];
  bool _loading = false;
  String? _error;

  Future<void> _onSearch(String query) async {
    debugPrint('[SearchTabPage] Search query: "$query"');
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = ApiService();
    final response = await api.searchSongs(query);
    debugPrint('[SearchTabPage] API response: isSuccess=${response.isSuccess}, data=${response.data}, error=${response.error}');
    if (!mounted) return;
    if (response.isSuccess && response.data != null) {
      setState(() {
        _results = response.data!;
        _loading = false;
      });
    } else {
      setState(() {
        _results = [];
        _loading = false;
        _error = response.error?.message ?? 'Unknown error';
      });
      debugPrint('[SearchTabPage] Error: ${response.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            custom.SearchBar(onSearch: _onSearch),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_error!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            if (!_loading && _error == null)
              Expanded(
                child: SearchResults(
                  results: _results,
                  onSongSelected: widget.onSongSelected,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
