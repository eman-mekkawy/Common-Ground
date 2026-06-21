class Need {
  final String category; // 'Housing Support', 'Food Assistance', etc.
  final String priority; // 'High', 'Medium', 'Low'
  final double confidence; // 0.0 to 1.0
  final String reasoning; // Explanation of why this was inferred or detected

  Need({
    required this.category,
    required this.priority,
    required this.confidence,
    required this.reasoning,
  });

  factory Need.fromJson(Map<String, dynamic> json) {
    return Need(
      category: json['category'] as String? ?? 'General Support',
      priority: json['priority'] as String? ?? 'Medium',
      confidence: (json['confidence'] as num? ?? 0.5).toDouble(),
      reasoning: json['reasoning'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'priority': priority,
      'confidence': confidence,
      'reasoning': reasoning,
    };
  }
}
