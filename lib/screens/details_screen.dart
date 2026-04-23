import 'package:flutter/material.dart';
import 'package:peliculas_app/models/movie.dart';
import 'package:peliculas_app/models/cast.dart';
import 'package:peliculas_app/widgets/widgets.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Movie movie;
  List<Cast>? castList;
  bool isLoading = true;
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtenemos los argumentos solo una vez
    if (castList == null && !isLoading) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Movie) {
      movie = args;
      // Cargamos el elenco si aún no lo hemos hecho
      if (castList == null && isLoading) {
        _loadCast();
      }
    } else {
      setState(() {
        errorMessage = "No se recibió información de la película";
        isLoading = false;
      });
    }
  }

  Future<void> _loadCast() async {
    try {
      final moviesProvider = Provider.of<MoviesProvider>(
        context,
        listen: false,
      );

      // Verificamos que el ID sea válido
      if (movie.id <= 0) throw Exception("ID de película inválido");

      final cast = await moviesProvider.getCast(movie.id);

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
          _CustomAppBar(movie: movie),
          SliverList(
            delegate: SliverChildListDelegate([
              _PosterAndTitle(movie: movie),
              _Overview(movie: movie),
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
    final String imageUrl =
        'https://image.tmdb.org/t/p/w500 ${movie.backdropPath}';
    return SliverAppBar(
      backgroundColor: Colors.blue,
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          color: Colors.black12,
          child: Text(
            movie.title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        background: FadeInImage(
          placeholder: const AssetImage('assets/loading.gif'),
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
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
    final String imageUrl =
        'https://image.tmdb.org/t/p/w500 ${movie.posterPath}';
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(20),
            child: FadeInImage(
              placeholder: const AssetImage('assets/no-image.jpg'),
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              height: 150,
              width: 100,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Row(
                children: [
                  const Icon(Icons.star_outline, size: 15, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    movie.voteAverage.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
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
