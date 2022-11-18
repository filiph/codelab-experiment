import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return MainScreen();
        },
      ),
    ],
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Startup App',
      darkTheme: ThemeData(
        useMaterial3: true,
        // brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          // brightness: Brightness.dark,
        ),
      ),
      // themeMode: ThemeMode.dark,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<WordPair> history = [];

  List<WordPair> favorites = [];

  WordPair pair = WordPair.random();

  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: Text('Favorites'),
            ),
            for (var pair in favorites)
              ListTile(
                title: Text(pair.asLowerCase),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      favorites.remove(pair);
                    });
                  },
                ),
              ),
          ],
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: AnimatedList(
                  reverse: true,
                  key: listKey,
                  itemBuilder: (context, index, animation) {
                    var historicalPair = history[index];
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        child: Center(
                          child: TextButton(
                            onPressed: historicalPair == pair
                                ? null
                                : () {
                                    setState(() {
                                      if (!history.contains(pair)) {
                                        history.insert(0, pair);
                                        listKey.currentState?.insertItem(0);
                                      }
                                      pair = historicalPair;
                                    });
                                  },
                            child: Text(historicalPair.asLowerCase),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PairDisplay(pair: pair),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (favorites.isNotEmpty)
                    TextButton.icon(
                      icon: Icon(Icons.list),
                      label: Text('Favorites'),
                      onPressed: () {
                        scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(favorites.contains(pair)
                        ? Icons.favorite
                        : Icons.favorite_border),
                    label: Text('Like'),
                    onPressed: () {
                      setState(() {
                        if (favorites.contains(pair)) {
                          favorites.remove(pair);
                        } else {
                          favorites.add(pair);
                        }
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Next'),
                    onPressed: () {
                      setState(() {
                        if (!history.contains(pair)) {
                          history.insert(0, pair);
                          listKey.currentState?.insertItem(0);
                        }
                        pair = WordPair.random();
                      });
                    },
                  ),
                  SizedBox(width: 8),
                ],
              ),
              Spacer(),
            ],
          ),
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
