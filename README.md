# Kantin Bu Sari

Aplikasi pemesanan makanan ringan ala kantin kampus, dibangun dengan **Flutter**.
Project ini berisi pemesanan menu (makanan, cemilan, minuman, paket hemat),
keranjang belanja, checkout form, sampai halaman sukses.

## Halaman

| Route        | Halaman                             | Fitur widget interaktif                                                                                |
| ------------ | ----------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `/`          | Beranda                             | Search bar, **PageView** promo auto-scroll, **ChoiceChip** kategori, **GridView** menu, FAB keranjang|
| `/menu`      | Daftar Menu                         | Search bar, filter **ChoiceChip** kategori, sortir **PopupMenuButton**, ListView, RefreshIndicator  |
| `/detail`    | Detail Menu                         | Hero image, **ChoiceChip** varian, **CheckboxListTile** topping, **Stepper** qty, **TextField** note |
| `/cart`      | Keranjang                           | ListView kartu, **Dismissible** swipe-hapus, stepper, **TextField** kode promo, ringkasan            |
| `/checkout`  | Pembayaran                          | **Form** (TextFormField), **RadioListTile** metode bayar, **Switch** cutlery, ringkasan               |
| `/success`   | Pesanan Diterima                    | Animasi **ScaleTransition**, **LinearProgressIndicator**, kartu detail pesanan                       |

## State Management

Pakai pola `InheritedNotifier` bawaan Flutter lewat `CartScope` —
tersimpan di `lib/state/cart_state.dart` (model keranjang dan notifier) dan
`lib/state/order_record.dart` (record pesanan akhir).

## Struktur Direktori

```
lib/
├── main.dart
├── models/
│   └── menu_item.dart         # model + helper format Rupiah + data menu
├── pages/
│   ├── home_page.dart
│   ├── menu_list_page.dart
│   ├── menu_detail_page.dart
│   ├── cart_page.dart
│   ├── checkout_page.dart
│   └── order_success_page.dart
├── state/
│   ├── cart_state.dart
│   └── order_record.dart
└── widgets/
    ├── categories.dart         # definisi kategori & promo
    └── common_widgets.dart      # kartu menu, chip rating, banner, FAB keranjang
```

## Menjalankan

```
flutter pub get
flutter run
```
