import 'package:flutter/material.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:peliculas_app/models/movie.dart';
import 'package:provider/provider.dart';
import 'package:peliculas_app/screens/screens.dart';

class MovieSlider extends StatelessWidget {
  const MovieSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(
      builder: (context, moviesProvider, child) {
        if (moviesProvider.popularMovies.isEmpty) {
          return const SizedBox(
            height: 270,
            width: double.infinity,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Añadimos un item extra para el título
            itemCount: moviesProvider.popularMovies.length + 1,
            itemBuilder: (_, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'Populares',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              final movie = moviesProvider.popularMovies[index - 1];
              return _MoviePoster(movie: movie);
            },
          ),
        );
      },
    );
  }
}

class _MoviePoster extends StatelessWidget {
  final Movie movie;

  const _MoviePoster({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // Validación estricta de la URL
    final String? path = movie.posterPath;
    final bool hasImage = path != null && path.isNotEmpty;
    final String imageUrl = hasImage
        ? 'https://image.tmdb.org/t/p/w185${path.trim()}' // Usamos w185 para ahorrar memoria
        : '';

    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, 'detail', arguments: movie);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.grey[800], // Color de fondo mientras carga
                width: 130,
                height: 195,
                child: hasImage
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        // frameBuilder ayuda a evitar parpadeos y gestiona mejor la memoria
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) return child;
                              return AnimatedOpacity(
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                child: child,
                              );
                            },
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback silencioso si falla la red
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white54,
                              ),
                            ),
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
