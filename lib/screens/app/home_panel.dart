import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../models/news.dart';
import '../../services/news_service.dart';
import '../../widgets/widgets.dart';

class HomePanel extends StatefulWidget {
  final List<Match> matches;
  final void Function(Match, String, double) onBet;
  final bool Function(Match) alreadyBet;
  const HomePanel({required this.matches, required this.onBet, required this.alreadyBet, super.key});
  @override
  State<HomePanel> createState() => _HomePanelState();
}
class _HomePanelState extends State<HomePanel> {
  List<News> news = [];

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  void loadNews() async {
    final n = await NewsService().latest();
    if (mounted) setState(() => news = n);
  }

  Match? get next {
    final open = widget.matches.where((m) => m.canBet).toList()
      ..sort((a, b) => (a.closeTime ?? DateTime(2100)).compareTo(b.closeTime ?? DateTime(2100)));
    return open.isEmpty ? null : open.first;
  }

  Widget betButton(String label, VoidCallback onTap) => Expanded(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
      onPressed: onTap, child: Text(label, overflow: TextOverflow.ellipsis),
    ),
  ));

  Widget iconButton(IconData icon, String label, VoidCallback onTap) => Expanded(child: Column(children: [
    IconButton(icon: Icon(icon, color: Colors.yellow[700], size: 28), onPressed: onTap),
    Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
  ]));

  Widget newsCard(News n) => Card(child: InkWell(
    onTap: () => popup(context, '${n.title}\n\n${n.url}'),
    child: Column(children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        child: Image.network(n.image, height: 150, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 150, color: Colors.black12, child: const Icon(Icons.image, size: 40, color: Colors.black26))),
      ),
      Padding(padding: const EdgeInsets.all(12), child: Text(n.title)),
    ]),
  ));

  @override
  Widget build(BuildContext context) {
    final m = next;
    return ListView(children: [
      const Text('NEXT MATCH', style: TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      if (m == null)
        const Card(child: Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No upcoming matches'))))
      else Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        Text(m.sport, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${m.home}\nvs\n${m.away}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Closes: ${fmtDate(m.voteCloseTime)}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        widget.alreadyBet(m)
            ? const Text('Bet placed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
            : Row(children: [
          betButton('${m.home}  ${m.homeOdds}', () => widget.onBet(m, m.home, m.homeOdds)),
          if (m.hasDraw) betButton('$draw  ${m.drawOdds}', () => widget.onBet(m, draw, m.drawOdds!)),
          betButton('${m.away}  ${m.awayOdds}', () => widget.onBet(m, m.away, m.awayOdds)),
        ]),
      ]))),
      const SizedBox(height: 20),
      const Text('LATEST SPORTS NEWS', style: TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      if (news.isEmpty)
        const Card(child: SizedBox(height: 150, child: Center(child: CircularProgressIndicator())))
      else for (var n in news.take(3)) newsCard(n),
      const SizedBox(height: 12),
      Row(children: [
        iconButton(Icons.share, 'Share', () => popup(context, m == null ? 'No match to share' : 'Link copied: bet365.mu/match/${m.id}')),
        iconButton(Icons.rule, 'Rules', () => popup(context, 'One bet per match. Bets close at the stated time. Winnings are paid when the admin settles the match.')),
        iconButton(Icons.support_agent, 'Support', () => popup(context, 'Contact support at ${const String.fromEnvironment('SUPPORT_EMAIL')}')),
      ]),
    ]);
  }
}