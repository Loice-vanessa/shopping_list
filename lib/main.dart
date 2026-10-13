import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const HomeScreen(title: 'Shopping List'),
    );
  }
}

// The model: one thing to buy.
class Item {
  final String name;
  bool bought;
  int quantity;

  Item({
    required this.name,
    this.bought = false,
    this.quantity = 1,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Item> items = [
    Item(name: 'Milk'),
    Item(name: 'Bread'),
    Item(name: 'Rice'),
  ];
  final TextEditingController controller = TextEditingController();
  String filter = 'All';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void showMessage(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), action: action),
    );
  }

  // Part 3: an item already on the list (any capitals or spaces) gets +1.
  void addItem() {
    final name = controller.text.trim();
    if (name.isEmpty) {
      showMessage('Type an item first');
      return;
    }

    final matches =
        items.where((item) => item.name.toLowerCase() == name.toLowerCase());
    if (matches.isNotEmpty) {
      final existing = matches.first;
      setState(() {
        existing.quantity++;
      });
      showMessage(
          '${existing.name} is already on the list: now ×${existing.quantity}');
    } else {
      setState(() {
        items.add(Item(name: name));
      });
    }
    controller.clear();
  }

  void toggleBought(Item item) {
    setState(() {
      item.bought = !item.bought;
    });
  }

  // Part 2: + has no limit, − stops at 1.
  void increase(Item item) {
    setState(() {
      item.quantity++;
    });
  }

  void decrease(Item item) {
    if (item.quantity <= 1) return;
    setState(() {
      item.quantity--;
    });
  }

  // Parts 4 and 5: delete the item itself (not an index), remember where it
  // was, and let Undo put it back in exactly the same place.
  void deleteItem(Item item) {
    final position = items.indexOf(item);
    setState(() {
      items.remove(item);
    });
    showMessage(
      '${item.name} removed',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          setState(() {
            items.insert(
                position <= items.length ? position : items.length, item);
          });
        },
      ),
    );
  }

  Widget filterChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: filter == label,
      onSelected: (_) {
        setState(() {
          filter = label;
        });
      },
    );
  }

  Widget buildList(List<Item> shown) {
    // Part 1: a truly empty list.
    if (items.isEmpty) {
      return const Center(child: Text('Your list is empty'));
    }
    // Part 5: the filter has nothing to show.
    if (shown.isEmpty) {
      return const Center(child: Text('Nothing here'));
    }
    return ListView.builder(
      itemCount: shown.length,
      itemBuilder: (context, index) {
        final item = shown[index];
        return ListTile(
          title: Text(
            item.name,
            style: TextStyle(
              decoration: item.bought ? TextDecoration.lineThrough : null,
              color: item.bought ? Colors.grey : null,
            ),
          ),
          onTap: () => toggleBought(item),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => decrease(item),
              ),
              Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => increase(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => deleteItem(item),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Part 5: never change items to filter it; build a second list instead.
    final toBuy = items.where((item) => !item.bought).toList();
    final bought = items.where((item) => item.bought).toList();
    List<Item> shown;
    if (filter == 'To buy') {
      shown = toBuy;
    } else if (filter == 'Bought') {
      shown = bought;
    } else {
      shown = [...toBuy, ...bought];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'New item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addItem, child: const Text('Add')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                filterChip('All'),
                filterChip('To buy'),
                filterChip('Bought'),
              ],
            ),
          ),
          Expanded(child: buildList(shown)),
        ],
      ),
    );
  }
}
