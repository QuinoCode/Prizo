import 'package:prizo/shared/data_entities/producto.dart';

class ProductoCompra {
  final Producto producto;
  int cantidad;

  ProductoCompra({required this.producto, this.cantidad = 1});
}

class ListaCompra {
  final String id;
  final String usuario;
  List<ProductoCompra> productos;

  ListaCompra({required this.id, required this.usuario, required this.productos});

  void addProduct(Producto thisProduct) {
    ProductoCompra? existingProduct;
    for (var productoCompra in productos) {
      if (productoCompra.producto.equals(thisProduct)) {
        existingProduct = productoCompra;
        break;
      }
    }

    if (existingProduct != null) {
      existingProduct.cantidad++;
    } else {
      productos.add(ProductoCompra(producto: thisProduct));
    }
  }

  void removeProduct(Producto thisProduct) {
    ProductoCompra? existingProduct;
    for (var productoCompra in productos) {
      if (productoCompra.producto.equals(thisProduct)) {
        existingProduct = productoCompra;
        break;
      }
    }

    if (existingProduct != null) {
      if (existingProduct.cantidad > 1) {
        existingProduct.cantidad--;
      } else {
        productos.remove(existingProduct);
      }
    }
  }
}