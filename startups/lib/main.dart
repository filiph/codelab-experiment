import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MainScreen(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  var history = <WordPair>[];

  var favorites = <WordPair>[];

  void generateNext() {
    history.insert(0, current);
    current = WordPair.random();
    notifyListeners();
  }

  void toggleCurrentFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int value) => setState(() {
                    selectedIndex = value;
                  }),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: ListView(
            reverse: true,
            children: [
              for (var historicalPair in appState.history)
                Center(
                  child: Text(historicalPair.asLowerCase),
                ),
            ],
          ),
        ),
        SizedBox(height: 16),
        BigCard(appState.current),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              icon: Icon(appState.favorites.contains(appState.current)
                  ? Icons.favorite
                  : Icons.favorite_border),
              label: Text('Like'),
              onPressed: () {
                appState.toggleCurrentFavorite();
              },
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Next'),
              onPressed: () {
                appState.generateNext();
              },
            ),
            SizedBox(width: 28),
          ],
        ),
        Spacer(),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  final WordPair pair;

  BigCard(this.pair);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      margin: EdgeInsets.all(24),
      color: theme.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pair.first,
                style: style.copyWith(fontWeight: FontWeight.w100)),
            Text(
              pair.second,
              style: style.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          for (final favorite in appState.favorites)
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                favorite.asLowerCase,
                style: theme.textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }
}
