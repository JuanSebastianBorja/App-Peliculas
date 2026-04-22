import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_app/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  String _apyKey = 'cd000327b9663451fd4de423f4e0aa47';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];

  MoviesProvider() {
    print('Movies provider inicializado');
    this.getOnDisplayMovies();
  }
  getOnDisplayMovies() async {
    var url = Uri.https(this._baseUrl, '3/movie/now_playing', {
      'api_key': _apyKey,
      'language': _language,
      'page': '1',
    });
    final response = await http.get(url);
    final nowPlayingResponse = NowPlayingResponse.fromJson(response.body);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }
}
