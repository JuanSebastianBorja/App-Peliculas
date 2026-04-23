import 'package:peliculas_app/models/cast.dart';

class CastResponse {
  final List<Cast> cast;

  CastResponse({required this.cast});

  factory CastResponse.fromJson(Map<String, dynamic> json) => CastResponse(
    cast: List<Cast>.from(json["cast"].map((x) => Cast.fromMap(x))),
  );
}
