import 'package:flutter/material.dart';
import '../services/llm_service.dart';
import '../services/pantry_service.dart';
import 'home_screen.dart' show AppTheme;
import '../l10n/app_localizations.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  final bool autoSendInitialMessage;

  const ChatScreen({
    super.key,
    this.initialMessage,
    this.autoSendInitialMessage = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final LLMService _llmService = LLMService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _didAddGreeting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMessage?.trim();
    if (initial != null && initial.isNotEmpty && widget.autoSendInitialMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageController.text = initial;
        _handleSendMessage();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didAddGreeting) return;
    final t = AppLocalizations.of(context);
    _messages.add(
      ChatMessage(
        text: t.tr('assistant_greeting'),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _didAddGreeting = true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    
    // Scroll to show user message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      // Get current pantry items to pass as context
      final inventoryItems = PantryService.instance.items;
      
      final response = await _llmService.sendChatMessage(text, inventoryItems);

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      setState(() {
        _messages.add(ChatMessage(
          text: t.tr('assistant_error'),
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.smart_toy_rounded, color: AppTheme.primaryDark),
            const SizedBox(width: 8),
            Text(
              t.tr('assistant_title'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: AppTheme.primary),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : AppTheme.textDark,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: t.tr('assistant_hint'),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _isLoading ? null : _handleSendMessage,
            mini: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
