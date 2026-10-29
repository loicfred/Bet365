import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/bet.dart';
import '../../services/bet_database.dart';
import '../../widgets/widgets.dart';

class BetsPage extends StatelessWidget {
  final String email;
  const BetsPage({required this.email, super.key});

  Widget betCard(Bet b) => Card(
    color: b.pending ? null : b.won ? Colors.green[100] : Colors.red[100],
    child: ListTile(
      isThreeLine: true,
      leading: b.pending ? const Icon(Icons.hourglass_bottom, color: Colors.orange) : Icon(b.won ? Icons.check_circle : Icons.cancel, color: b.won ? Colors.green : Colors.red),
      title: Text(b.match),
      subtitle: Text('Picked: ${b.teamPicked}\nBetted: ${fmtDate(b.dateBetted)}'),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(b.status, style: TextStyle(fontWeight: FontWeight.bold, color: b.pending ? Colors.orange : b.won ? Colors.green[800] : Colors.red[800])),
        Text('Stake Rs ${b.stake}', style: const TextStyle(fontSize: 11)),
        Text('${b.won ? '+ ' : ''}Rs ${b.payout}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MyScaffold(text: 'My Bets', body: FutureBuilder(
      future: BetDatabase().betsFor(email),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
        final bets = snapshot.data!;
        if (bets.isEmpty) return const Center(child: Text('No bets placed yet', style: TextStyle(color: Colors.white)));
        return ListView(children: [for (var b in bets) betCard(b)]);
      },
    ));
  }
}