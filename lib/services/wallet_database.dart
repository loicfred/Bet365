import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet.dart';

class WalletDatabase {
  final database = Supabase.instance.client.from('wallets');

  Future<Wallet> walletFor(String email) async {
    final rows = await database.select().eq('email', email);
    if (rows.isNotEmpty) return Wallet.fromMap(rows.first);
    final w = Wallet(email: email, balance: 1000);
    await database.insert(w.toMap());
    return w;
  }

  Future adjust(String email, double delta) async {
    final w = await walletFor(email);
    await database.update({'balance': w.balance + delta}).eq('email', email);
  }
}

