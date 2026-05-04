class UsersModel {
  final String? docId;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final int? createdAt;
  final List<String>? favorites;

  UsersModel({
    this.docId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.favorites,
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) => UsersModel(
        docId: json["docId"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        createdAt: json["createdAt"],
        favorites: (json["favorites"] as List?)
            ?.map((e) => e.toString())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "docId": docId,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "createdAt": createdAt,
        "favorites": favorites ?? [],
      };
}
