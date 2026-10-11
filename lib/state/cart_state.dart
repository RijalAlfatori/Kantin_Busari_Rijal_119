import 'package:flutter/material.dart';

/// Model satu baris di keranjang. Immutable agar aman dipakai
/// sebagai value dalam [CartModel].
class CartItem {
  final String id;
  final String menuId;
  final String name;
  final String imageUrl;
  final int unitPrice; // harga dasar (sudah termasuk variant)
  final int quantity;
  final String variant;
  final List<String> toppings;
  final String note;

  const CartItem({
    required this.id,
    required this.menuId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.variant,
    required this.toppings,
    required this.note,
  });

  int get totalPrice => unitPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      menuId: menuId,
      name: name,
      imageUrl: imageUrl,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      variant: variant,
      toppings: toppings,
      note: note,
    );
  }
}

/// State global untuk keranjang. Dipakai via [CartScope] (InheritedNotifier)
/// sehingga setiap halaman bisa bereaksi terhadap perubahan tanpa ribet.
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalQuantity => _items.fold(0, (sum, it) => sum + it.quantity);

  int get subtotal => _items.fold(0, (sum, it) => sum + it.totalPrice);

  /// Biaya kemasan flat (dipakai saat take away di checkout).
  static const int packagingFee = 2000;

  /// Promo sederhana: "KANTIN10" -> diskon 10%.
  String? _appliedPromo;
  String? get appliedPromo => _appliedPromo;

  int get discount {
    if (_appliedPromo == 'KANTIN10') {
      return (subtotal * 0.10).round();
    }
    return 0;
  }

  /// Total akhir dengan diskon (biaya kemasan ditambahkan di checkout).
  int total({bool includePackaging = false}) {
    final base = subtotal - discount;
    if (includePackaging) return base + packagingFee;
    return base;
  }

  bool get isEmpty => _items.isEmpty;

  void addItem(CartItem newItem) {
    // Item dengan konfigurasi sama persis -> jumlahkan.
    final existingIndex = _items.indexWhere(
      (it) =>
          it.menuId == newItem.menuId &&
          it.variant == newItem.variant &&
          _listEquals(it.toppings, newItem.toppings) &&
          it.note.trim() == newItem.note.trim(),
    );

    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] =
          existing.copyWith(quantity: existing.quantity + newItem.quantity);
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQty) {
    final idx = _items.indexWhere((it) => it.id == cartItemId);
    if (idx < 0) return;
    if (newQty <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(quantity: newQty);
    }
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((it) => it.id == cartItemId);
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    _appliedPromo = null;
    notifyListeners();
  }

  /// Terapkan kode promo. Return true jika diterima.
  bool applyPromo(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return false;
    if (trimmed == 'KANTIN10') {
      _appliedPromo = trimmed;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearPromo() {
    if (_appliedPromo == null) return;
    _appliedPromo = null;
    notifyListeners();
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Scope InheritedNotifier agar widget mana pun bisa akses [CartModel]
/// lewat [CartScope.of(context)].
class CartScope extends InheritedNotifier<CartModel> {
  const CartScope({super.key, required CartModel super.notifier, required super.child});

  static CartModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope not found in widget tree');
    return scope!.notifier!;
  }

  /// Versi tanpa dependOnInheritedWidgetOfExactType — untuk callback.
  static CartModel read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope not found in widget tree');
    return scope!.notifier!;
  }
}
