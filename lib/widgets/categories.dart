import 'package:flutter/material.dart';

import '../models/menu_item.dart';

/// Struktur kategori yang ditampilkan di aplikasi.
/// Setiap kategori punya label, ikon, dan slug yang cocok dengan [MenuItem.category].
class CategoryDef {
  final String slug;
  final String label;
  final IconData icon;
  const CategoryDef({required this.slug, required this.label, required this.icon});
}

const List<CategoryDef> kCategories = [
  CategoryDef(slug: 'all', label: 'Semua', icon: Icons.apps_rounded),
  CategoryDef(slug: 'Makanan', label: 'Makanan', icon: Icons.ramen_dining),
  CategoryDef(slug: 'Cemilan', label: 'Cemilan', icon: Icons.fastfood),
  CategoryDef(slug: 'Minuman', label: 'Minuman', icon: Icons.local_drink),
  CategoryDef(slug: 'Paket Hemat', label: 'Paket Hemat', icon: Icons.local_offer),
];

CategoryDef categoryFor(String slug) {
  return kCategories.firstWhere(
    (c) => c.slug.toLowerCase() == slug.toLowerCase(),
    orElse: () => kCategories.first,
  );
}

/// Daftar promo untuk carousel di halaman beranda.
final List<Map<String, dynamic>> kPromos = [
  {
    'title': 'Diskon 10% Pakai Kode KANTIN10',
    'subtitle': 'Berlaku untuk semua menu sampai akhir bulan ini.',
    'icon': Icons.local_offer_rounded,
    'gradient': [Colors.deepOrange, Colors.orangeAccent],
  },
  {
    'title': 'Paket Kenyang Hemat Mulai Rp 19.000',
    'subtitle': 'Ayam geprek + nasi + es teh jumbo, cocok buat mahasiswa.',
    'icon': Icons.set_meal_rounded,
    'gradient': [Colors.pink.shade400, Colors.deepOrange.shade300],
  },
  {
    'title': 'Buka Setiap Hari 07.00 - 21.00',
    'subtitle': 'Lokasi kantin kampus, dekat gedung B. Pesan & ambil.',
    'icon': Icons.access_time_filled_rounded,
    'gradient': [Colors.indigo, Colors.purpleAccent],
  },
];
