import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../widgets/common_widgets.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _promoCtl = TextEditingController();

  @override
  void dispose() {
    _promoCtl.dispose();
    super.dispose();
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
        title: const Text('Keranjang',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              final cart = CartScope.read(context);
              if (cart.isEmpty) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Kosongkan Keranjang?'),
                  content: const Text(
                      'Semua item di keranjang akan dihapus. Tindakan ini tidak bisa dibatalkan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () {
                        cart.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Hapus Semua'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: CartScope.of(context),
        builder: (context, _) {
          final cart = CartScope.of(context);
          if (cart.isEmpty) {
            return _EmptyCart(
              onBrowse: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/menu', (r) => r.isFirst),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    return _CartCard(
                      key: ValueKey(item.id),
                      item: item,
                      onMinus: () => cart.updateQuantity(item.id, item.quantity - 1),
                      onPlus: () => cart.updateQuantity(item.id, item.quantity + 1),
                      onRemove: () {
                        cart.removeItem(item.id);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          kantinSnack(context, '${item.name} dihapus dari keranjang.'),
                        );
                      },
                    );
                  },
                ),
              ),

              // Promo code
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_rounded,
                        color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _promoCtl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Kode promo (coba: KANTIN10)',
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (_) {},
                      ),
                    ),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final cart = CartScope.read(context);
                        final code = _promoCtl.text;
                        final ok = cart.applyPromo(code);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          kantinSnack(
                            context,
                            ok
                                ? 'Promo "$code" diterapkan 🎉'
                                : 'Kode promo tidak valid',
                            error: !ok,
                          ),
                        );
                      },
                      child: const Text('Pakai'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Ringkasan
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Subtotal (${cart.totalQuantity} item)',
                      value: formatRupiah(cart.subtotal),
                    ),
                    const SizedBox(height: 6),
                    if (cart.appliedPromo != null) ...[
                      _SummaryRow(
                        label: 'Diskon (${cart.appliedPromo})',
                        value: '- ${formatRupiah(cart.discount)}',
                        accent: Colors.green,
                      ),
                      TextButton(
                        onPressed: () {
                          CartScope.read(context).clearPromo();
                          _promoCtl.clear();
                        },
                        child: const Text('Hapus promo'),
                      ),
                    ],
                    const Divider(height: 16),
                    _SummaryRow(
                      label: 'Total',
                      value: formatRupiah(cart.total()),
                      big: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text('Lanjut ke Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.pushNamed(context, '/checkout'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;

  const _CartCard({
    super.key,
    required this.item,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    'Varian: ${item.variant}',
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 11),
                  ),
                  if (item.toppings.isNotEmpty)
                    Text(
                      'Topping: ${item.toppings.join(", ")}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 11),
                    ),
                  if (item.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Note: ${item.note}',
                        style: const TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 11,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(formatRupiah(item.totalPrice),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _MiniBtn(icon: Icons.remove, onTap: onMinus),
                            SizedBox(
                              width: 26,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            _MiniBtn(icon: Icons.add, onTap: onPlus),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool big;
  final Color? accent;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.big = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final style = big
        ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        : const TextStyle(fontSize: 13);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style.copyWith(color: accent ?? Colors.black87),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_basket_rounded,
                  size: 64, color: Colors.deepOrange.shade400),
            ),
            const SizedBox(height: 14),
            const Text('Keranjangmu masih kosong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'Yuk pilih menu favoritmu dari daftar menu Kantin Bu Sari!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Jelajahi Menu'),
              onPressed: onBrowse,
            ),
          ],
        ),
      ),
    );
  }
}
