import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../state/order_record.dart';
import '../widgets/common_widgets.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtl;
  late final Animation<double> _scale;
  late final AnimationController _progressCtl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _scaleCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _scaleCtl, curve: Curves.elasticOut);
    _scaleCtl.forward();

    _progressCtl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _progress = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressCtl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _scaleCtl.dispose();
    _progressCtl.dispose();
    super.dispose();
  }

  void _startCooking() {
    _progressCtl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as OrderRecord;
    final theme = Theme.of(context);
    final prepMinutes = order.items.fold<int>(
      0,
      (acc, it) => acc + (it.quantity * 3),
    ).clamp(5, 30);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              ScaleTransition(
                scale: _scale,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pesanan Diterima! \u{1F389}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Pesananmu sedang dimasak oleh tim Bu Sari.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              _infoCard(order, theme, prepMinutes),
              const SizedBox(height: 14),
              _progressCard(theme, prepMinutes),
              const SizedBox(height: 14),
              _itemsCard(order, theme),
              const SizedBox(height: 18),
              _actionButtons(context, theme),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(OrderRecord order, ThemeData theme, int prepMinutes) {
    Widget row(IconData icon, String label, String value) {
      return Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.black54)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row(Icons.confirmation_number_rounded, 'Nomor Pesanan', order.orderId),
            const Divider(height: 20),
            row(Icons.table_restaurant_rounded, 'Untuk', order.tableOrMethod),
            const Divider(height: 20),
            row(Icons.account_circle_rounded, 'Pemesan', order.customerName),
            const Divider(height: 20),
            row(Icons.timer_outlined, 'Estimasi Siap', '~$prepMinutes menit'),
          ],
        ),
      ),
    );
  }

  Widget _progressCard(ThemeData theme, int prepMinutes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: Colors.deepOrange),
              const SizedBox(width: 8),
              const Text('Proses Dapur',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: _startCooking,
                child: const Text('Mulai simulasi'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progress,
            builder: (_, __) {
              final remain = (_progress.value * prepMinutes)
                  .ceil()
                  .clamp(0, prepMinutes);
              final pct = 1 - _progress.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      color: Colors.deepOrange,
                      backgroundColor: Colors.orange.shade100,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Sisa estimasi: $remain menit'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _itemsCard(OrderRecord order, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildItemChildren(order, theme),
      ),
    );
  }

  List<Widget> _buildItemChildren(OrderRecord order, ThemeData theme) {
    final children = <Widget>[];
    children
      ..add(const Text('Item Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)))
      ..add(const SizedBox(height: 8))
      ..addAll(order.items.map(_buildItemRow))
      ..add(const Divider(height: 20))
      ..add(_row('Subtotal', formatRupiah(order.subtotal)))
      ..add(order.discount > 0
          ? _styledRow(
              'Diskon',
              '- ${formatRupiah(order.discount)}',
              Colors.green.shade700,
            )
          : const SizedBox.shrink())
      ..add(order.packagingFee > 0
          ? _row('Biaya Kemasan', '+ ${formatRupiah(order.packagingFee)}')
          : const SizedBox.shrink())
      ..add(const SizedBox(height: 4))
      ..add(Row(
          children: [
            const Text('Total',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(
              formatRupiah(order.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 18,
              ),
            ),
          ]))
      ..add(const SizedBox(height: 6))
      ..add(Text(
        'Metode bayar: ${order.paymentMethod}',
        style: const TextStyle(color: Colors.black54),
      ));
    if (order.note.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Catatan: ${order.note}',
          style: const TextStyle(color: Colors.black54),
        ),
      ));
    }
    return children;
  }

  Widget _buildItemRow(CartItem it) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.network(
                it.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.fastfood,
                      size: 18, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${it.quantity}x ${it.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${it.variant}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade700)),
                if (it.toppings.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('+ ${it.toppings.join(", ")}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade700)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(formatRupiah(it.totalPrice),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  Widget _styledRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color)),
          const Spacer(),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                kantinSnack(context, 'Struk disalin ke clipboard.'),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: theme.colorScheme.primary),
              foregroundColor: theme.colorScheme.primary,
            ),
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Salin Struk'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Selesai'),
          ),
        ),
      ],
    );
  }
}
