class ChatMessage {
  final String role;
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
    );
  }
}

class ChatRequest {
  final String message;
  final List<ChatMessage>? history;

  ChatRequest({
    required this.message,
    this.history,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        if (history != null) 'history': history!.map((e) => e.toJson()).toList(),
      };
}

class ChatResponse {
  final String response;
  final List<String> actionableHighlights;

  ChatResponse({
    required this.response,
    required this.actionableHighlights,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] ?? '',
      actionableHighlights: List<String>.from(json['actionable_highlights'] ?? []),
    );
  }
}
