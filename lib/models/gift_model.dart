class GiftModel {
  final String id;
  final String name;
  final String icon;
  final int cost;
  final String? animation;
  final String? sound;

  GiftModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
    this.animation,
    this.sound,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      cost: json['cost'],
      animation: json['animation'],
      sound: json['sound'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'cost': cost,
      'animation': animation,
      'sound': sound,
    };
  }
}