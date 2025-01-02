import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:prizo/shared/data_entities/models/producto.dart';
import 'package:prizo/shared/data_entities/models/lista_compra.dart';
import 'package:prizo/shared/data_entities/models/lista_favoritos.dart';
import 'package:prizo/shared/application/producto_service.dart';
import 'package:prizo/features/lista_compra/application/lista_compra_service.dart';
import 'package:prizo/features/lista_favoritos/application/lista_favoritos_service.dart';

class ListaFavoritosInterfaz extends StatefulWidget {
  ListaFavoritos listaFavoritos;
  final ListaFavoritos original;
  final ListaCompra listaCompra;
  final List<String> tiendasSeleccionadas;

  ListaFavoritosInterfaz({super.key, required this.listaFavoritos, required this.listaCompra, required this.tiendasSeleccionadas, required this.original});

  @override
  _ListaFavoritosInterfazState createState() => _ListaFavoritosInterfazState();
}

class _ListaFavoritosInterfazState extends State<ListaFavoritosInterfaz> {
  final ListaFavoritosService listaFavoritosService = ListaFavoritosService();
  final ListaCompraService listaCompraService = ListaCompraService();
  final ProductoService productoService = ProductoService();
  Map<String, TextEditingController> _mapaControladorCantidad = {};
  Map<String, bool> _mapaProductoConBotonCarrito = {};
  String? _mensajeAdvertencia;
  final String base64ImagePapelera = "iVBORw0KGgoAAAANSUhEUgAAAJ4AAACtCAYAAABBa8Z4AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAu3SURBVHhe7Z2/rlXFF8d5CDstsTNWJlrQkGiDYAUNuZdKQyPJJWJjIDEROyiFSGUFseYBeAFf4L6AD+ALHO/3kE02h7XPWTPrO3utmbOKz6/54ew5M589f9as2ffSH683m2Pn6d//bR48/Wfzwy+vNzfv/rn5+uavW764etcMyrlx+mRb7r3f3mwePjsX63BsHK14EA1CXP78u81HH3+xOpDy5P7Lze9//SvWb3SOSjyMbDfvvth88ulVUQYvIOHPFy+CVOdRORrxMM15jW5aMC0fywg4vHgY5TCiSB0dlZOzV+JvGYmhxXv0/Dz8KLfE9TtPty+N9LtGYFjxIF20tVwpn315e1j5hhRvBOkmRpVvOPGwOO91el0Cmw7pt/bMcOKNJt3EaBuOocRDjE7qtBHA0mGkUMsw4qFTpA4bCYSFpN/eI8OI983FOkjqrNFAIFz6/b0xhHg4d5U6aUQuf35jiF3uEOL1djJhBZkuUjv0RPfirTHaYadcQusYIsrvfdTrXjzmaId4GXLysFFhdSzKQubJ6f2XWyml59bQ+6jXtXis0Q7rJpx2SM9gc+tCGKkOpfQ+6nUtHmMnC+nWjo+x5Ot51OtWPFbcDlOrVH5rGEuEnke9bsVjjXZS2WuAdZ9Up1J6HfW6FK/30W6C8fJg1JPKjk6X4l2/80TshBI+++q2WPaa4AVihF6+d36BauhSPEZYwnu0m8BUKdWvBM8lQy3diQdhpMYvIVJHYXNwjKNed+KNNNpNMNZ6EZYOJXQl3mij3QRrs9TT3dxF8TAFIAUHnR0Fxmh35dsHYtne4G6FVN8SUIZUtgeHPtfxgXg4hjq2bI+kHZhhpPXne+KNnDqe+ILBbH7K8k68lC5pzfyq5la8h8/PxX+YJGymI76teLmmS9ZiSmy4hP+R/kGStAKbjUvHdFEmicH10yebSz/+9kb8P5OkFbhikCNesjrbES/XeMna4GQjd7XJ6uBseiseKw07SQ6Bi07v4niAdfMpSZbAycXk2zvxUr6kJYtntROPnp3nmi+hgVHu9Ozle46BD8SbwAIQa7/dPCsUIj1AC6TeLTPxxZoBPX36Yw7y8eCQ5BZYFG8f0sO1XLn2QCwz8QOiSH2lpSbzeXXxMOJJZSZ+WG+6rSaeJQW9x6t4o2MVD/sCqdx9pHjJdo0m9ZWWx3vWcktUiWfZ9fb6yYWRuXLtJ7GvtMzDJFpWFw9IZSZ+ePRnlXjWobnmDUna4TGDuYhXsyZI2uGxZq8Sz7oLSvFiYRGv9tMZLuL19KmFY0DqIy21cdkq8ayR7nuPx/jrNKMg9ZGW2pMoF/F6/JDgqFg/GIT1vlTuIarEs14QSvHiYBUP9yekcg9RJZ71gtB0mzzxx6svq8TzeksSPlbxToRcOw0u4tWuCxI+Xuv1KvGsVyJTvDh4RSiqxANSJbTUxn4SPl4x2WrxLF8q7+1D0SPTnXiZkzcGXufu1eJZPhad4sXBKl5tplG1eJmTNwZe/VgtnjVrVSqzJXgzMS1EzQX0qptHLh6oFs9rbVACOhIfFd9dj2KZgPrvu/e5Bghl7HY8liFr1s1ryVQtnvUvKLYWDxH5QztvNJzHuTGk0nQ4Xhrpv2fikYsHqsWzbsNrrsRpwS126ZlLnJy9EstpAaQr6ezW8knP1GKJx1aLd3Lf9imLVsmg6NjSGCP+/VpTW80I03JUlp6nxUW8qDl5td8BsTSilto2syzi94GXTXqeFqxFpXI1DCde6Wg3p/Wu0rKDbDFDWMWzZBlVi+eVTrMPa51ap+RLz9TSIofRKxcPVIuHzYFUGS0tGjJyZjRGU+mZWizT2hJdiuc5TC8RdfoHnuupJTxfVDfxWjRkileGtb0sS5Nq8YBUGS0tPtCY4pVhjcVaNjxu4rUIX6R4ZXQrntdxyxIpXhmex55u4rXIyUvxykCZ0rO0uIlnyWxoEY1P8cqwBLSBVKYWk3ieFZdI8croVjzrUM0+okrxyvC8vuAqHjsnL8Urw3NzaBIvWjJoileG9Bwt1nCYSTzPOJBEileG9BwtruJZk0HZ2SApnh7vpAWTeNE6OsXT410fk3jR0pBSPD2eKVHAJJ535XdJ8fR0LV60ZNAUT4/3bGUSL1pjpnh6vNvKJF60dO4UT4/39VSTeECqlBZrLGiXFE+PdwzWLJ7lOmGKp4ctnvepk1m8SDl5KZ4elCc9R0uKNyPF0+OZEgXM4nn/gDkpnp7uxYv0gcYUT49nLh4wi+e9VpiT4unxXiKleDOOSTzvaIRZPGs8iPmBxhRPj/QMLUOIx0wGTfF0RDhxMosXqbNTPB0R6pLizTgW8SJkFZnFs+Z1MT/QmOLpiJBH6S4e40dMpHg6ImSOm8WzNijzA40pno4I7eQu3mgNukSkdorwpyLM4gGpclqYH2hM8XRECIG5i8cIRk6keDqsuXiMoD9FPM9vcMxJ8XSgLOkZWhjHnO7iMXPyUjwdETKKKOJF+UBjiqcjQg4lRbwIPwSkeDos/cUaKCjiWdcMrA80png6IiyNQojHyslL8XREuBlIES/KBxpTPB1S+VpCiRclJy/FO4w1F48V8KeIF+UDjSneYaLUgyJelA5P8Q4T5QtfFPGsaTasnDxrPVr+oWTrFMfK4omSxkYRL8qPsY4qzItHEpbdZJSXkzUrUMSzdjgzJ6/2FIX9OQ0Jy+4fbSyVWYp1OcKaFUKIxwwV1DYs/jupPCbYvUvPPgSzfaJEICjiAamSWth/NLn0SGiN0W7iVmHHo26s0Q5ESIkCNPEs6xf2367FQl57LMTuWA3azkebPnrOXXdi9JSepYUV7KeJFyU1as6hDr5xsbZknROXgql9X5th1G7xQlgSBIBUZg008SypUUAqkwE6D50MyfC2g9P7L92E2+XexS5zt26sdZSERTxWZgqgiWdNLowiwuhEmZlo4kVZOyT7kdpeCytBANDEs27TW54aJG+xhr2Y0QeaeNbAZMtz0uQt1hMmZqCfJp71KIZ1bJYsE+VMHdDEsw7jWCNK5SY8Ii2HaOJZsy/YQeTkQ6yRB2aYhyYesJxeMGNEiYw11soMeVHFs/6wDKm0RWpzLeyBgSqeNZaXO9t2WHe0zBgeoIpnvXvB3K4n7xOtb6ji1eabTayZnnRsWJMDmKEUQBXPurMFuc7jw+gXduICVTxg3WBkIJmP9VSpRcSBLp41wxU/MjNVuFinWfbGAtDFsx7LgJOzV2LZSTnW3Sxgr+8AXTyMVpZAMshRj4cl/26ixbVPunjAOrQD9gWgY+Tm3Rdi25bQKtLQRDxrzGgip9x6kFIvtWkprWKrTcRjTLcTeZpRDm6msdq/1Q28JuIB6+52Tsqnhyldi93sRDPxrPl5u+S0exjsYFnSgZbXEZqJB74xJg3scv3O09ztLsDYSMxpfXzZVDyMesw3EKBBfsyLQe/A1MqIIuzS8m4vaCoesKZbL4EUrNaNExlMq+wZZWKNawjNxcPUyAhiLoEREA2F8MHI0zB+G2TDlNpihJtAe7bayc5pLh7AdCD9yBZgakfH4LMQGG1xQI6RESDzBUQSFHWZ6vXw2fn2BUKdEQvFb0AgveWLuwueLdWTzSrigdMzTlC5FejcNWCveZlAdKnvWrCaeKDVmiSxg3Q2qc9asap4mFas+XoJn7XWdXNWFQ9APkw5UgMk6+MhHVhdPIAfmvL54yUdcBEP4AfntOuHp3TATTyAaffKtw/EhknagRfeUzrgKt5E6ZfQk3oQMokQxwwhHkCAN9d97UD8ELFUqe09CCMewPCfsT4+OMnxnlp3CSXeBC6X5OhnBxsIHMFJbexNSPEmcG6YApYD4bBujrCWWyK0eBNY/2EKjnzOGQFMqb2kinUh3hxMHZAwR8K3GwakhGFmiDy6SXQn3hwsmCEi0p8QDxw5II0XDb8R4RCIFm2zUErX4i2Bt3/KwUMn4c80QU50GkYIgE7E1LQPdLYFvAhSuRNTXQDqhjqirqgzXijkMfYumMxm8z8LpdeoQSEEGQAAAABJRU5ErkJggg==";
  final String base64ImageBolsa = "iVBORw0KGgoAAAANSUhEUgAAALYAAAC9CAYAAAAeN4fHAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAvhSURBVHhe7Z2/jhzFFof9DA4RyXXgAAesIDMSBHY2vk7GgaXdaNcRd50hI9AGIO2Vdrki88pkm4GIkd+AJ2BfAPwC9z7BHeY3do97ek7PVPU53VWn6hd8CaxrZqq/Pn3q1J++dfXbYkHs+fHX/y3Or98sTr97vXj24ufF/PhiMXv67eLB43+J4P8D/P1XP/y++rdSuyQMim0AJIaMR89fLT57eLS4c/fjxe3bt9V88OE/Fp/e/+dK/Gdf/7w4e3kjfj7ZhmIPBCI/WUZYiCdJORZ37h6sbh6Ifn79l/jdCMWOopEZkVSSLgW4sSA5nhrSd64Vir0HCIMUY+rIHAtuNqQsjOJvodg9QOjconMouAnxdJF+Vy1Q7A6ehe6CfLxWwSl2C6QcJQjdBYPN2lIUir0EUe3ewReiFCWBJ1Etg8yqxcZFfvT0G1GCUlmlJ/8pPz2pVuyzqz9WF1m6+DWA6C31SylUKTZyaeli1wZu7FJz76rERurx4PGX4kWuFch9+v1rsb88U43Y/15GphoGiEMpLTWpQmxIXXM+HUpJchcvNqWOA9PyUj96o2ixUflINeGCz73/8Gi1BhuLlJDHYo01aNeSm/+GEhz+BgNbyPVJwrUpJchdrNhTR2qIDBkhpuUmAQiPm+Ojg8/Fzx0L73IXKfaUUkNmRNopZvTwuyD5VL/Nc85dnNhTSI3oPD+5TDo9jfRminTFq9zFiT3muukchO6CVGXsG9ljnbsosZ+cXIgXxgJEx5xn6RDBxxIcN7S3GcpixMZOcOmiaIEsXhYNNTm49Du03FsOXnN6Uu2jCLHHyquxjtnTxWwYK3o/Wt400uflSBFij5FXHz7/SfwsL+BmR5SVfpsGL08v92JbpyDIJ71cvBCsUxM8CTw8xVyLbZ2CoC3MVkqf5RlUcqTfOxQPKYlrsTE7JnX8ECB1yfsCreXO/anmVmxEa6nDh1C61A2WcmNcI31GLrgV23LAWGL60YflUy7nqO1SbHSo1NFD8F79GIJVtSTnqO1SbKtoPT++FNsvHctBd65R253YVtEaF1Zqvxas+jHXqO1ObKscsYbB4j6satw5Rm1XYltVQmpNQbpgosUiJclxU4IrsQ8NzgOpPQXpgiWpUj/FgNna3GYjXYltEV2wQEhqu2YsBuOHp6/EtlPhRmyLwQ6jtYxF3+Y2iHQj9szg8EhG634sonZO6YgbsbVpCKP1biyidk7piAuxLaohjNb7wSBQ6rtQckpHXIhtseaadev9zJV7RnFjSO2mwIXYOFFJ6shQvB/+MhXIkaX+iyGXBWUuxNbm1x6PD0iFdhCZS56dvdgWUSS3yYOc0aYjuTwdsxdbO1rHeSBSu0RG29+5VJ+yF1s7jT57+o3YLulHWx2R2pyawWLj8X728mZVsQDz44sNsHIMjyUt2vz60/uPxXZJP1qxcR6L1G6XrjM4qRYu4fWEcEuTQgaLjQ/BB+NLa384IaFgtw9ugtPv4k603Ss27h6L6VZCtCCgQvKQOYlesXF3IDpLH0BIavYdbyyKXfvLPYkPkKb0Re8tsVO+t4WQWBCApdx7Q2zrI8MImQJp8dWG2JSaeAXlwrbLa7GtTy0lZGra+fZabEZr4h2UAjfEZrQmJYCix4+//ve92Nr1zoTkwskySK/FZnmPlEKTjtxC3Vr6A0I8grHi1W//X9yy2J1MSC4g+1iJzYEjKQ0MINViI6fB0QaI/GdXN4vz6zeERAFv4A+AS9qD6c+v/9SLzY2yxBoES8m1UEzEbsorhFihLT+vcmzsTJD+ZyjdOXpCtGg3tqzE1pb72tOYhFigmVdZl/u05+Jhl4305QgZAtZWS56F0hy3oZ55fHuHyF+SkFi0GUQTaFdi37n7sfhHocTsHiZkF1ZjPpNFULjL2l+OkKFATMmxUDYWQc2UbwtgyY9YoQ2ymORBOyuxtbXsGY8RI0Z8pJx13FiPbZWwE6JBWxFpFkChrZXY2gZZGSEWaFeatk/WXYkNWBkhqbE8WXctNisjJDVaB9sv0FqLPWNlhCRGu0WxHVzXYrMyQlKiLWC8HTi+b28tNisjJCXaGcfuK1nWYrMyQlIyU6bCvUecAVZGSCq0a7CbGceGDbFZGSGpkHyKoRtUN8SesTJCEqCdmLl38MVWmxtiszJCUqCdmJF2cW2IzcoISYF2qWp7YqZhQ2xWRkgKtGJLY7sNsQErI2RqNDXs7sRMw5bYrIyQqUEwHDqd3ndKwpbYM1ZGSALmJ8PSkeDX4bEyQlKAqB17Zt/8+FJsC2yJzcoISUXM6xh3SQ22xGZlhKRmfnLZKzgWO3WnzyW2xAasjNQJrhtSUZTfAKoVIS/kHwsI3HyXo+evgoRuEMVmZaQukALsWoSEykNKwYcgij1jZaQaEIRCSm34GxzQLrWRI6LYrIzUASJ1TP3Yk9yi2DyBtQ5CKxBtUJKT2soNUWwg/ahQcGdLbZJ80ExjxwziUtErNisjZaN5z4uHw/57xdb8cODhrq4ZzVYsaWF/bvSKrV1KeHj6SmyX5IHmiexhEq5XbFZGyqZasbWVETzqpHZJHlQrNpB+VCisjORN1WKzMlIuVYvNyki5VC02KyPlUrXYrIyUS9ViszJSLlWLDaQfFgorI/lSvdiaDgCsjORJ9WKzMlIm1YutPTCQlZE8qV5s7SsUZqyMZEn1YrMyUibViw1i9sV1YWUkTyj2Eu2L271t3a8Bir1EWxk5/f612C5JB8VewspIeVDsJdrKiIfNn7VBsZdoKyMeNn/WBsV+BysjZUGx38HKSFlQ7HewMjIt59dvRkUrttSmJVKfxBAsNisj44JVkE+OL1QH2ZQGzgnEOxyHrBANFpuVkfHAUb6IglK/kbdPiNhTXoPFZmVkHELPpyZ4oUC43MFiA1ZGbEGwYKQOBw6FpiVRYrMyYssj5ZsjagQnJ0h92SVKbFZGbGG0jif0yR8lNisjdmjHLDUT8uSPEpuVETuwF1TqI7KfkH20UWKzMmKH9g3INWMuNmBlxAaM7qU+IvsJqYxEi83KiB2cZYwHr5yW+rJLtNisjNjBPDseTLFLfdklWmxWRmyZPf1W7CeyDfpK6kOJaLFZGbFH+xSsgVhvosVmZWQc8IjlhM02KDgcPv9J7LNdRIsNWBkZD4xBMG2MCDUm2msotWkJ+gBjkCFLVsEgsVkZ8Q930AjgjpJ+cCisjKSHYguwMuIfii3Ayoh/KLaAtjLioWNKh2L3oBlVg6GjXWIDxe5Bu84Bq9ukdsk0UOweZsptTScvwub8yThQ7B74clPfUOwetAvlObWeFordg3ahPKfW00Kxd6DpHMABZDoo9g60U+ucgUwHxd6BdmqdM5DpoNg70A4gPXRQqVDsHWAAqZ2B5BLWNFDsPWhnIJlnp4Fi72GmnIHkK6nTQLH3oF3CilSGC6Kmh2LvQTtRA0KOrCK2UOwAtHk205HpodgBzE8uxA6IgenItFDsACyO6go9qZ7YQLED0daz8e9Z054Oih2IRTrCXHs67j88Eq9BCKEnnqbETGyrk0PxEk+pfWKLJhB5mFQzExtoqyMNlHt8NMshPKSMpmJrV/u1wco/5tzjMiRqz48vxbZyw1Rsi0VRbTBIwSmkFHw8YtbUe1pmbCo2sBhESiDNOVo+Eb76gbOU1sxPLsU+bxNz6HoOmIttHbX7uHfw+Up2dDhq4Ng1DyA+OHt5s4z0bzbgJFA/ON0LEbl9ki5Kguhfj0sezMUGlrm2d3ADcrwwPaOIDawqJCXBas90jCY2Hm1TpCTe8DQA88xoYgOmJDJH3DU0OqOKDfi6t23wJONAdlxGFxsw396Gez3HZRKxEZ1QHZAucK0w1x6XScRuYFryHg8r5DwzqdggZJarBij2uEwuNsBMFtaBSBe8FmY8H3xUkogNkHfXHL35rstxSSZ2Q7NGQbr4peJha5V3kovdAMFreVE+zwUfn2zEbnN2dbNaoooBliSGZ559/Yv4m4ktWYrdBYNNiI5yIWRvL630Ar63x+WfXnEhdh8YgCK6QxgMxpDK4AbA+uwG5O8p8bqe2TeLxd8yDuFCIjGxjQAAAABJRU5ErkJggg==";

