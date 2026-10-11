import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../widgets/categories.dart';
import '../widgets/common_widgets.dart';

enum SortKey { popular, priceLow, priceHigh, rating }

extension on SortKey {
  String get label => switch (this) {
        SortKey.popular => 'Paling Populer',
        SortKey.priceLow => 'Harga Termurah',
        SortKey.priceHigh => 'Harga Tertinggi',
        SortKey.rating => 'Rating Tertinggi',
      };
}

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';
  String _category = 'all';
  SortKey _sort = SortKey.popular;

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  List<MenuItem> get _items {
    Iterable<MenuItem> list = sampleMenuItems;
    if (_category != 'all') {
      list = list.where((m) => m.category == _category);
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((m) =>
          m.name.toLowerCase().contains(q) ||
          m.description.toLowerCase().contains(q));
    }
    final arr = list.toList();
    switch (_sort) {
      case SortKey.popular:
        arr.sort((a, b) => (b.isPopular ? 1 : 0).compareTo(a.isPopular ? 1 : 0));
        break;
      case SortKey.priceLow:
        arr.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortKey.priceHigh:
        arr.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortKey.rating:
        arr.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return arr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Daftar Menu',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<SortKey>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort_rounded),
            onSelected: (k) => setState(() => _sort = k),
            itemBuilder: (_) => SortKey.values
                .map((k) => PopupMenuItem(
                      value: k,
                      child: Row(
                        children: [
                          Icon(
                            _sort == k ? Icons.check : Icons.sort,
                            size: 18,
                            color: _sort == k
                                ? theme.colorScheme.primary
                                : Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(k.label),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari di daftar menu...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtl.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: kCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = kCategories[i];
                return CategoryPill(
                  label: c.label,
                  icon: c.icon,
                  selected: _category == c.slug,
                  onTap: () => setState(() => _category = c.slug),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_items.length} menu ditemukan',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 14, color: Colors.brown),
                      const SizedBox(width: 4),
                      Text(_sort.label,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.brown)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _items.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 600));
                      setState(() {});
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          kantinSnack(context, 'Daftar menu diperbarui'),
                        );
                      }
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _MenuRow(item: _items[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: CartScope.of(context),
        builder: (context, _) {
          final cart = CartScope.of(context);
          if (cart.totalQuantity == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_rounded),
            label: Text('${cart.totalQuantity} item • ${formatRupiah(cart.total())}'),
          );
        },
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final MenuItem item;
  const _MenuRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/detail', arguments: item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.name,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        if (item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('🔥 Populer',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.deepOrange)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12, height: 1.3)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingChip(
                          rating: item.rating,
                          reviewCount: item.reviewCount,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.timer_outlined,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 2),
                        Text('${item.prepTimeMinutes} mnt',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        const Spacer(),
                        Text(formatRupiah(item.price),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('Tidak ada menu yang cocok',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              'Coba ubah kata kunci pencarian atau pilih kategori lain.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
