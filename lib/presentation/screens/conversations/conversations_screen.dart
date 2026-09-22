import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../data/services/mock_messaging_service.dart';
import '../../../data/services/mock_broadcast_service.dart';

class ConversationItem {
  final String id;
  final String title;
  final DateTime lastUpdatedAt;
  final bool isBroadcast;

  ConversationItem({
    required this.id,
    required this.title,
    required this.lastUpdatedAt,
    required this.isBroadcast,
  });
}

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MockMessagingService _messagingService = MockMessagingService();
  final MockBroadcastService _broadcastService = MockBroadcastService();

  List<ConversationItem> _allItems = [];
  List<ConversationItem> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredItems = _allItems.where((item) {
        return item.title.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    try {
      final conversations = await _messagingService.getConversations();
      final lists = await _broadcastService.getBroadcastLists();

      final List<ConversationItem> items = [];

      // Add normal conversations
      for (final conv in conversations) {
        items.add(ConversationItem(
          id: conv.id,
          title: conv.participantId, // We just show participantId as title
          lastUpdatedAt: conv.lastUpdatedAt,
          isBroadcast: false,
        ));
      }

      // Add broadcast lists if they have at least one broadcast sent
      for (final list in lists) {
        final broadcasts = await _broadcastService.getBroadcastsForList(list.id);
        if (broadcasts.isNotEmpty) {
          items.add(ConversationItem(
            id: list.id,
            title: list.name, // The broadcast clearly indicates it is a broadcast by name/icon
            lastUpdatedAt: broadcasts.first.sentAt, // Newest first
            isBroadcast: true,
          ));
        }
      }

      // Sort by newest first
      items.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));

      if (mounted) {
        setState(() {
          _allItems = items;
          _filteredItems = _allItems.where((item) {
            return item.title.toLowerCase().contains(_searchQuery);
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading conversations: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allItems.isEmpty) {
      return const Center(child: Text('No conversations yet'));
    }

    if (_filteredItems.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return ListTile(
          leading: CircleAvatar(
            child: Icon(item.isBroadcast ? Icons.campaign : Icons.person),
          ),
          title: Text(item.title),
          subtitle: Text('Last updated: ${item.lastUpdatedAt.toLocal()}'.split('.')[0]),
          onTap: () {
            if (item.isBroadcast) {
              Navigator.of(context).pushNamed(
                AppRouter.broadcastComposer,
                arguments: item.id,
              ).then((_) => _loadConversations());
            } else {
              Navigator.of(context).pushNamed(
                AppRouter.chat,
                arguments: item.id,
              ).then((_) => _loadConversations());
            }
          },
        );
      },
    );
  }
}
