import 'dart:async';

import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../widgets/categories.dart';
import '../widgets/common_widgets.dart';

/// Halaman beranda: sapaan, cari, banner promo, kategori, dan menu populer.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _searchCtl;
  late final PageController _promoPageCtl;
  Timer? _promoTimer;
  int _promoIndex = 0;
  String _activeCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtl = TextEditingController();
    _promoPageCtl = PageController(viewportFraction: 0.92);
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_promoPageCtl.hasClients) return;
      final next = (_promoIndex + 1) % kPromos.length;
      _promoPageCtl.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _searchCtl.dispose();
    _promoPageCtl.dispose();
    super.dispose();
  }

  List<MenuItem> get _filteredMenu {
    Iterable<MenuItem> items = sampleMenuItems;
    if (_activeCategory != 'all') {
      items = items.where((m) => m.category == _activeCategory);
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((m) => m.name.toLowerCase().contains(q));
    }
    return items.toList();
  }

  List<MenuItem> get _popularMenu =>
      sampleMenuItems.where((m) => m.isPopular).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF6),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              titleSpacing: 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Halo, Pelanggan Setia 👋',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Mau makan apa hari ini?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Notifikasi',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => const _NotificationsSheet(),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Text(
                      'BS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _searchCtl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari menu favoritmu...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchCtl.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
            ),

            // Promo carousel
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 130,
                  child: PageView.builder(
                    controller: _promoPageCtl,
                    onPageChanged: (i) => setState(() => _promoIndex = i),
                    itemCount: kPromos.length,
                    itemBuilder: (_, i) {
                      final p = kPromos[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: PromoBanner(
                          title: p['title'] as String,
                          subtitle: p['subtitle'] as String,
                          icon: p['icon'] as IconData,
                          gradient: p['gradient'] as List<Color>,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Indicator dot
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(kPromos.length, (i) {
                  final active = i == _promoIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

            // Kategori
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: kCategories.length,
                    itemBuilder: (_, i) {
                      final c = kCategories[i];
                      return CategoryPill(
                        label: c.label,
                        icon: c.icon,
                        selected: _activeCategory == c.slug,
                        onTap: () => setState(() => _activeCategory = c.slug),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Menu Populer
            SliverToBoxAdapter(
              child: SectionHeader(
                title: _activeCategory == 'all'
                    ? 'Menu Populer 🔥'
                    : 'Pilihan Kategori ${categoryFor(_activeCategory).label}',
                actionLabel: 'Lihat semua',
                onActionTap: () => Navigator.pushNamed(context, '/menu'),
              ),
            ),

            // Grid menu
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.66,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final list = _filteredMenu;
                    if (list.isEmpty) return const _EmptyMenuTile();
                    final item = list[i % list.length];
                    return MenuCard(
                      menu: item,
                      onTap: () => Navigator.pushNamed(context, '/detail', arguments: item),
                      onAdd: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          kantinSnack(context, 'Buka detail ${item.name} untuk atur pesanan.'),
                        );
                      },
                    );
                  },
                  childCount:
                      _filteredMenu.isEmpty ? 1 : _filteredMenu.length,
                ),
              ),
            ),

            // Banner informasi
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.info_outline,
                            color: Colors.amber.shade900, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Info Pemesanan',
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              'Pesan & bayar di tempat kasir Bu Sari. Pembayaran QRIS, tunai, atau dompet digital.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_filteredMenu.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Center(child: Text('Menu tidak ditemukan.')),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _CartFab(),
    );
  }
}

class _EmptyMenuTile extends StatelessWidget {
  const _EmptyMenuTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Tidak ada menu yang cocok dengan pencarianmu.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CartFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartScope.of(context),
      builder: (context, _) {
        final cart = CartScope.of(context);
        if (cart.totalQuantity == 0) {
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/menu'),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Lihat Menu'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          );
        }
        return FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/cart'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_rounded),
              Positioned(
                right: -8,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${cart.totalQuantity}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: Text('Keranjang (${cart.totalQuantity})'),
        );
      },
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Notifikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _NotifTile(
              icon: Icons.local_offer,
              title: 'Promo spesial hari ini!',
              subtitle: 'Pakai kode KANTIN10 untuk diskon 10%.',
            ),
            const SizedBox(height: 8),
            _NotifTile(
              icon: Icons.timer_outlined,
              title: 'Pesananmu sedang dimasak',
              subtitle: 'Estimasi siap dalam 8 menit lagi.',
            ),
            const SizedBox(height: 8),
            _NotifTile(
              icon: Icons.star_rate_rounded,
              title: 'Beri penilaian',
              subtitle: 'Bantu kami dengan rating menu favoritmu.',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _NotifTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
