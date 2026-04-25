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
        title: const Text(
          'Peliculas en Cartelera',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF2FF), Color(0xFFF7FAFC)],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                final moviesProvider = Provider.of<MoviesProvider>(
                  context,
                  listen: false,
                );

                showSearch(
                  context: context,
                  delegate: MovieSearchDelegate(moviesProvider: moviesProvider),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.search_outlined),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7FAFC), Color(0xFFEAF2FF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20)),
              const SizedBox(height: 16),
              CardSwiper(movies: moviesProvider.onDisplayMovies),
              const SizedBox(height: 12),
              MovieSlider(),
              const SizedBox(height: 18),
            ],
          ),
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
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No se encontraron películas con ese nombre',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final movie = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 6,
          ),
          leading: movie.posterPath != null
              ? Image.network(
                  movie.fullPosterImg,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.broken_image),
                  ),
                )
              : Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.movie),
                ),
          title: Text(
            movie.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 6,
          ),
          leading: movie.posterPath != null
              ? Image.network(
                  movie.fullPosterImg,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.broken_image),
                  ),
                )
              : Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.movie),
                ),
          title: Text(
            movie.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () {
            query = movie.title;
            showResults(context);
          },
        );
      },
    );
  }
}
