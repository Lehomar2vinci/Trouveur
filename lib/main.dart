import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BachelorsModel()),
        ChangeNotifierProvider(create: (_) => BachelorsFavoritesProvider()),
      ],
      child: MaterialApp.router(
        title: 'Bachelor App',
        routerDelegate: GoRouterDelegate(
          routes: (router) => [
            router.notFound((context, state) => const BachelorsMasterScreen()),
            router.define('/', (context, state) => const BachelorsMasterScreen()),
            router.define(
              '/details/:name',
              (context, state) {
                final name = state.params['name'] as String?;
                final bachelor = Provider.of<BachelorsModel>(context, listen: false).getBachelorByName(name);
                return BachelorDetailsScreen(bachelor: bachelor!);
              },
            ),
            router.define(
              '/likedBachelors',
              (context, state) => const LikedBachelorsScreen(),
            ),
          ],
        ),
        routeInformationParser: GoRouterInformationParser(),
      ),
    );
  }
}

class BachelorsModel with ChangeNotifier {
  List<BachelorCandidate> likedBachelors = [];

  void addLikedBachelor(BachelorCandidate bachelor) {
    likedBachelors.add(bachelor);
    notifyListeners();
  }

  void removeLikedBachelor(BachelorCandidate bachelor) {
    likedBachelors.remove(bachelor);
    notifyListeners();
  }

  BachelorCandidate? getBachelorByName(String? name) {
    return likedBachelors.firstWhereOrNull((bachelor) => bachelor.name == name);
  }
}

class BachelorsFavoritesProvider with ChangeNotifier {
  List<BachelorCandidate> likedBachelors = [];

  void addLikedBachelor(BachelorCandidate bachelor) {
    likedBachelors.add(bachelor);
    notifyListeners();
  }

  void removeLikedBachelor(BachelorCandidate bachelor) {
    likedBachelors.remove(bachelor);
    notifyListeners();
  }
}

class BachelorCandidate {
  final String name;
  final String photoUrl;
  final int age;
  final String occupation;

  const BachelorCandidate({
    required this.name,
    required this.photoUrl,
    required this.age,
    required this.occupation,
  });
}

class BachelorsMasterScreen extends StatelessWidget {
  const BachelorsMasterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bachelor List'),
        actions: [
          IconButton(
            onPressed: () => context.go('/likedBachelors'),
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: Consumer<BachelorsModel>(
        builder: (context, bachelorsModel, _) {
          return ListView.builder(
            itemCount: bachelorsModel.likedBachelors.length,
            itemBuilder: (context, index) {
              final bachelor = bachelorsModel.likedBachelors[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(bachelor.photoUrl),
                ),
                title: Text(bachelor.name),
                subtitle:
                    Text('${bachelor.age} years old, ${bachelor.occupation}'),
                onTap: () => context.go('/details/${bachelor.name}'),
              );
            },
          );
        },
      ),
    );
  }
}

class BachelorDetailsScreen extends StatelessWidget {
  final BachelorCandidate bachelor;

  const BachelorDetailsScreen({required this.bachelor, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLiked = Provider.of<BachelorsFavoritesProvider>(context)
        .likedBachelors
        .contains(bachelor);

    void handleLike(BuildContext context) {
      final favoritesProvider =
          Provider.of<BachelorsFavoritesProvider>(context, listen: false);

      if (isLiked) {
        favoritesProvider.removeLikedBachelor(bachelor);
      } else {
        favoritesProvider.addLikedBachelor(bachelor);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(bachelor.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(bachelor.photoUrl),
              ),
            ),
            const SizedBox(height: 16.0),
            Text('Age: ${bachelor.age}'),
            const SizedBox(height: 8.0),
            Text('Occupation: ${bachelor.occupation}'),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => handleLike(context),
              child: Text(isLiked ? 'Unlike' : 'Like'),
            ),
          ],
        ),
      ),
    );
  }
}

class LikedBachelorsScreen extends StatelessWidget {
  const LikedBachelorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final likedBachelors =
        Provider.of<BachelorsFavoritesProvider>(context).likedBachelors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Bachelors'),
      ),
      body: ListView.builder(
        itemCount: likedBachelors.length,
        itemBuilder: (context, index) {
          final bachelor = likedBachelors[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(bachelor.photoUrl),
            ),
            title: Text(bachelor.name),
            subtitle: Text('${bachelor.age} years old, ${bachelor.occupation}'),
            onTap: () => context.go('/details/${bachelor.name}'),
          );
        },
      ),
    );
  }
}
