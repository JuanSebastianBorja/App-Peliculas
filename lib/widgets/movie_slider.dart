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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: const [
                  Text(
                    'Populares',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: moviesProvider.popularMovies.length,
                itemBuilder: (_, int index) {
                  final movie = moviesProvider.popularMovies[index];
                  return _MoviePoster(movie: movie);
                },
              ),
            ),
          ],
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
    final String? path = movie.posterPath;

    // CORRECCIÓN CRÍTICA: Sin espacios entre w92 y la ruta
    final String imageUrl = (path != null && path.isNotEmpty)
        ? 'https://image.tmdb.org/t/p/w92${path.trim()}'
        : '';

    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, 'detail', arguments: movie);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                width: 110,
                height: 165,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: 110,
                        height: 165,
                        cacheWidth: 110,
                        cacheHeight: 165,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 30,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 30,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF102A43),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
