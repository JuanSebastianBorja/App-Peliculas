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

        // Usamos un SizedBox para dar altura fija al contenedor principal
        return SizedBox(
          height: 270,
          child: ListView.builder(
            // Clave: ScrollDirection.horizontal permite que el ListView crezca horizontalmente
            // sin chocar con la altura fija del padre.
            scrollDirection: Axis.horizontal,
            itemCount:
                moviesProvider.popularMovies.length + 1, // +1 para el título
            itemBuilder: (_, int index) {
              // El índice 0 es el título, el resto son las películas
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    // Centramos verticalmente el título en los 270px
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

              // Ajustamos el índice para acceder a la lista de películas (restamos 1)
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
    final String imageUrl = movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
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
              child: FadeInImage(
                placeholder: const AssetImage('assets/no-image.jpg'),
                // Si no hay URL, usamos la imagen local directamente
                image: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl) as ImageProvider<Object>
                    : const AssetImage('assets/no-image.jpg'),
                width: 130,
                height: 175,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  // Fallback seguro
                  return Image.asset('assets/no-image.jpg', fit: BoxFit.cover);
                },
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
