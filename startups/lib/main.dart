import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(StartupApp());
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          childAspectRatio: 16 / 9,
        ),
        itemBuilder: (BuildContext context, int index) {
          return WordCard(index);
        },
      ),
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

class WordCard extends StatelessWidget {
  final int index;

  const WordCard(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final pair = getWordPairAt(index);
    final color = Colors.primaries[index % Colors.primaries.length];

    return Card(
      color: color,
      // surfaceTintColor: Colors.primaries[index % Colors.primaries.length],
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DetailPage(pair, color),
        )),
        child: Center(
          child: Hero(
            tag: 'pair${pair.toString()}',
            child: Text(
              pair.asLowerCase,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                shadows: const [
                  Shadow(blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StartupApp extends StatelessWidget {
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

  StartupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Startup App',
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
    );
  }
}

class DetailPage extends StatefulWidget {
  final WordPair pair;

  final Color color;

  const DetailPage(this.pair, this.color, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // backgroundColor: widget.color,
          ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
            child: Hero(
              tag: 'pair${widget.pair.toString()}',
              child: Card(
                color: widget.color,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(100),
                    child: Text(
                      widget.pair.asLowerCase,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        shadows: const [
                          Shadow(blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
