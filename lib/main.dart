import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrito de Compras',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(),
    );
  }
}

// Producto (Stateless)
class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});
}

// Pantalla principal que muestra la lista de productos (Stateless)
class ProductListScreen extends StatelessWidget {
  final List<Product> products = [
    Product(name: "Laptop", price: 1000.00),
    Product(name: "Teléfono", price: 500.00),
    Product(name: "Audífonos", price: 100.00),
    Product(name: "Teclado", price: 75.00),
    Product(name: "Mouse", price: 50.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navegar a la pantalla del carrito
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductItem(product: products[index]);
        },
      ),
    );
  }
}

// Widget para cada producto (Stateless)
class ProductItem extends StatelessWidget {
  final Product product;


  ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
      trailing: IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          // Agregar producto al carrito
          CartModel.of(context)?.addProduct(product);
        },
      ),
    );
  }
}

// Modelo de carrito (Stateful)
class CartModel extends StatefulWidget {
  final Widget child;

  CartModel({Key? key, required this.child}): super(key: key);

  static _CartModelState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CartModelState>();
  }

  @override
  _CartModelState createState() => _CartModelState();
}

class _CartModelState extends State<CartModel> {
  List<Product> _cart = [];

  void addProduct(Product product) {
    setState(() {
      _cart.add(product);
    });
  }

  double get totalPrice {
    return _cart.fold(0, (total, product) => total + product.price);
  }

  @override
  Widget build(BuildContext context) {
    return InheritedCart(
      data: this,
      child: widget.child,
    );
  }
}

// InheritedWidget para compartir el estado del carrito
class InheritedCart extends InheritedWidget {
  final _CartModelState data;

  InheritedCart({Key? key, required this.data, required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedCart oldWidget) {
    return true;
  }
}

// Pantalla del carrito de compras (Stateful)
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartState = CartModel.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
      ),
      body: cartState != null && cartState._cart.isNotEmpty
          ? ListView.builder(
        itemCount: cartState._cart.length,
        itemBuilder: (context, index) {
          final product = cartState._cart[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
          );
        },
      )
          : Center(
        child: Text('El carrito está vacío'),
      ),
      bottomNavigationBar: cartState != null && cartState._cart.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Total: \$${cartState.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 20),
        ),
      )
          : null,
    );
  }
}
