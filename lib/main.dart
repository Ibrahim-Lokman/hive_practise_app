import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('hive_crud_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  final _hiveCrudBox = Hive.box('hive_crud_box');
  // bool _isLoading = true;

  void _refreshItems() async {
    final data = await _hiveCrudBox.keys.map((key) {
      final item = _hiveCrudBox.get(key);
      return {
        "id": key,
        "name": item["name"],
        "description": item["description"],
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      print("amount data is (hive) ${_hiveCrudBox.length}");
      print("amount data is (lcal) ${_items.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _addItem() async {
    await _hiveCrudBox.add({
      "name": _nameController.text,
      "description": _descController.text,
    });
    _refreshItems();
  }

  Future<void> _updateItem(int id) async {
    await _hiveCrudBox.put(id, {
      "name": _nameController.text,
      "description": _descController.text,
    });
    _refreshItems();
    print("..number of items ${_items.length}");
  }

  Future<void> _deleteItem(int id) async {
    await _hiveCrudBox.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('successfully deleted!'),
    ));
    _refreshItems();
    print("..number of items ${_items.length}");
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingJournal =
          _items.firstWhere((element) => element['id'] == itemKey);
      _nameController.text = existingJournal['name'];
      _descController.text = existingJournal['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (itemKey == null) {
                        await _addItem();
                      }
                      if (itemKey != null) {
                        await _updateItem(itemKey);
                      }

                      _nameController.text = '';
                      _descController.text = '';
                      Navigator.of(context).pop();
                    },
                    child: Text(itemKey == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Hive CRUD"),
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(_items[index]['name']),
                  subtitle: Text(_items[index]['description']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(children: [
                      IconButton(
                        onPressed: () =>
                            _showForm(context, _items[index]['id']),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => _deleteItem(_items[index]['id']),
                        icon: const Icon(Icons.delete),
                      ),
                    ]),
                  ),
                ),
              )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
