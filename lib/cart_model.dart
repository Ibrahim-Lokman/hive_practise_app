//

class Product {
  final String name;
  final double price;
  final double vat;
  final int quantity;

  Product(
      {required this.name,
      required this.price,
      required this.vat,
      required this.quantity});
}

class ActiveCartItem {
  String shopname = '';
  List<Product> items = [
    Product(name: "name 1", price: 140, vat: 8, quantity: 5),
    Product(name: "name 2", price: 114, vat: 5, quantity: 6)
  ];
}

/*
=> active_cart_list ds : ()
{
 'shopname' : "ibrahim Store",
 'items': { 
     'product_name_id_1': {name: 'abc', quantity: 10*, unitprice: 200, vat_percentage: 0.3, totalprice: ....,  },
     'product_name_id_2': {name: 'efg', quantity: 21*, unitprice: 350, vat_percentage: 0.4, totalprice: ....,  },
  }
 'items_overall_price': ......;

}
*/