import 'package:flutter/material.dart';
import 'package:peliculas_app/models/movie.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:peliculas_app/screens/details_screen.dart';
import 'package:peliculas_app/widgets/card_swiper.dart';
import 'package:peliculas_app/widgets/movie_slider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar populares con retraso para no saturar la memoria al inicio
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Provider.of<MoviesProvider>(context, listen: false).getPopularMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliculas en Cartelera'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              final moviesProvider = Provider.of<MoviesProvider>(
                context,
                listen: false,
              );

              showSearch(
                context: context,
                delegate: MovieSearchDelegate(moviesProvider: moviesProvider),
              );
            },
            icon: const Icon(Icons.search_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardSwiper(movies: moviesProvider.onDisplayMovies),
            MovieSlider(), // Ahora cargará sus datos diferidamente
          ],
        ),
      ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  MovieSearchDelegate({required this.moviesProvider});

  final MoviesProvider moviesProvider;

  List<Movie> _searchResults() {
    return moviesProvider.searchMovies(query);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _searchResults();

    if (results.isEmpty) {
      return const Center(
        child: Text('No se encontraron películas con ese nombre'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final movie = results[index];
        return ListTile(
          leading: movie.posterPath != null
              ? Image.network(
                  movie.fullPosterImg,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                )
              : const Icon(Icons.movie),
          title: Text(movie.title),
          subtitle: Text(movie.originalTitle),
          onTap: () {
            close(context, movie);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Escribe el nombre de una película para buscarla'),
      );
    }

    final results = _searchResults().take(10).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Sin resultados'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final movie = results[index];
        return ListTile(
          leading: movie.posterPath != null
              ? Image.network(
                  movie.fullPosterImg,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                )
              : const Icon(Icons.movie),
          title: Text(movie.title),
          onTap: () {
            query = movie.title;
            showResults(context);
          },
        );
      },
    );
  }
}
