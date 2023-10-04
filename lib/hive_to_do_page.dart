import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

enum PaymentOption { cash, card }

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _vatController = TextEditingController();
  PaymentOption? _paymentOption = PaymentOption.cash;
  List<Map<String, dynamic>> items = [];
  final activeToDoItems = Hive.box('activeToDoItems');
  var totalCartPrice = 0.0;
//  var activeShopData = Hive.box('activeShop');

  // bool _isLoading = true;

  Future<void> addItem() async {
    int totalPriceBeforVat =
        int.parse(_quantityController.text) * int.parse(_priceController.text);
    print("Total price:  ${totalPriceBeforVat}");
    double vat = totalPriceBeforVat * (int.parse(_vatController.text) / 100);
    print("Vat:  ${vat}");
    await activeToDoItems.add(
      {
        "code": "product_name_code",
        "name": _nameController.text,
        "quantity": _quantityController.text,
        "vat": _vatController.text,
        "price": _priceController.text,
        "total_before_vat": totalPriceBeforVat,
        "total_after_vat": totalPriceBeforVat - vat,
      },
    );
    refreshItems();
  }

  Future<void> updateItem(int id) async {
    int totalPriceBeforVat =
        int.parse(_quantityController.text) * int.parse(_priceController.text);

    double vat = totalPriceBeforVat * (int.parse(_vatController.text) / 100);

    await activeToDoItems.put(id, {
      "code": "product_name_old_code",
      "name": _nameController.text,
      "quantity": _quantityController.text,
      "vat": _vatController.text,
      "price": _priceController.text,
      "total_before_vat": totalPriceBeforVat,
      "total_after_vat": totalPriceBeforVat - vat,
    });
    refreshItems();
    print("..number of items ${items.length}");
  }

  void refreshItems() async {
    if (activeToDoItems.keys.length == 0) totalCartPrice = 0.0;
    totalCartPrice = 0.0;
    final data = await activeToDoItems.keys.map((key) {
      final item = activeToDoItems.get(key);
      print("totalCartPrice : ${totalCartPrice}");
      print("total_after_vat: ${item["total_after_vat"]}");
      totalCartPrice = totalCartPrice + item["total_after_vat"];
      return {
        "id": key,
        "code": "product_name_old_code",
        "name": item["name"],
        "quantity": item["quantity"],
        "price": item["price"],
        "vat": item['vat'],
        "total_after_vat": item["total_after_vat"],
      };
    }).toList();

    setState(() {
      items = data.reversed.toList();
      print("amount data is (hive) ${activeToDoItems.length}");
      print("amount data is (lcal) ${items.length}");
    });
  }

  Future<void> deleteItem(int id) async {
    await activeToDoItems.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('successfully deleted!'),
    ));
    refreshItems();
    print("..number of items ${items.length}");
  }

  void clearController() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _vatController.dispose();
  }

  void showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingJournal =
          items.firstWhere((element) => element['id'] == itemKey);
      _nameController.text = existingJournal['name'];
      _quantityController.text = existingJournal['quantity'];
      _priceController.text = existingJournal['price'];
      _vatController.text = existingJournal['vat'];
    }

    showModal(itemKey);
  }

  Future<dynamic> showModal(int? itemKey) {
    if (itemKey == null) {
      _nameController.text = '';
      _quantityController.text = '';
      _priceController.text = '';
      _vatController.text = '';
    }
    return showModalBottomSheet(
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
                    decoration: const InputDecoration(hintText: 'Task Title'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(hintText: 'Importance'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _vatController,
                    decoration: const InputDecoration(hintText: 'Date'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (itemKey == null) {
                        print("item key add:   ${itemKey}");
                        await addItem();
                      }
                      if (itemKey != null) {
                        print("item key update:   ${itemKey}");
                        await updateItem(itemKey);
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text(itemKey == null ? 'Add Task' : 'Update'),
                  )
                ],
              ),
            ));
  }

  @override
  void initState() {
    super.initState();
    refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Hive Todo SFA"),
      ),
      body: CartPageBody2(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(context, null),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Tasks",
                        style: TextStyle(
                            color: Colors.purple,
                            fontSize: 14,
                            fontFamily: "Inter-Bold"),
                      ),
                      Text("Total  ${items.length ?? '0'} Items")
                    ],
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // Map<String, dynamic> cartItem = cartItems[index];
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(left: 10, top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(5.0) //
                              ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
// ${items[index]['quantity']}
//  ${items[index]["total_after_vat"]}
// items[index]['name']
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 8.0,
                                    ),
                                    child: Text(
                                      "Description : ",
                                      style: TextStyle(
                                          fontFamily: "Inter-Regular",
                                          fontSize: 14),
                                    ),
                                  ),
                                  Container(
                                    width: Get.width,
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 234, 234, 234),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "${items[index]['quantity']}",
                                        maxLines: null,
                                        style: const TextStyle(
                                            fontFamily: "Inter-Regular",
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 213, 226, 230),
                                          ),
                                          onPressed: () => showForm(
                                              context, items[index]['id']),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.mode_edit_outlined,
                                                  size: 14,
                                                  color: Colors.black),
                                              Text(
                                                '   Edit',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 213, 226, 230),
                                        ),
                                        onPressed: () =>
                                            deleteItem(items[index]['id']),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete_outline_rounded,
                                                size: 14, color: Colors.black),
                                            Text(
                                              '   Delete',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
