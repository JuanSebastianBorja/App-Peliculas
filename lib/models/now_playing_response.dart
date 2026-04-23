import 'dart:convert';
import 'package:peliculas_app/models/models.dart';

class NowPlayingResponse {
  NowPlayingResponse({
    this.dates,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  Dates? dates;
  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  factory NowPlayingResponse.fromJson(String str) =>
      NowPlayingResponse.fromMap(json.decode(str));

  factory NowPlayingResponse.fromMap(Map<String, dynamic> json) =>
      NowPlayingResponse(
        dates: json["dates"] != null ? Dates.fromMap(json["dates"]) : null,
        page: json["page"] ?? 1,
        results: json["results"] != null
            ? List<Movie>.from(
                json["results"]
                    .where(
                      (element) => element != null,
                    ) // <--- Filtrar nulos aquí
                    .map((x) => Movie.fromMap(x)),
              )
            : [],
        totalPages: json["total_pages"] ?? 0,
        totalResults: json["total_results"] ?? 0,
      );
}

class Dates {
  DateTime maximum;
  DateTime minimum;

  Dates({required this.maximum, required this.minimum});

  factory Dates.fromJson(String str) => Dates.fromMap(json.decode(str));
  factory Dates.fromMap(Map<String, dynamic> json) => Dates(
    maximum: DateTime.parse(json["maximum"]),
    minimum: DateTime.parse(json["minimum"]),
  );
}
