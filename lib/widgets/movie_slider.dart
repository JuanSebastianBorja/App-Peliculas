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
    // OPTIMIZACIÓN: Usar w185 en lugar de w500 para listas reduce el uso de memoria en ~70%
    // Esto es crucial para evitar crashes en emuladores o dispositivos con poca RAM.
    final String? path = movie.posterPath;
    // Eliminamos cualquier espacio y usamos tamaño pequeño
    final String imageUrl = (path != null && path.isNotEmpty)
        ? 'https://image.tmdb.org/t/p/w185${path.trim()}'
        : '';

    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, 'detail', arguments: movie);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.grey[800], // Color de fondo mientras carga
                width: 130,
                height: 195, // Ajustado para proporción de póster
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: 130,
                        height: 195,
                        // Manejo de errores robusto
                        errorBuilder: (context, error, stackTrace) {
                          // Opcional: Imprimir solo en debug para no saturar logs
                          // print('Error imagen: ${movie.title}');
                          return Image.asset(
                            'assets/no-image.jpg',
                            fit: BoxFit.cover,
                            width: 130,
                            height: 195,
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
                    : Image.asset(
                        'assets/no-image.jpg',
                        fit: BoxFit.cover,
                        width: 130,
                        height: 195,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 40,
            child: Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