  Uint8List _decodeBase64Image(String base64String) {
    return base64.decode(base64String.split(',').last);
  }

  void _toggleTienda(String tienda) {
    setState(() {
      if (widget.tiendasSeleccionadas.contains(tienda)) {
        widget.tiendasSeleccionadas.remove(tienda);
      } else {
        widget.tiendasSeleccionadas.add(tienda);
      }
      List<Producto> productosFiltrados = [];
      if (widget.original.productos.isNotEmpty && widget.tiendasSeleccionadas.isNotEmpty) {
        for (var producto in widget.original.productos) {
          if(widget.tiendasSeleccionadas.contains(producto.tienda)) {
            productosFiltrados.add(producto);
          }
        }
      } else {
        productosFiltrados = widget.original.productos;
      }
      widget.listaFavoritos = new ListaFavoritos(id: widget.original.id, usuario: widget.original.usuario, productos: productosFiltrados);
    });
  }

  TextEditingController _crearCantidadController(Producto producto) {
    String key = productoService.generarClave(producto);
    if (!_mapaControladorCantidad.containsKey(key)) {
      _mapaControladorCantidad[key] = TextEditingController();
      _mapaControladorCantidad[key]!.text = listaCompraService.getCantidadProducto(widget.listaCompra, producto).toString();
    }
    return _mapaControladorCantidad[key]!;
  }

