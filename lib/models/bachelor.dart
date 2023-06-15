import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BachelorsModel(),
      child: MaterialApp(
        title: 'Suiveur',
        theme: ThemeData(primarySwatch: Colors.pink),
        home: const BachelorsMasterScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/likedBachelors': (context) => const LikedBachelorsScreen(),
        },
      ),
    );
  }
}

class BachelorsMasterScreen extends StatefulWidget {
  const BachelorsMasterScreen({Key? key}) : super(key: key);

  @override
  _BachelorsMasterScreenState createState() => _BachelorsMasterScreenState();
}

class _BachelorsMasterScreenState extends State<BachelorsMasterScreen> {
  late List<BachelorCandidate> bachelors;
  List<BachelorCandidate> likedBachelors = [];

  @override
  void initState() {
    super.initState();
    generateAndSaveBachelors();
  }

  void generateAndSaveBachelors() async {
    final faker = Faker();
    List<BachelorCandidate> bachelorsList = [];

    for (var i = 0; i < 30; i++) {
      var candidate = BachelorCandidate(
        firstname: faker.person.firstName(),
        lastname: faker.person.lastName(),
        gender: Gender.male,
        avatar: 'assets/images/man-1.png',
        searchFor: [Gender.female],
        job: faker.job.title(),
        description: faker.lorem.sentences(3).join(' '),
      );
      bachelorsList.add(candidate);
    }

    setState(() {
      bachelors = bachelorsList;
    });
  }

  void handleLike(BachelorCandidate bachelor, bool isLiked) {
    if (isLiked) {
      Provider.of<BachelorsModel>(context, listen: false)
          .addLikedBachelor(bachelor);
      showLikeConfirmation();
    } else {
      Provider.of<BachelorsModel>(context, listen: false)
          .removeLikedBachelor(bachelor);
    }
  }

  void showLikeConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bachelor Liked!'),
      ),
    );
  }

  void navigateToLikedBachelorsScreen() {
    Navigator.pushNamed(context, '/likedBachelors');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bachelor List'),
        actions: [
          IconButton(
            onPressed: navigateToLikedBachelorsScreen,
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: bachelors.length,
        itemBuilder: (context, index) {
          final bachelor = bachelors[index];
          final isLiked =
              Provider.of<BachelorsModel>(context).isLikedBachelor(bachelor);
          return BachelorPreview(
            bachelor: bachelor,
            isLiked: isLiked,
            onLike: (isLiked) => handleLike(bachelor, isLiked),
          );
        },
      ),
    );
  }
}

class BachelorPreview extends StatelessWidget {
  final BachelorCandidate bachelor;
  final bool isLiked;
  final LikeCallback onLike;

  const BachelorPreview({
    Key? key,
    required this.bachelor,
    required this.isLiked,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(bachelor.avatar),
          ),
          if (isLiked)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
            ),
        ],
      ),
      title: Text('${bachelor.firstname} ${bachelor.lastname}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BachelorDetailsScreen(
              bachelor: bachelor,
            ),
          ),
        );
      },
    );
  }
}

class BachelorDetailsScreen extends StatefulWidget {
  final BachelorCandidate bachelor;

  const BachelorDetailsScreen({
    Key? key,
    required this.bachelor,
  }) : super(key: key);

  @override
  _BachelorDetailsScreenState createState() => _BachelorDetailsScreenState();
}

class _BachelorDetailsScreenState extends State<BachelorDetailsScreen> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = Provider.of<BachelorsModel>(context, listen: false)
        .isLikedBachelor(widget.bachelor);
  }

  void handleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    Provider.of<BachelorsModel>(context, listen: false)
        .addLikedBachelor(widget.bachelor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bachelor Details'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.bachelor.avatar),
              radius: 80,
            ),
          ),
          ListTile(
            title: const Text('Nom'),
            subtitle: Text(
                '${widget.bachelor.firstname} ${widget.bachelor.lastname}'),
          ),
          ListTile(
            title: const Text('Genre'),
            subtitle: Text(widget.bachelor.gender.toString().split('.').last),
          ),
          ListTile(
            title: const Text('Travail'),
            subtitle: Text(widget.bachelor.job),
          ),
          ListTile(
            title: const Text('Description'),
            subtitle: Text(widget.bachelor.description),
          ),
          ElevatedButton(
            onPressed: handleLike,
            child: Text(isLiked ? 'Unlike' : 'Like'),
          ),
        ],
      ),
    );
  }
}

class LikedBachelorsScreen extends StatelessWidget {
  const LikedBachelorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final likedBachelors = Provider.of<BachelorsModel>(context).likedBachelors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Bachelors'),
      ),
      body: ListView.builder(
        itemCount: likedBachelors.length,
        itemBuilder: (context, index) {
          final likedBachelor = likedBachelors[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(likedBachelor.avatar),
            ),
            title: Text('${likedBachelor.firstname} ${likedBachelor.lastname}'),
          );
        },
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

  bool isLikedBachelor(BachelorCandidate bachelor) {
    return likedBachelors.contains(bachelor);
  }

  void addLikedBachelors(BachelorCandidate bachelor) {
    likedBachelors.add(bachelor);
    notifyListeners();
  }

  void updateLikedBachelor(BachelorCandidate bachelor, bool isLiked) {
    if (isLiked) {
      addLikedBachelor(bachelor);
    } else {
      removeLikedBachelor(bachelor);
    }
  }
}

enum Gender {
  male,
  female,
}

class BachelorCandidate {
  final String firstname;
  final String lastname;
  final Gender gender;
  final String avatar;
  final List<Gender> searchFor;
  final String job;
  final String description;

  BachelorCandidate({
    required this.firstname,
    required this.lastname,
    required this.gender,
    required this.avatar,
    required this.searchFor,
    required this.job,
    required this.description,
  });
}

typedef LikeCallback = void Function(bool isLiked);
