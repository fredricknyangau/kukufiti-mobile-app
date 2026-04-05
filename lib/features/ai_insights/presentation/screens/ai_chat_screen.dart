import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_insights_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiInsightsProvider);
    final theme = Theme.of(context);

    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(title: const Text('AI Vet Chat')),
      body: Column(
        children: [
          Expanded(
            child: aiState.chatHistory.isEmpty
                ? Center(child: Text('Ask me anything about your flock!', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: aiState.chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = aiState.chatHistory[index];
                      final isUser = message.role == 'user';

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                              bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                            ),
                          ),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (aiState.isLoading) ...[
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: Text('AI is typing...', style: TextStyle(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
             ),
          ],

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                   Expanded(
                     child: TextField(
                       controller: _messageController,
                       decoration: const InputDecoration(
                         hintText: 'Type your question...',
                         border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                         contentPadding: EdgeInsets.symmetric(horizontal: 16),
                       ),
                       onSubmitted: (_) => _sendMessage(),
                       onChanged: (val) => setState(() {}),
                     ),
                   ),
                   const SizedBox(width: 8),
                   IconButton(
                     onPressed: aiState.isLoading || _messageController.text.trim().isEmpty ? null : _sendMessage,
                     icon: const Icon(Icons.send),
                     color: theme.colorScheme.primary,
                   )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _sendMessage() {
     final text = _messageController.text.trim();
     if (text.isEmpty) return;
     
     HapticFeedback.lightImpact();
     _messageController.clear();
     setState(() {});
     ref.read(aiInsightsProvider.notifier).sendMessage(text);
  }
}
