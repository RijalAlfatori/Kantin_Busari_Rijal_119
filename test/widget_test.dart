import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app1/main.dart';

void main() {
  testWidgets('Beranda Kantin Bu Sari menampilkan sapaan',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KantinBuSariApp());
    await tester.pumpAndSettle();

    // Memastikan teks sapaan pada header beranda muncul.
    expect(find.text('Mau makan apa hari ini?'), findsOneWidget);
    // Kategori "Semua" tampil secara default di filter.
    expect(find.text('Semua'), findsWidgets);
  });
}
