import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../widgets/widgets.dart';

class MatchesPanel extends StatefulWidget {
  final List<Match> matches;
  final void Function(Match, String, double) onBet;
  final bool Function(Match) alreadyBet;
  const MatchesPanel({required this.matches, required this.onBet, required this.alreadyBet, super.key});
  @override
  State<MatchesPanel> createState() => _MatchesPanelState();
}
class _MatchesPanelState extends State<MatchesPanel> {
  final search = TextEditingController();
  String query = '';
  String sport = 'All';
  DateTime? date;
  bool showCompleted = false;

  bool keep(Match m) => (query.isEmpty || m.hasTeam(query)) && (showCompleted || !m.ended) && (sport == 'All' || m.sport == sport) && (date == null || m.closesOn(date!));

  List<Match> get visible => widget.matches.where(keep).toList();

  Widget trailingFor(Match m) => m.ended ? const Text('Ended', style: TextStyle(color: Colors.grey))
      : m.closed ? const Text('Closed', style: TextStyle(color: Colors.red))
      : widget.alreadyBet(m) ? const Text('Bet placed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
      : Row(mainAxisSize: MainAxisSize.min, children: [
    betButton('Home', () => widget.onBet(m, m.home, m.homeOdds)),
    if (m.hasDraw) betButton(draw, () => widget.onBet(m, draw, m.drawOdds!)),
    betButton('Away', () => widget.onBet(m, m.away, m.awayOdds)),
  ]);

  Widget betButton(String label, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 36)),
      onPressed: onTap, child: Text(label),
    ),
  );

  void pickDate() async {
    final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (d != null) setState(() => date = d);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: TextField(
          controller: search,
          onChanged: (v) => setState(() => query = v),
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(hintText: 'Search team...', prefixIcon: Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
        )),
        const SizedBox(width: 8),
        Checkbox(value: showCompleted, onChanged: (v) => setState(() => showCompleted = v ?? false)),
        const Text('Completed', style: TextStyle(color: Colors.white)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: boxField(child: DropdownButton<String>(
          value: sport, isExpanded: true, underline: const SizedBox(),
          items: [for (var s in ['All', ...sports]) DropdownMenuItem(value: s, child: Text(s))],
          onChanged: (v) => setState(() => sport = v ?? 'All'),
        ))),
        const SizedBox(width: 8),
        Expanded(child: pickerField(date == null ? 'Any date' : fmtDate(date!.toIso8601String()).substring(0, 10), pickDate, Icons.calendar_today)),
        if (date != null) IconButton(icon: const Icon(Icons.clear, color: Colors.white), onPressed: () => setState(() => date = null)),
      ]),
      const SizedBox(width: 4),
      Expanded(child: visible.isEmpty ? const Center(child: Text('No matches', style: TextStyle(color: Colors.white))) : ListView(children: [for (var m in visible) MatchTile(m, trailing: trailingFor(m))])),
    ]);
  }
}