import 'package:flutter/material.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/error_state_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'content_detail_screen.dart';

class BaseContentListScreen extends StatefulWidget {
  final String title;
  final String contentType;

  const BaseContentListScreen({
    super.key,
    required this.title,
    required this.contentType,
  });

  @override
  State<BaseContentListScreen> createState() =>
      _BaseContentListScreenState();
}

class _BaseContentListScreenState extends State<BaseContentListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ContentModel> _items = [];
  
  int _page = 1;
  final int _limit = 20;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        _loadMore();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    
    setState(() {
      _loading = true;
      if (_page == 1) _error = null;
    });
    
    try {
      final offset = (_page - 1) * _limit;
      final newData = await ContentService().fetchByType(
        widget.contentType,
        limit: _limit,
        offset: offset,
      );
      
      setState(() {
        if (newData.isEmpty || newData.length < _limit) {
          _hasMore = false;
        }
        _items.addAll(newData);
        _page++;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        if (_page == 1) _error = e.toString();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _items.clear();
      _hasMore = true;
      _error = null;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_loading && _page == 1 && _items.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    if (_error != null && _items.isEmpty) {
      return ErrorStateWidget(
        title: "Failed to load ${widget.title.toLowerCase()}",
        message: "Please check your connection.",
        onRetry: _refresh,
      );
    }

    if (_items.isEmpty && !_loading) {
      return const Center(
        child: Text(
          "No content available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        itemCount: _items.length + (_loading ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final content = _items[index];
          return ContentCard(
            content: content,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContentDetailScreen(item: content),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
