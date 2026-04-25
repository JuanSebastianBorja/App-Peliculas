import 'package:flutter/material.dart';
import 'package:peliculas_app/models/movie.dart';
import 'package:peliculas_app/models/cast.dart';
import 'package:peliculas_app/widgets/widgets.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Cast>? castList;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCast();
  }

  Future<void> _loadCast() async {
    try {
      final moviesProvider = Provider.of<MoviesProvider>(
        context,
        listen: false,
      );

      if (widget.movie.id <= 0) throw Exception("ID de película inválido");

      final cast = await moviesProvider.getCast(widget.movie.id);

      if (mounted) {
        setState(() {
          castList = cast;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Error al cargar actores: $e";
          isLoading = false;
        });
      }
      print("Error detallado: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: CustomScrollView(
        slivers: [
          _CustomAppBar(movie: widget.movie),
          SliverList(
            delegate: SliverChildListDelegate([
              _PosterAndTitle(movie: widget.movie),
              _Overview(movie: widget.movie),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (castList != null && castList!.isNotEmpty)
                CastingCards(casts: castList!)
              else
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text("No hay actores disponibles")),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final Movie movie;
  const _CustomAppBar({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final String? path = movie.backdropPath;
    final String imageUrl = path != null
        ? 'https://image.tmdb.org/t/p/w500$path'
        : '';

    return SliverAppBar(
      backgroundColor: const Color(0xFF102A43),
      expandedHeight: 240,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        background: FadeInImage(
          placeholder: AssetImage('assets/loading.gif'),
          image: imageUrl.isNotEmpty
              ? NetworkImage(imageUrl) as ImageProvider
              : AssetImage('assets/no-image.jpg'),
          fit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) {
            print("Error cargando backdrop: $error");
            return Image.asset('assets/no-image.jpg', fit: BoxFit.cover);
          },
        ),
      ),
    );
  }
}

class _PosterAndTitle extends StatelessWidget {
  final Movie movie;
  const _PosterAndTitle({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final String? path = movie.posterPath;
    final String imageUrl = path != null
        ? 'https://image.tmdb.org/t/p/w500$path'
        : '';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 100,
              height: 150,
              child: FadeInImage(
                placeholder: AssetImage('assets/no-image.jpg'),
                image: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl) as ImageProvider
                    : AssetImage('assets/no-image.jpg'),
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  print("Error cargando poster: $error");
                  return Image.asset('assets/no-image.jpg', fit: BoxFit.cover);
                },
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 24),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFFF5A524),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoChip(text: movie.releaseDate ?? 'Fecha no disponible'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  final Movie movie;
  const _Overview({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        movie.overview ?? 'Sin descripción disponible.',
        textAlign: TextAlign.justify,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0F4C81),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
