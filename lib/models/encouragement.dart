class Encouragement {
  final String id;
  final String query;
  final String message;
  final DateTime createdAt;
  final bool isFavorite;

  Encouragement({
    required this.id,
    required this.query,
    required this.message,
    required this.createdAt,
    this.isFavorite = false,
  });

  Encouragement copyWith({
    String? id,
    String? query,
    String? message,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Encouragement(
      id: id ?? this.id,
      query: query ?? this.query,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory Encouragement.fromJson(Map<String, dynamic> json) {
    return Encouragement(
      id: json['id'],
      query: json['query'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
} 