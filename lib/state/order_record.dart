import 'cart_state.dart';

/// Model sebuah pesanan yang sudah dikonfirmasi.
class OrderRecord {
  final String orderId;
  final DateTime placedAt;
  final String customerName;
  final String tableOrMethod; // nomor meja / metode ambil
  final List<CartItem> items;
  final int subtotal;
  final int discount;
  final int packagingFee;
  final int total;
  final String note;
  final String paymentMethod;

  const OrderRecord({
    required this.orderId,
    required this.placedAt,
    required this.customerName,
    required this.tableOrMethod,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.packagingFee,
    required this.total,
    required this.note,
    required this.paymentMethod,
  });
}