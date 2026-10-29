import 'package:flutter/material.dart';
import '../../models/bet.dart';

class StatsPanel extends StatelessWidget {
  final List<Bet> bets;
  final double balance;
  const StatsPanel({required this.bets, required this.balance, super.key});

  Widget row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final won = bets.where((b) => b.won).length;
    final lost = bets.where((b) => b.lost).length;
    final staked = bets.fold<double>(0, (s, b) => s + b.stake);
    final winnings = bets.where((b) => b.won).fold<double>(0, (s, b) => s + b.payout);
    final rate = (won + lost) == 0 ? 0 : won * 100 / (won + lost);
    return ListView(children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        const Text('MY STATISTICS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        const Divider(),
        row('Balance', 'Rs ${balance.toStringAsFixed(2)}'),
        row('Total bets', '${bets.length}'),
        row('Won', '$won'),
        row('Lost', '$lost'),
        row('Pending', '${bets.where((b) => b.pending).length}'),
        row('Total staked', 'Rs ${staked.toStringAsFixed(2)}'),
        row('Total winnings', 'Rs ${winnings.toStringAsFixed(2)}'),
        row('Win rate', '${rate.toStringAsFixed(1)} %'),
      ]))),
      const SizedBox(height: 16),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ABOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        Divider(),
        Text('Bet365 is a Flutter demo betting application built for the Advanced Mobile Application Development module. It is connected to a Supabase online backend which handles the authentication, the matches, the bets and the wallets in realtime.'),
        SizedBox(height: 8),
        Text('Developed by Loic Fred Cheerkoot\nID: 2403_27696 ~ BSE/24A/FT1', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 8),
        Text('This app is a demonstration only and does not involve real money.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      ]))),
    ]);
  }
}