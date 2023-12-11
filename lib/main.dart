import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filmographia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Filmographia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchMovies(BuildContext context) async {
    final apiKey = '956f48c5';
    final searchQuery = _searchController.text;

    if (searchQuery.isNotEmpty) {
      final apiUrl = 'http://www.omdbapi.com/?s=$searchQuery&apikey=$apiKey&plot=full';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['Response'] == 'True') {
          setState(() {
            _searchResults = List<Map<String, dynamic>>.from(data['Search']);
          });

          // Naviguer vers la page de la liste de films
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieListPage(searchResults: _searchResults),
            ),
          );
        } else {
          setState(() {
            _searchResults = [];
          });
        }
      } else {
        throw Exception('Échec du chargement des données depuis l\'API OMDB');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Rechercher un film :',
              style: Theme.of(context).textTheme.headline5,
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Entrez une recherche',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _searchMovies(context);
              },
              child: Text('Rechercher'),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieListPage extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;

  const MovieListPage({Key? key, required this.searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des films'),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final movie = searchResults[index];
          return ListTile(
            title: Text(movie['Title']),
            subtitle: Text(movie['Year']),
            onTap: () {
              // Naviguer vers la page des détails du film
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailPage(movie: movie),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MovieDetailPage extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieDetailPage({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(movie['Title']),
        ),
        body: Container(
          color: Colors.black, // Fond noir
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${movie['Title']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${movie['Year']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Image.network(
                    movie['Poster'],
                    height: 300,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Type: ${movie['Type']}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ID: ${movie['imdbID']}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description du film: ${movie['Plot']}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
