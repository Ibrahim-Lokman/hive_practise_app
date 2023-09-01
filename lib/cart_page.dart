import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
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
  final activeCartItems = Hive.box('activeCartItems');
  var totalCartPrice = 0.0;
//  var activeShopData = Hive.box('activeShop');

  // bool _isLoading = true;

  Future<void> addItem() async {
    int totalPriceBeforVat =
        int.parse(_quantityController.text) * int.parse(_priceController.text);
    print("Total price:  ${totalPriceBeforVat}");
    double vat = totalPriceBeforVat * (int.parse(_vatController.text) / 100);
    print("Vat:  ${vat}");
    await activeCartItems.add(
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

    await activeCartItems.put(id, {
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
    if (activeCartItems.keys.length == 0) totalCartPrice = 0.0;
    totalCartPrice = 0.0;
    final data = await activeCartItems.keys.map((key) {
      final item = activeCartItems.get(key);
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
      print("amount data is (hive) ${activeCartItems.length}");
      print("amount data is (lcal) ${items.length}");
    });
  }

  Future<void> deleteItem(int id) async {
    await activeCartItems.delete(id);
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
                    decoration: const InputDecoration(hintText: 'Product Name'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(hintText: 'Quantity'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(hintText: 'Price'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _vatController,
                    decoration: const InputDecoration(hintText: 'Vat'),
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
                    child: Text(itemKey == null ? 'Add Product' : 'Update'),
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
        title: Text("Hive Cart"),
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
                      Text("Total  ${items.length ?? '0'} Items")
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
                                                  "Tk: ${items[index]["total_after_vat"]}",
                                                  style: TextStyle(
                                                      color: Colors.purple),
                                                ),
                                                Text(
                                                    "Qty: ${items[index]['quantity']}")
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
                                    showForm(context, items[index]['id']),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteItem(items[index]['id']),
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
                              "Tk ${totalCartPrice}",
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
                              "Offer (15%)",
                              style: TextStyle(fontFamily: "Inter-Regular"),
                            ),
                            Text(
                              "Tk ${totalCartPrice * 0.15 == 0 ? 0 : totalCartPrice * 0.15}",
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
                              "VAT (0%)",
                              style: TextStyle(fontFamily: "Inter-Regular"),
                            ),
                            Text(
                              "Tk 0",
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
                  Text('${items.length ?? '0'} Items'),
                  Text(
                    "TK ${totalCartPrice - totalCartPrice * 0.15}",
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
