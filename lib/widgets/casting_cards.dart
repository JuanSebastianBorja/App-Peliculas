import 'package:flutter/material.dart';
import 'package:peliculas_app/models/movie.dart';

class CastingCards extends StatelessWidget {
  final List<Cast> casts;

  const CastingCards({super.key, required this.casts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      width: double.infinity,
      height: 210,
      child: ListView.builder(
        itemCount: casts.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, int index) => _CastCard(cast: casts[index]),
      ),
    );
  } // <--- FALTABA ESTA LLAVE DE CIERRE
}

class _CastCard extends StatelessWidget {
  final Cast cast;

  const _CastCard({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    // Verificamos si profilePath existe y no es null
    final String? imagePath = cast.profilePath;

    // Construimos la URL completa si existe el path
    final String imageUrl = imagePath != null
        ? 'https://image.tmdb.org/t/p/w500$imagePath'
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 110,
      height: 180,
      child: Column(
        children: [
          SizedBox(
            width: 110,
            height: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FadeInImage(
                placeholder: const AssetImage('assets/no-image.jpg'),
                // Ajuste correcto para la propiedad image
                image: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl) as ImageProvider<Object>
                    : const AssetImage('assets/no-image.jpg'),
                fit: BoxFit.cover,
                // Opcional: manejar errores de carga de imagen
                imageErrorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Text(
              cast.name ?? 'Sin nombre',
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