  void actualizarCantidadController(Producto producto) {
    _mapaControladorCantidad[productoService.generarClave(producto)]!.text = listaCompraService
        .getCantidadProducto(widget.listaCompra, producto)
        .toString();
  }

  void _manejadorTextField(String input) {
    /* Verificar que solo se introduzcan números */
    if (input.isNotEmpty && RegExp(r'[^0-9]').hasMatch(input)) {
      /* Si no es un número, mostrar un mensaje de advertencia*/
      setState(() {
        _mensajeAdvertencia = 'Solo números';
      });
      /* Evitar que se agregue el carácter no permitido */
      /* Esta parte lo hace imposible */
      _mapaControladorCantidad.forEach((key, controller) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      });
      Future.delayed(Duration(seconds: 2), () {
        /* Limpiar el mensaje de advertencia si han pasado 2 segundos */
        setState(() {
          _mensajeAdvertencia = null;
        });
      });
    } else {
      /* Limpiar el mensaje de advertencia si el input es válido */
      setState(() {
        _mensajeAdvertencia = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool tieneDia = widget.tiendasSeleccionadas.contains("DIA");
    bool tieneConsum = widget.tiendasSeleccionadas.contains("CONSUM");
    bool tieneCarrefour = widget.tiendasSeleccionadas.contains("Carrefour");
    final Uint8List papeleraImage = _decodeBase64Image(base64ImagePapelera);
    final Uint8List bolsaImage = _decodeBase64Image(base64ImageBolsa);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Lista de Favoritos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /* Fila de botones "Día", "Consum", "Carrefour" */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () { _toggleTienda("DIA"); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneDia ? Color(0xFF95B3FF) : Colors.white,
                    side: BorderSide(color: Color(0xFF95B3FF)),
                  ),
                  child: const Text('Día'),
                ),
                ElevatedButton(
                  onPressed: () { _toggleTienda("CONSUM"); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneConsum ? Color(0xFF95B3FF) : Colors.white,
                    side: BorderSide(color: Color(0xFF95B3FF)),
                  ),
                  child: const Text('Consum'),
                ),
                ElevatedButton(
                  onPressed: () { _toggleTienda("Carrefour"); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneCarrefour ? Color(0xFF95B3FF) : Colors.white,
                    side: BorderSide(color: Color(0xFF95B3FF)),
                  ),
                  child: const Text('Carrefour'),
                ),
              ],
            ),
            if (_mensajeAdvertencia != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _mensajeAdvertencia!,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: widget.listaFavoritos.productos.isEmpty
                  ? Center(child: Text('Tu lista de favoritos está vacía.'))
                  : ListView.builder(
                itemCount: widget.listaFavoritos.productos.length,
                itemBuilder: (context, index) {
                  final producto = widget.listaFavoritos.productos[index];
                  final imageUrl = producto.foto;
                  final cantidad = listaCompraService.getCantidadProducto(widget.listaCompra, producto);
                  return Dismissible(
                    key: Key(productoService.generarClave(producto)),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      listaFavoritosService.quitarProducto(widget.listaFavoritos, producto);
                      listaFavoritosService.quitarProducto(widget.original, producto);
                    },
                    background: Container(
                      color: Color(0xFF95B3FF),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Image.memory(papeleraImage, width: 30, height: 30),
                    ),
                    child: ListTile(
                      leading: producto.foto.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Icon(Icons.broken_image);
                        },
                      )
                          : Icon(Icons.image_not_supported),
                      title: Text(producto.nombre),
                      subtitle: Text('${producto.tienda} - €${producto.precio.toStringAsFixed(2)}'),
                      trailing: _mapaProductoConBotonCarrito[productoService.generarClave(producto)] == true
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (cantidad > 1) {
                                setState(() {
                                  listaCompraService.quitarInstancia(widget.listaCompra, producto);
                                  actualizarCantidadController(producto);
                                });
                              } else {
                                setState(() {
                                  listaCompraService.quitarProducto(widget.listaCompra, producto);
                                  _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = false;
                                });
                              }
                            },
                          ),
                          Container(
                            width: 50,
                            child: TextField(
                              controller: _crearCantidadController(producto),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: cantidad.toString(),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                              ),
                              textAlign: TextAlign.center,
                              onChanged: _manejadorTextField,
                              onSubmitted: (value) {
                                int newQuantity = int.tryParse(value) ?? cantidad;
                                if (newQuantity > 0) {
                                  setState(() {
                                    listaCompraService.setCantidadProducto(widget.listaCompra, producto, newQuantity);
                                    actualizarCantidadController(producto);
                                  });
                                } else {
                                  setState(() {
                                    listaCompraService.quitarProducto(widget.listaCompra, producto);
                                    _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = false;
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                if (_mapaControladorCantidad[productoService.generarClave(producto)]!.text == "0") {
                                  listaCompraService.annadirProducto(widget.listaCompra, producto);
                                } else {
                                  listaCompraService.annadirInstancia(widget.listaCompra, producto);
                                }
                                actualizarCantidadController(producto);
                              });
                            },
                          ),
                        ],
                      )
                          : IconButton(
                        icon: Image.memory(bolsaImage, width: 30, height: 30),
                        onPressed: () {
                          setState(() {
                            _mapaProductoConBotonCarrito[productoService.generarClave(producto)] = true;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}