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
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
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
      backgroundColor: Colors.blue,
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.all(0),
        title: Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          color: Colors.black12,
          child: Text(
            movie.title,
            style: TextStyle(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
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
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(20),
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
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star_outline, size: 15, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(
        movie.overview ?? 'Sin descripción disponible.',
        textAlign: TextAlign.justify,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
