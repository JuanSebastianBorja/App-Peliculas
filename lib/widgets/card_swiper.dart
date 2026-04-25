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
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
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
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: isValidUrl
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: size.width * 0.6,
                          height: size.height * 0.4,
                          cacheWidth: (size.width * 0.6).toInt(),
                          cacheHeight: (size.height * 0.4).toInt(),
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white54,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
