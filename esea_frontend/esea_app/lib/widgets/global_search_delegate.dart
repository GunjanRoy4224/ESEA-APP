import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_result.dart';
import '../services/search_service.dart';
import '../services/discussion_service.dart';

// Screens for deep linking
import '../screens/internships/internship_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/announcements/announcements_screen.dart';
import '../screens/newsletter/newsletter_screen.dart';
import '../screens/blogs/research_blog_screen.dart';
import '../screens/discussions/discussion_detail_screen.dart';
import '../screens/discussions/discussion_feed_screen.dart';
import '../screens/content/content_detail_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/internships/internship_detail_screen.dart';
import '../services/content_service.dart';

class GlobalSearchDelegate extends SearchDelegate<SearchResult?> {
  final SearchService _searchService = SearchService();
  Timer? _debounce;
  
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  
  List<String> _recentSearches = [];
  
  GlobalSearchDelegate() {
    _loadRecentSearches();
  }
  
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
  }
  
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches.removeLast();
    }
    await prefs.setString('recent_searches', _recentSearches);
  }
  
  void _performSearch(String query, BuildContext context, Function updateState) {
    if (query.trim().isEmpty) {
      updateState(() {
        _searchResults = [];
        _error = null;
      });
      return;
    }
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      updateState(() {
        _isLoading = true;
        _error = null;
      });
      
      try {
        final results = await _searchService.globalSearch(query: query);
        updateState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } catch (e) {
        updateState(() {
          _error = "Failed to fetch search results. Please try again.";
          _isLoading = false;
        });
      }
    });
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _searchResults.clear();
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      _saveRecentSearch(query.trim());
    }
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _performSearch(query, context, (fn) => fn());
              },
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return const Center(child: Text("No results found."));
    }
    
    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _buildResultTile(context, _searchResults[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // We use StatefulBuilder to update local state in suggestions without rebuilding everything
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Trigger search on query change
        if (query.isNotEmpty) {
          _performSearch(query, context, setState);
        }
        
        if (query.isEmpty) {
          if (_recentSearches.isEmpty) {
            return const Center(child: Text("Try searching for events, discussions, etc."));
          }
          return ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(_recentSearches[index]),
                onTap: () {
                  query = _recentSearches[index];
                  showResults(context);
                },
              );
            },
          );
        }

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (_error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _performSearch(query, context, setState);
                  },
                  child: const Text('Retry'),
                )
              ],
            ),
          );
        }

        if (_searchResults.isEmpty) {
          return const Center(child: Text("No results found."));
        }

        return ListView.separated(
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _buildResultTile(context, _searchResults[index]);
          },
        );
      },
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResult result) {
    IconData icon;
    switch (result.entityType.toLowerCase()) {
      case 'discussion':
        icon = Icons.forum_outlined;
        break;
      case 'announcement':
        icon = Icons.campaign_outlined;
        break;
      case 'event':
        icon = Icons.event_outlined;
        break;
      case 'research':
        icon = Icons.search_outlined;
        break;
      case 'newsletter':
        icon = Icons.menu_book_outlined;
        break;
      case 'internship':
        icon = Icons.work_outline;
        break;
      default:
        icon = Icons.article_outlined;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF0B5D4B).withOpacity(0.1),
        child: Icon(icon, color: const Color(0xFF0B5D4B)),
      ),
      title: Text(result.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: _buildHighlightedText(result.preview),
      onTap: () {
        _saveRecentSearch(query);
        _navigateToResult(context, result);
      },
    );
  }

  Widget _buildHighlightedText(String text) {
    // ts_headline wraps matched words in <b></b>
    List<TextSpan> spans = [];
    final split = text.split('<b>');
    
    for (int i = 0; i < split.length; i++) {
      if (i == 0) {
        if (split[i].isNotEmpty) {
          spans.add(TextSpan(text: split[i], style: const TextStyle(color: Colors.black54)));
        }
      } else {
        final innerSplit = split[i].split('</b>');
        if (innerSplit.isNotEmpty) {
          spans.add(TextSpan(
            text: innerSplit[0],
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ));
          if (innerSplit.length > 1 && innerSplit[1].isNotEmpty) {
            spans.add(TextSpan(text: innerSplit[1], style: const TextStyle(color: Colors.black54)));
          }
        }
      }
    }
    
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  void _navigateToResult(BuildContext context, SearchResult result) async {
    final type = result.entityType.toLowerCase();
    
    if (type == 'discussion') {
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (_) => const Center(child: CircularProgressIndicator())
      );
      try {
        final discussion = await DiscussionService().fetchDiscussionById(int.parse(result.id));
        Navigator.pop(context); // close dialog
        Navigator.push(context, MaterialPageRoute(builder: (_) => DiscussionDetailScreen(discussion: discussion)));
      } catch (e) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to load discussion")));
      }
      return;
    }
    
    // For contents
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator())
    );
    try {
      final content = await ContentService().fetchContentById(result.id);
      Navigator.pop(context); // close dialog
      
      Widget screen;
      switch (type) {
        case 'internship':
          screen = InternshipDetailScreen(content: content);
          break;
        case 'event':
          screen = EventDetailScreen(content: content);
          break;
        default:
          screen = ContentDetailScreen(item: content);
      }
      
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } catch (e) {
      Navigator.pop(context); // close dialog
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to load content")));
    }
  }
}
