import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:peliculas_app/models/movie.dart';

class CardSwiper extends StatelessWidget {
  final List<Movie> movies;
  const CardSwiper({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Si no hay películas, mostramos un contenedor vacío para evitar errores
    if (movies.isEmpty) {
      return SizedBox(
        height: size.height * 0.5,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.5,
      child: Swiper(
        itemCount: movies.length,
        layout: SwiperLayout.STACK,
        itemWidth: size.width * 0.6,
        itemHeight: size.height * 0.4,
        itemBuilder: (_, int index) {
          final movie = movies[index];

          // Validar que exista una URL válida
          final String imageUrl = movie.fullPosterImg;
          final bool isValidUrl = imageUrl.contains('http');

          return GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, 'detail', arguments: movie),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.black, // Fondo mientras carga
                child: isValidUrl
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: size.width * 0.6,
                        height: size.height * 0.4,
                        cacheWidth: (size.width * 0.6).toInt(),
                        cacheHeight: (size.height * 0.4).toInt(),
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(Icons.error_outline, color: Colors.white54),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
