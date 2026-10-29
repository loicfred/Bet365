import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bet.dart';

class BetDatabase {
  final database = Supabase.instance.client.from('bets');

  Future placeBet(Bet b) async => await database.insert(b.toMap());
  Future settle(Bet b, bool won) async => await database.update({'settled': true, 'won': won}).eq('id', b.id!);

  Future<List<Bet>> betsFor(String email) async => (await database.select().eq('email', email)).map((m) => Bet.fromMap(m)).toList();
  Future<List<Bet>> openBetsOn(int matchId) async => (await database.select().eq('match_id', matchId).eq('settled', false)).map((m) => Bet.fromMap(m)).toList();
}


