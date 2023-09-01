import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class CartController extends GetxController {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final activeCartItems = Hive.box('activeCartItems');
//  var activeShopData = Hive.box('activeShop');

// bool _isLoading = true;

  Future<void> addItem() async {
    await activeCartItems.add({
      "name": _nameController.text,
      "description": _descController.text,
    });
    refreshItems();
  }

  Future<void> updateItem(int id) async {
    await activeCartItems.put(id, {
      "name": _nameController.text,
      "description": _descController.text,
    });
    refreshItems();
    print("..number of items ${items.length}");
  }

  Future<void> deleteItem(int id) async {
    await activeCartItems.delete(id);
    Get.showSnackbar(GetSnackBar(
      message: 'successfully deleted!',
    ));
    refreshItems();
    print("..number of items ${items.length}");
  }

  void refreshItems() async {
    final data = await activeCartItems.keys.map((key) {
      final item = activeCartItems.get(key);
      return {
        "id": key,
        "name": item["name"],
        "description": item["description"],
      };
    }).toList();

    items = data.reversed.toList();
    print("amount data is (hive) ${activeCartItems.length}");
    print("amount data is (lcal) ${items.length}");
  }

  void showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingJournal =
          items.firstWhere((element) => element['id'] == itemKey);
      _nameController.text = existingJournal['name'];
      _descController.text = existingJournal['description'];
    }
    showModal(ctx, itemKey);
  }

  Future<dynamic> showModal(BuildContext context, int? itemKey) {
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
                    controller: _descController,
                    decoration: const InputDecoration(hintText: 'Quantity'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (itemKey == null) {
                        await addItem();
                      }
                      if (itemKey != null) {
                        await updateItem(itemKey);
                      }

                      _nameController.text = '';
                      _descController.text = '';
                      Navigator.of(context).pop();
                    },
                    child: Text(itemKey == null ? 'Add Product' : 'Update'),
                  )
                ],
              ),
            ));
  }
}
