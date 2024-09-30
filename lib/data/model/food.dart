class Food {
  final String? id;
  final String name;
  final String category;
  final DateTime expiredDate;
  final String desc;
  final String imageUrl;
  late final int quantity;
  final bool state;

  Food({
    this.id,
    required this.name,
    required this.category,
    required this.expiredDate,
    required this.desc,
    required this.imageUrl,
    required this.quantity,
    this.state = false,
  });

  Food copy({
    String? id,
    String? name,
    String? category,
    DateTime? expiredDate,
    String? desc,
    String? imageUrl,
    int? quantity,
    bool? state,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      expiredDate: expiredDate ?? this.expiredDate,
      desc: desc ?? this.desc,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      state: state ?? this.state,
    );
  }

  @override
  String toString() {
    return "Food($id, $name, $category, $expiredDate, $desc, $imageUrl, $quantity, $state)";
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "category": category,
      "expiredDate": expiredDate.millisecondsSinceEpoch,
      "desc": desc,
      "imageUrl": imageUrl,
      "quantity": quantity,
      "state": state,
    };
  }

  static Food fromMap(Map<String, dynamic> map) {
    return Food(
      id: map["id"],
      name: map["name"],
      category: map["category"],
      expiredDate: DateTime.fromMillisecondsSinceEpoch(map["expiredDate"]),
      desc: map["desc"],
      imageUrl: map["imageUrl"],
      quantity: map["quantity"],
      state: map["state"] ?? false,
    );
  }
}
