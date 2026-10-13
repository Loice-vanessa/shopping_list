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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void addItem() {
    final name = controller.text.trim();
    if (name.isEmpty) {
      showMessage('Type an item first');
      return;
    }

    setState(() {
      items.add(Item(name: name));
    });
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

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Widget buildList() {
    // Part 1: a truly empty list.
    if (items.isEmpty) {
      return const Center(child: Text('Your list is empty'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
                onPressed: () => deleteItem(index),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(child: buildList()),
        ],
      ),
    );
  }
}
