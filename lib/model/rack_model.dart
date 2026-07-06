class RackModel {
  final int id;
  final String name;

  RackModel({
    required this.id,
    required this.name,
  });

  factory RackModel.fromJson(Map<String, dynamic> json) {
    return RackModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}