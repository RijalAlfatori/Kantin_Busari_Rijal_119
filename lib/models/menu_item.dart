import 'package:flutter/material.dart';

class MenuItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final double rating;
  final int reviewCount;
  final String description;
  final String imageUrl;
  final int prepTimeMinutes;
  final bool isPopular;
  final List<String> availableVariants;
  final List<ToppingOption> availableToppings;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.imageUrl,
    required this.prepTimeMinutes,
    this.isPopular = false,
    this.availableVariants = const [],
    this.availableToppings = const [],
  });
}

class ToppingOption {
  final String name;
  final int price;

  const ToppingOption({
    required this.name,
    required this.price,
  });
}

// Helper untuk format rupiah yang rapi
String formatRupiah(int price) {
  final str = price.toString();
  final buffer = StringBuffer();
  final len = str.length;

  for (int i = 0; i < len; i++) {
    buffer.write(str[i]);
    final remaining = len - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
  }

  return 'Rp ${buffer.toString()}';
}

// Data katalog menu autentik Kantin Bu Sari
final List<MenuItem> sampleMenuItems = [
  const MenuItem(
    id: 'm1',
    name: 'Nasi Goreng Spesial Bu Sari',
    category: 'Makanan',
    price: 18000,
    rating: 4.9,
    reviewCount: 142,
    description:
        'Nasi goreng resep legendaris Bu Sari dengan bumbu rempah pilihan, potongan ayam suwir gurih, bakso sapi, dan acar segar.',
    imageUrl:
        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 10,
    isPopular: true,
    availableVariants: [
      'Level 0 (Tidak Pedas)',
      'Level 1 (Sedang)',
      'Level 2 (Pedas Mantap)',
      'Level 3 (Super Pedas 🔥)'
    ],
    availableToppings: [
      ToppingOption(name: 'Telur Mata Sapi / Dadar', price: 4000),
      ToppingOption(name: 'Sosis Sapi Panggang', price: 3000),
      ToppingOption(name: 'Ekstra Kerupuk Udang', price: 2000),
      ToppingOption(name: 'Keju Mozzarella Leleh', price: 5000),
    ],
  ),
  const MenuItem(
    id: 'm2',
    name: 'Ayam Geprek Sambal Bawang',
    category: 'Makanan',
    price: 16000,
    rating: 4.8,
    reviewCount: 198,
    description:
        'Ayam krispi renyah di luar juicy di dalam, digeprek dadakan dengan sambal bawang segar minyak panas yang harum menggugah selera. Sudah termasuk nasi putih pulen.',
    imageUrl:
        'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 12,
    isPopular: true,
    availableVariants: [
      'Level 1 (Cabe 3)',
      'Level 2 (Cabe 7)',
      'Level 3 (Cabe 12 🔥)',
      'Level 5 (Cabe 20 🔥🔥)'
    ],
    availableToppings: [
      ToppingOption(name: 'Keju Parut Melimpah', price: 3500),
      ToppingOption(name: 'Tahu & Tempe Goreng', price: 3000),
      ToppingOption(name: 'Terong Crispy', price: 3000),
      ToppingOption(name: 'Ekstra Nasi Putih', price: 4000),
    ],
  ),
  const MenuItem(
    id: 'm3',
    name: 'Mie Nyemek Telur Pedas',
    category: 'Makanan',
    price: 14000,
    rating: 4.7,
    reviewCount: 95,
    description:
        'Mie rebus berkuah kental gurih khas masakan rumahan Bu Sari, dipadukan dengan kocokan telur, sawi hijau segar, tomat, dan taburan bawang goreng.',
    imageUrl:
        'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 8,
    isPopular: false,
    availableVariants: [
      'Manis Gurih (Tidak Pedas)',
      'Sedang Pedas Gurih',
      'Pedas Nyemek Nampol'
    ],
    availableToppings: [
      ToppingOption(name: 'Bakso Sapi Iris (3 pcs)', price: 4000),
      ToppingOption(name: 'Sosis Ayam Iris', price: 3000),
      ToppingOption(name: 'Kerupuk Pangsit', price: 2000),
    ],
  ),
  const MenuItem(
    id: 'm4',
    name: 'Soto Ayam Lamongan Komplit',
    category: 'Makanan',
    price: 17000,
    rating: 4.9,
    reviewCount: 110,
    description:
        'Kuah kuning hangat berkaldu kaya rempah dengan taburan koya udang khas Bu Sari, suwiran ayam kampung lembut, soun, tauge, dan jeruk nipis.',
    imageUrl:
        'https://images.unsplash.com/photo-1541832676-9b763b0239ab?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 7,
    isPopular: true,
    availableVariants: ['Nasi Dicampur', 'Nasi Dipisah'],
    availableToppings: [
      ToppingOption(name: 'Koya Gurih Ekstra', price: 2000),
      ToppingOption(name: 'Telur Rebus Utuh', price: 4000),
      ToppingOption(name: 'Perkedel Kentang', price: 3000),
    ],
  ),
  const MenuItem(
    id: 'm5',
    name: 'Tahu Bakso Goreng Crispy (5 Pcs)',
    category: 'Cemilan',
    price: 10000,
    rating: 4.8,
    reviewCount: 88,
    description:
        'Tahu pong coklat gurih berisi adonan bakso sapi tebal padat, digoreng garing renyah disajikan dengan cabai rawit hijau dan petis manis.',
    imageUrl:
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 6,
    isPopular: false,
    availableVariants: ['Goreng Kering', 'Goreng Basah'],
    availableToppings: [
      ToppingOption(name: 'Bumbu Tabur Balado', price: 1500),
      ToppingOption(name: 'Saus Sambal Mayo', price: 2000),
    ],
  ),
  const MenuItem(
    id: 'm6',
    name: 'Pisang Goreng Karamel Keju',
    category: 'Cemilan',
    price: 12000,
    rating: 4.9,
    reviewCount: 76,
    description:
        'Pisang kepok madu pilihan dibalut tepung krispi, disiram susu kental manis, saus karamel legit, dan parutan keju cheddar melimpah.',
    imageUrl:
        'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 7,
    isPopular: true,
    availableVariants: ['Original Manis', 'Ekstra Renyah'],
    availableToppings: [
      ToppingOption(name: 'Ekstra Meses Coklat', price: 2000),
      ToppingOption(name: 'Ekstra Keju Parut', price: 3000),
    ],
  ),
  const MenuItem(
    id: 'm7',
    name: 'Es Teh Manis Melati Jumbo',
    category: 'Minuman',
    price: 4000,
    rating: 4.9,
    reviewCount: 310,
    description:
        'Teh racikan daun melati wangi khas Solo diseduh kental, disajikan segar dingin dalam gelas jumbo penyegar dahaga.',
    imageUrl:
        'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 3,
    isPopular: true,
    availableVariants: [
      'Dingin (Banyak Es)',
      'Dingin (Sedikit Es)',
      'Hangat / Panas'
    ],
    availableToppings: [
      ToppingOption(name: 'Nata de Coco', price: 2000),
      ToppingOption(name: 'Selasih Segar', price: 1500),
    ],
  ),
  const MenuItem(
    id: 'm8',
    name: 'Es Jeruk Peras Murni',
    category: 'Minuman',
    price: 7000,
    rating: 4.8,
    reviewCount: 164,
    description:
        'Perasan asli jeruk segar manis alami tanpa pemanis buatan, kaya vitamin C dan sangat menyegarkan di siang hari.',
    imageUrl:
        'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 4,
    isPopular: false,
    availableVariants: ['Dingin dengan Es', 'Hangat'],
    availableToppings: [
      ToppingOption(name: 'Gula Cair Dipisah', price: 0),
      ToppingOption(name: 'Biji Selasih', price: 1500),
    ],
  ),
  const MenuItem(
    id: 'm9',
    name: 'Paket Kenyang Hemat: Ayam + Nasi + Es Teh',
    category: 'Paket Hemat',
    price: 19000,
    rating: 5.0,
    reviewCount: 240,
    description:
        'Paket favorit andalan mahasiswa! 1 porsi Ayam Geprek Sambal Bawang + Nasi Putih Pulen + Es Teh Manis Jumbo. Praktis, hemat, dan kenyang.',
    imageUrl:
        'https://images.unsplash.com/photo-1562967914-608f82629710?w=600&auto=format&fit=crop&q=80',
    prepTimeMinutes: 10,
    isPopular: true,
    availableVariants: [
      'Level Pedas Sedang + Es Teh Jumbo',
      'Level Pedas Mantap + Es Teh Jumbo',
      'Tidak Pedas + Es Teh Jumbo'
    ],
    availableToppings: [
      ToppingOption(name: 'Tahu Goreng', price: 2000),
      ToppingOption(name: 'Telur Mata Sapi', price: 4000),
    ],
  ),
];
