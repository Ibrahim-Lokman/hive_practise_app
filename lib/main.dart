import 'package:dotted_border/dotted_border.dart';
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

enum PaymentOption { cash, card }

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  PaymentOption? _paymentOption = PaymentOption.cash;
  List<Map<String, dynamic>> items = [];
  final hiveCrudBox = Hive.box('hive_crud_box');
  // bool _isLoading = true;

  void _refreshItems() async {
    final data = await hiveCrudBox.keys.map((key) {
      final item = hiveCrudBox.get(key);
      return {
        "id": key,
        "name": item["name"],
        "description": item["description"],
      };
    }).toList();

    setState(() {
      items = data.reversed.toList();
      print("amount data is (hive) ${hiveCrudBox.length}");
      print("amount data is (lcal) ${items.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _addItem() async {
    await hiveCrudBox.add({
      "name": _nameController.text,
      "description": _descController.text,
    });
    _refreshItems();
  }

  Future<void> _updateItem(int id) async {
    await hiveCrudBox.put(id, {
      "name": _nameController.text,
      "description": _descController.text,
    });
    _refreshItems();
    print("..number of items ${items.length}");
  }

  Future<void> _deleteItem(int id) async {
    await hiveCrudBox.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('successfully deleted!'),
    ));
    _refreshItems();
    print("..number of items ${items.length}");
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingJournal =
          items.firstWhere((element) => element['id'] == itemKey);
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
        title: Text("Hive Cart"),
      ),
      body: CartPageBody2(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Column CartPageBody2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              child: Text(
                                "Print Invoice  ",
                                style: TextStyle(),
                              ),
                            ),
                            Icon(
                              Icons.print_outlined,
                              color: Colors.yellow,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Cart",
                        style: TextStyle(color: Colors.purple),
                      ),
                      Text("Total  34 Items")
                    ],
                  ),
                ),
                Container(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      // Map<String, dynamic> cartItem = cartItems[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.only(left: 10, top: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 0.5, color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0) //
                                        ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.oil_barrel,
                                    color: Color.fromARGB(255, 250, 232, 67),
                                    size: 30,
                                  ),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              items[index]['name'],
                                              style: TextStyle(),
                                              maxLines: null,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Tk dummy 500",
                                                  style: TextStyle(
                                                      color: Colors.purple),
                                                ),
                                                Text("Qty: Dummy")
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.mode_edit_outline_outlined,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _showForm(context, items[index]['id']),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteItem(items[index]['id']),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 15, bottom: 20),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      child: Text(
                        '+ Add More',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00B383),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal",
                              style: TextStyle(fontFamily: "Inter-Bold"),
                            ),
                            Text(
                              "Tk 2489.00",
                              style: TextStyle(fontFamily: "Inter-Bold"),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Offer",
                              style: TextStyle(fontFamily: "Inter-Regular"),
                            ),
                            Text(
                              "Tk 8900.00",
                              style: TextStyle(fontFamily: "Inter-Regular"),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "VAT (7%)",
                              style: TextStyle(fontFamily: "Inter-Regular"),
                            ),
                            Text(
                              "Tk 780.00",
                              style: TextStyle(fontFamily: "Inter-Regular"),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    color: Color(0x0D6528F7),
                    child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(5),
                        dashPattern: [5, 5],
                        padding: EdgeInsets.all(20),
                        color: Colors.grey,
                        strokeWidth: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.discount,
                              color: Color(0xFFFB3580),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                "Apply a Voucher",
                                style: TextStyle(
                                    color: Colors.purple,
                                    fontFamily: "Inter-Bold"),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10, left: 10),
                  child: Text(
                    "Select Payment Type",
                    style: TextStyle(fontFamily: "Inter-Bold", fontSize: 16),
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Radio<PaymentOption>(
                          activeColor: MaterialStateColor.resolveWith(
                              (states) => Colors.purple),
                          value: PaymentOption.cash,
                          groupValue: _paymentOption,
                          onChanged: (PaymentOption? value) {
                            setState(() {
                              _paymentOption = value;
                            });
                          },
                        ),
                        Text("Cash")
                      ],
                    ),
                    Row(
                      children: [
                        Radio<PaymentOption>(
                          activeColor: MaterialStateColor.resolveWith(
                              (states) => Colors.purple),
                          value: PaymentOption.card,
                          groupValue: _paymentOption,
                          onChanged: (PaymentOption? value) {
                            setState(() {
                              _paymentOption = value;
                            });
                          },
                        ),
                        Text(
                          'Credit Card',
                          style: TextStyle(fontFamily: "Inter-regular"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey, //New
                blurRadius: 7,
                spreadRadius: 5,
                offset: Offset(0, 3),
              )
            ],
          ),
          margin: EdgeInsets.only(top: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Order",
                    style: TextStyle(fontFamily: "Inter-Bold"),
                  ),
                  Text('20 Items'),
                  Text(
                    "TK 17800.00",
                    style: TextStyle(
                        fontFamily: "Inter-Bold", color: Colors.green),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 15,
                ),
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  child: Text(
                    'Place Order',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Get.to(CartPage());
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
