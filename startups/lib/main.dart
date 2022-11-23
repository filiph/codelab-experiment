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

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Column(
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
                            : () => appState.makeCurrent(historicalPair),
                        child: Text(historicalPair.asLowerCase),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            BigCard(appState.current),
            SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
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

class BigCard extends StatelessWidget {
  final WordPair pair;

  const BigCard(this.pair);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: pair.first,
                style: style.copyWith(fontWeight: FontWeight.w100),
              ),
              TextSpan(text: '​' /* zero width space */),
              TextSpan(
                text: pair.second,
                style: style.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(16),
      child: GridView.extent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 16 / 3,
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
