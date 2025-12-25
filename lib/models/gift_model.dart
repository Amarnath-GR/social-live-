class GiftModel {
  final String id;
  final String name;
  final String icon;
  final int cost;
  final String? description;
  final String? animationUrl;

  GiftModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
    this.description,
    this.animationUrl,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      cost: json['cost'],
      description: json['description'],
      animationUrl: json['animationUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'cost': cost,
      'description': description,
      'animationUrl': animationUrl,
    };
  }
}