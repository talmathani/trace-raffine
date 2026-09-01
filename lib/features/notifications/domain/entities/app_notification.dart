class AppNotification {
  final String? id;
  final String userId;
  final String title;
  final String? body;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    this.id,
    required this.userId,
    required this.title,
    this.body,
    this.isRead = false,
    this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'body': body,
      'is_read': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['\$id'],
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
