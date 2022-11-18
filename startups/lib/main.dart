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
          seedColor: Colors.red,
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

  WordPair pair = WordPair.random();

  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          child: Opacity(
                            opacity: ((7 - index) / 7).clamp(0, 1),
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
                  ElevatedButton.icon(
                    icon: Icon(Icons.favorite_border),
                    label: Text('Like'),
                    onPressed: () {},
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

final List<WordPair> _wordPairs = [];

WordPair getWordPairAt(int index) {
  while (index >= _wordPairs.length) {
    _wordPairs.addAll(generateWordPairs().take(50));
  }
  return _wordPairs[index];
}
