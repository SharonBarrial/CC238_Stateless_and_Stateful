import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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

  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navegar a la pantalla del carrito
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
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

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
      trailing: IconButton(
        icon: const Icon(Icons.add),
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

  const CartModel({super.key, required this.child});

  static CartModelState? of(BuildContext context) {
    return context.findAncestorStateOfType<CartModelState>();
  }

  @override
  CartModelState createState() => CartModelState();
}

class CartModelState extends State<CartModel> {
  final List<Product> _cart = [];

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
  final CartModelState data;

  const InheritedCart({super.key, required this.data, required super.child});

  @override
  bool updateShouldNotify(InheritedCart oldWidget) {
    return true;
  }
}

// Pantalla del carrito de compras (Stateful)
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = CartModel.of(context);

    return Scaffold(
      // AppBar dont have a const constructor because it is a StatefulWidget
      appBar: AppBar(
        // title have a const constructor because it is a StatelessWidget
        title: const Text('Carrito de Compras'),
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
          : const Center(
        child: Text('El carrito está vacío'),
      ),
      bottomNavigationBar: cartState != null && cartState._cart.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Total: \$${cartState.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 20),
        ),
      )
          : null,
    );
  }
}
