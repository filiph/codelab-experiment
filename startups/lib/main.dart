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
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
          ),
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

  void makeCurrent(WordPair pair) {
    current = pair;
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: page,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.extent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 16 / 3,
        children: [
          for (final favorite in appState.favorites)
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                favorite.asLowerCase,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  GeneratorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: ListView(
                reverse: true,
                children: [
                  for (var historicalPair in appState.history)
                    Center(
                      child: TextButton(
                        onPressed: historicalPair == appState.current
                            ? null
                            : () {
                                appState.makeCurrent(historicalPair);
                              },
                        child: Text(historicalPair.asLowerCase),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PairDisplay(pair: appState.current),
              ),
            ),
            SizedBox(
              height: 8,
            ),
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
                OutlinedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Next'),
                  onPressed: () {
                    appState.generateNext();
                  },
                ),
                SizedBox(width: 8),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class PairDisplay extends StatelessWidget {
  final WordPair pair;

  const PairDisplay({Key? key, required this.pair}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: pair.first,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w100,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          TextSpan(text: '​' /* zero width space */),
          TextSpan(
            text: pair.second,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
