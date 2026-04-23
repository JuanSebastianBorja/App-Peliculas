class Cast {
  Cast({
    required this.castId,
    required this.character,
    required this.name,
    this.profilePath,
    required this.order,
  });

  int castId;
  String character;
  String name;
  String? profilePath;
  int order;

  factory Cast.fromMap(Map<String, dynamic> json) => Cast(
    castId: json["cast_id"],
    character: json["character"],
    name: json["name"],
    profilePath: json["profile_path"],
    order: json["order"],
  );
}
