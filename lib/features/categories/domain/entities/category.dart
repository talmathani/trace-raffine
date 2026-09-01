class Category {
  final String? id;
  final String name;
  final String slug;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;

  const Category({
    this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  Category copyWith({
    String? id,
    String? name,
    String? slug,
    String? iconUrl,
    int? sortOrder,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      iconUrl: iconUrl ?? this.iconUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'icon_url': iconUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['\$id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      iconUrl: json['icon_url'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}
