import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/bet_database.dart';
import '../services/wallet_database.dart';
import '../models/match.dart';

class MatchDatabase {
  final database = Supabase.instance.client.from('matches');
  final bets = BetDatabase();
  final wallet = WalletDatabase();

  // live list for the customer page
  Stream<List<Match>> get stream => database.stream(primaryKey: ['id']).map((data) => data.map((m) => Match.fromMap(m)).toList());

  // one-time fetch for the admin page
  Future<List<Match>> allMatches() async => (await database.select().order('id')).map((m) => Match.fromMap(m)).toList();

  Future createMatch(Match m) async => await database.insert(m.toMap());
  Future updateMatch(Match m) async => await database.update(m.toMap()).eq('id', m.id!);
  Future deleteMatch(Match m) async => await database.delete().eq('id', m.id!);

  Future settleMatch(Match m, String result) async {
    final winner = result == 'home' ? m.home : result == 'away' ? m.away : draw;
    for (final b in await bets.openBetsOn(m.id!)) {
      final won = b.teamPicked == winner;
      if (won) await wallet.adjust(b.email, b.payout);
      await bets.settle(b, won);
    }
    await database.update({'result': result, 'date_ended': DateTime.now().toUtc().toIso8601String()}).eq('id', m.id!);
  }
}


