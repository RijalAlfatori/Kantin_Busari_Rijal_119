import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../widgets/common_widgets.dart';

/// Halaman detail menu. Menerima [MenuItem] lewat [arguments].
class MenuDetailPage extends StatefulWidget {
  const MenuDetailPage({super.key});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  late MenuItem _menu;
  int _quantity = 1;
  int _variantIndex = 0;
  final Set<int> _selectedToppings = {};
  final TextEditingController _noteCtl = TextEditingController();
  bool _favorite = false;
  double? _scrollOffset;

  @override
  void initState() {
    super.initState();
    // Default: item pertama dikenal dari argumen oleh [didChangeDependencies].
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is MenuItem) {
      _menu = args;
    } else {
      _menu = sampleMenuItems.first;
    }
  }

  @override
  void dispose() {
    _noteCtl.dispose();
    super.dispose();
  }

  int get _unitPrice {
    int p = _menu.price;
    for (final i in _selectedToppings) {
      p += _menu.availableToppings[i].price;
    }
    return p;
  }

  int get _totalPrice => _unitPrice * _quantity;

  void _addToCart() {
    final cart = CartScope.read(context);
    final variant = _menu.availableVariants.isEmpty
        ? 'Default'
        : _menu.availableVariants[_variantIndex];
    final toppings = _selectedToppings
        .map((i) => _menu.availableToppings[i].name)
        .toList(growable: false);

    cart.addItem(
      CartItem(
        id: '${_menu.id}-${DateTime.now().microsecondsSinceEpoch}',
        menuId: _menu.id,
        name: _menu.name,
        imageUrl: _menu.imageUrl,
        unitPrice: _unitPrice,
        quantity: _quantity,
        variant: variant,
        toppings: toppings,
        note: _noteCtl.text.trim(),
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      kantinSnack(context,
          '$_quantity × ${_menu.name} ditambahkan ke keranjang.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            expandedHeight: 280,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Favorit',
                onPressed: () => setState(() => _favorite = !_favorite),
                icon: Icon(
                  _favorite ? Icons.favorite : Icons.favorite_border,
                  color: _favorite ? Colors.red : Colors.black,
                ),
              ),
              IconButton(
                tooltip: 'Bagikan',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Bagikan Menu'),
                      content: Text('Bagikan "${_menu.name}" ke teman kamu.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _menu.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.restaurant, size: 80),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _menu.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 6),
                              ],
                            ),
                          ),
                        ),
                        RatingChip(
                          rating: _menu.rating,
                          reviewCount: _menu.reviewCount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Detail body
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${_menu.prepTimeMinutes} menit',
                        style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(width: 14),
                    Icon(Icons.local_fire_department,
                        size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text('${_menu.reviewCount}+ ulasan',
                        style: TextStyle(color: Colors.grey.shade700)),
                    const Spacer(),
                    Text(
                      formatRupiah(_menu.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Tentang Menu',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  _menu.description,
                  style: const TextStyle(
                      color: Colors.black87, height: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 20),
                if (_menu.availableVariants.isNotEmpty) ...[
                  const Text('Pilih Varian',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_menu.availableVariants.length, (i) {
                      final v = _menu.availableVariants[i];
                      return ChoiceChip(
                        label: Text(v),
                        selected: _variantIndex == i,
                        onSelected: (_) => setState(() => _variantIndex = i),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                ],
                if (_menu.availableToppings.isNotEmpty) ...[
                  const Text('Tambahan Topping',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Pilih topping favoritmu (opsional).',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  const SizedBox(height: 6),
                  ...List.generate(_menu.availableToppings.length, (i) {
                    final t = _menu.availableToppings[i];
                    final selected = _selectedToppings.contains(i);
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      value: selected,
                      onChanged: (_) {
                        setState(() {
                          if (selected) {
                            _selectedToppings.remove(i);
                          } else {
                            _selectedToppings.add(i);
                          }
                        });
                      },
                      title: Text(t.name),
                      subtitle: Text(
                        t.price == 0 ? 'Gratis' : '+ ${formatRupiah(t.price)}',
                        style: TextStyle(
                          color: t.price == 0
                              ? Colors.green.shade700
                              : Colors.black54,
                        ),
                      ),
                      activeColor: theme.colorScheme.primary,
                    );
                  }),
                  const SizedBox(height: 12),
                ],
                const Text('Catatan untuk Bu Sari',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                TextField(
                  controller: _noteCtl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Contoh: kurang garam, sambal dipisah...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Jumlah',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    _QtyStepper(
                      value: _quantity,
                      onChanged: (q) => setState(() => _quantity = q),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -2),
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
                  const Text('Total Harga',
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text(
                    formatRupiah(_totalPrice),
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
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Tambah ke Keranjang',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _addToCart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QtyStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
            color: theme.colorScheme.primary,
            disabledColor: Colors.grey,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: value < 99 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
            color: theme.colorScheme.primary,
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
