import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../state/order_record.dart';
import '../widgets/common_widgets.dart';

enum ServiceType { dineIn, takeaway }

extension on ServiceType {
  String get label => switch (this) {
        ServiceType.dineIn => 'Makan di tempat',
        ServiceType.takeaway => 'Bungkus / Take away',
      };
  IconData get icon => switch (this) {
        ServiceType.dineIn => Icons.table_restaurant_rounded,
        ServiceType.takeaway => Icons.shopping_bag_rounded,
      };
}

enum PayMethod { qris, cash, ewallet }

extension on PayMethod {
  String get label => switch (this) {
        PayMethod.qris => 'QRIS',
        PayMethod.cash => 'Tunai di Kasir',
        PayMethod.ewallet => 'Dompet Digital',
      };
  IconData get icon => switch (this) {
        PayMethod.qris => Icons.qr_code_2_rounded,
        PayMethod.cash => Icons.payments_rounded,
        PayMethod.ewallet => Icons.account_balance_wallet_rounded,
      };
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _tableCtl = TextEditingController();
  final _noteCtl = TextEditingController();
  ServiceType _service = ServiceType.dineIn;
  PayMethod _pay = PayMethod.qris;
  bool _addCutlery = true;

  @override
  void dispose() {
    _nameCtl.dispose();
    _tableCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cart = CartScope.read(context);

    final name = _nameCtl.text.trim();
    final table = _service == ServiceType.dineIn
        ? 'Meja ${_tableCtl.text.trim()}'
        : 'Take away';
    final packagingFee = _service == ServiceType.takeaway
        ? (CartModel.packagingFee * cart.totalQuantity)
        : 0;
    final total = cart.total() + packagingFee;

    final order = OrderRecord(
      orderId: 'BSR-${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
      placedAt: DateTime.now(),
      customerName: name,
      tableOrMethod: table,
      items: List.of(cart.items),
      subtotal: cart.subtotal,
      discount: cart.discount,
      packagingFee: packagingFee,
      total: total,
      note: _noteCtl.text.trim(),
      paymentMethod: _pay.label,
    );

    cart.clear();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/success',
      arguments: order,
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AnimatedBuilder(
        animation: CartScope.of(context),
        builder: (context, _) {
          final cart = CartScope.of(context);
          if (cart.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Keranjang kosong. Tidak ada yang bisa dibayar.'),
              ),
            );
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  title: 'Tipe Pesanan',
                  icon: Icons.dining_rounded,
                  child: Row(
                    children: [
                      for (final s in ServiceType.values)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: s == ServiceType.values.last ? 0 : 8,
                            ),
                            child: _PickCard(
                              selected: _service == s,
                              icon: s.icon,
                              label: s.label,
                              onTap: () => setState(() => _service = s),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'Detail Pemesan',
                  icon: Icons.person_rounded,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pemesan',
                          prefixIcon: Icon(Icons.badge_rounded),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Nama minimal 2 karakter'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      if (_service == ServiceType.dineIn)
                        TextFormField(
                          controller: _tableCtl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Nomor Meja',
                            prefixIcon: Icon(Icons.table_restaurant_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Nomor meja wajib diisi'
                                  : null,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.amber.shade800),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Pesenan dibungkus. Tunggu panggilan di meja ambil ya.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'Metode Pembayaran',
                  icon: Icons.credit_card_rounded,
                  child: Column(
                    children: [
                      for (final p in PayMethod.values)
                        RadioListTile<PayMethod>(
                          contentPadding: EdgeInsets.zero,
                          value: p,
                          groupValue: _pay,
                          onChanged: (v) => setState(() => _pay = v!),
                          activeColor: theme.colorScheme.primary,
                          secondary: Icon(p.icon,
                              color: theme.colorScheme.primary),
                          title: Text(p.label),
                          subtitle: Text(_payDescription(p),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: 'Pengaturan Tambahan',
                  icon: Icons.tune_rounded,
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _addCutlery,
                        onChanged: (v) => setState(() => _addCutlery = v),
                        activeColor: theme.colorScheme.primary,
                        title: const Text('Tambah sendok & garpu'),
                        subtitle: const Text(
                            'Untuk take-away, sekaligus dengan kemasan.'),
                      ),
                      TextFormField(
                        controller: _noteCtl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Catatan tambahan (opsional)',
                          hintText: 'Contoh: pesanan untuk 2 orang',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                _OrderSummary(),
                const SizedBox(height: 96),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: CartScope.of(context),
        builder: (context, _) {
          final cart = CartScope.of(context);
          if (cart.isEmpty) return const SizedBox.shrink();
          final packagingFee = _service == ServiceType.takeaway
              ? (CartModel.packagingFee * cart.totalQuantity)
              : 0;
          final total = cart.total() + packagingFee;
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Tagihan',
                          style: TextStyle(color: Colors.black54)),
                      Text(
                        formatRupiah(total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('Pesan Sekarang',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _placeOrder,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _payDescription(PayMethod m) => switch (m) {
        PayMethod.qris => 'Bayar pakai QRIS di kasir Bu Sari.',
        PayMethod.cash => 'Siapkan uang tunai saat mengambil pesanan.',
        PayMethod.ewallet => 'OVO, GoPay, DANA, ShopeePay, dll.',
      };
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickCard({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? primary : Colors.black54, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Pesanan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          for (final it in cart.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text('${it.quantity}x ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(it.name)),
                  Text(formatRupiah(it.totalPrice)),
                ],
              ),
            ),
          const Divider(height: 16),
          Row(
            children: [
              const Text('Subtotal'),
              const Spacer(),
              Text(formatRupiah(cart.subtotal)),
            ],
          ),
          if (cart.appliedPromo != null)
            Row(
              children: [
                Text('Diskon (${cart.appliedPromo})',
                    style: const TextStyle(color: Colors.green)),
                const Spacer(),
                Text('- ${formatRupiah(cart.discount)}',
                    style: const TextStyle(color: Colors.green)),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                formatRupiah(cart.total()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
