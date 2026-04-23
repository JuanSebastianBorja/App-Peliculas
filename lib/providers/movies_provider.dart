import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_app/models/models.dart';
import 'dart:convert';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = 'cd000327b9663451fd4de423f4e0aa47';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  MoviesProvider() {
    print('Movies provider inicializado');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  getOnDisplayMovies() async {
    try {
      var url = Uri.https(this._baseUrl, '3/movie/now_playing', {
        'api_key': _apiKey,
        'language': _language,
        'page': '1',
      });
      final response = await http.get(url);
      final nowPlayingResponse = NowPlayingResponse.fromJson(response.body);
      onDisplayMovies = nowPlayingResponse.results;
      notifyListeners();
    } catch (e) {
      print('Error al cargar películas: $e');
    }
  }

  Future<List<Cast>> getCast(int movieId) async {
    try {
      final url = Uri.https('api.themoviedb.org', '3/movie/$movieId/credits', {
        'api_key': _apiKey,
        'language': 'es-MX',
      });
      // Agregamos timeout para evitar que se congele si la red es lenta
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return CastResponse.fromJson(decodedData).cast;
      } else {
        print('Error HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('Excepción en getCast: $e');
      // Retornamos lista vacía en caso de error para no romper la UI
      return [];
    }
  }

  getPopularMovies() async {
    try {
      var url = Uri.https(this._baseUrl, '3/movie/popular', {
        'api_key': _apiKey,
        'language': _language,
        'page': '1',
      });
      final response = await http.get(url);
      final popularResponse = NowPlayingResponse.fromJson(response.body);
      popularMovies = popularResponse.results;
      notifyListeners();
    } catch (e) {
      print('Error al cargar películas populares: $e');
    }
  }
}
