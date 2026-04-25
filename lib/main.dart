import 'package:flutter/material.dart';
import 'package:peliculas_app/screens/screens.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:peliculas_app/models/movie.dart';
import 'package:provider/provider.dart';

void main() => runApp(AppState());

class AppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoviesProvider(), lazy: false),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peliculas',
      initialRoute: 'home',
      routes: {
        'home': (_) => HomeScreen(),
        'detail': (context) {
          final Movie movie =
              ModalRoute.of(context)!.settings.arguments as Movie;
          return DetailScreen(movie: movie);
        },
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C81),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF102A43),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF102A43),
          ),
          bodyMedium: TextStyle(color: Color(0xFF425466)),
          labelMedium: TextStyle(color: Color(0xFF516173), height: 1.5),
        ),
      ),
    );
  }
}
