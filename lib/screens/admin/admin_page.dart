import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/match.dart';
import '../../services/match_database.dart';
import '../../services/auth_service.dart';
import '../../widgets/widgets.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}
class _AdminPageState extends State<AdminPage> {
  final db = MatchDatabase();
  final auth = AuthService();
  final home = TextEditingController(), away = TextEditingController(), homeOdds = TextEditingController(), awayOdds = TextEditingController(), drawOdds = TextEditingController();
  List<Match> matches = [];
  bool unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => askPassword());
  }

  void load() async {
    final ms = await db.allMatches();
    if (mounted) setState(() => matches = ms);
  }

  void askPassword() {
    final pass = TextEditingController();
    String? error;
    showCupertinoDialog(context: context, barrierDismissible: false, builder: (_) => StatefulBuilder(
      builder: (context, setLocal) => CupertinoAlertDialog(
        title: const Text('Admin Access'),
        content: Column(children: [
          const SizedBox(height: 12),
          field(pass, 'Confirm your password', hide: true),
          if (error != null) Text(error!, style: const TextStyle(color: CupertinoColors.destructiveRed)),
        ]),
        actions: [
          CupertinoDialogAction(child: const Text('Cancel'), onPressed: () { Navigator.pop(context); Navigator.pop(context); }),
          CupertinoDialogAction(child: const Text('Enter'), onPressed: () async {
            try {
              await auth.signIn(auth.currentEmail()!, pass.text);
              if (context.mounted) { Navigator.pop(context); setState(() => unlocked = true); load(); }
            } catch (e) {
              setLocal(() => error = 'Wrong password');
            }
          }),
        ],
      ),
    ));
  }

  void pickSport(Function(String) onPick) => showCupertinoModalPopup(context: context, builder: (_) => CupertinoActionSheet(
    title: const Text('Select Sport'),
    actions: [for (var s in sports) CupertinoActionSheetAction(child: Text(s), onPressed: () { onPick(s); Navigator.pop(context); })],
  ));

  void pickTime(Function(DateTime) onPick) => showCupertinoModalPopup(context: context, builder: (_) => Container(
    height: 250, color: CupertinoColors.white,
    child: CupertinoDatePicker(initialDateTime: DateTime.now().add(const Duration(hours: 1)), onDateTimeChanged: onPick),
  ));

  void matchDialog({Match? m}) {
    var sport = m?.sport ?? sports.first;
    var close = m?.closeTime ?? DateTime.now().add(const Duration(hours: 1));
    var allowDraw = m?.hasDraw ?? false;
    if (m != null) { home.text = m.home; away.text = m.away; homeOdds.text = m.homeOdds.toString(); awayOdds.text = m.awayOdds.toString(); drawOdds.text = m.drawOdds?.toString() ?? ''; }
    else { for (var c in [home, away, homeOdds, awayOdds, drawOdds]) { c.clear(); } }
    showCupertinoDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (context, setLocal) => CupertinoAlertDialog(
        title: Text(m == null ? 'Create New Match' : 'Update Match'),
        content: Column(children: [
          const SizedBox(height: 12),
          field(home, 'Enter home team'), field(away, 'Enter away team'),
          field(homeOdds, 'Enter home odds'), field(awayOdds, 'Enter away odds'),
          toggleField('Allow draw', allowDraw, (v) => setLocal(() => allowDraw = v)),
          const SizedBox(height: 12),
          if (allowDraw) field(drawOdds, 'Enter draw odds'),
          pickerField('Sport: $sport', () => pickSport((s) => setLocal(() => sport = s)), Icons.arrow_drop_down),
          const SizedBox(height: 12),
          pickerField('Closes: ${fmtDate(close.toIso8601String())}', () => pickTime((d) => setLocal(() => close = d)), Icons.calendar_today),
        ]),
        actions: [
          CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(child: const Text('Save'), onPressed: () async {
            final match = Match(id: m?.id, home: home.text, away: away.text, sport: sport, homeOdds: double.tryParse(homeOdds.text) ?? 0, awayOdds: double.tryParse(awayOdds.text) ?? 0, drawOdds: allowDraw ? double.tryParse(drawOdds.text) ?? 0 : null, voteCloseTime: close.toUtc().toIso8601String());
            Navigator.pop(context);
            m == null ? await db.createMatch(match) : await db.updateMatch(match);
            load();
          }),
        ],
      ),
    ));
  }

  void resultDialog(Match m) {
    void settle(String r) async { Navigator.pop(context); await db.settleMatch(m, r); load(); }
    showCupertinoDialog(context: context, builder: (_) => CupertinoAlertDialog(
      title: Text('Winner of ${m.home} vs ${m.away}'),
      actions: [
        CupertinoDialogAction(child: Text(m.home), onPressed: () => settle('home')),
        if (m.hasDraw) CupertinoDialogAction(child: const Text(draw), onPressed: () => settle('draw')),
        CupertinoDialogAction(child: Text(m.away), onPressed: () => settle('away')),
        CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!unlocked) return const MyScaffold(text: 'Admin Access', body: Center(child: CupertinoActivityIndicator()));
    return MyScaffold(text: 'Matches in Play', barColor: Color.fromARGB(255, 60, 0, 0), bgColor: Color.fromARGB(255, 100, 0, 0), action: IconButton(icon: const Icon(Icons.add), onPressed: () => matchDialog()),
      body: ListView(children: [
        for (var m in matches) MatchTile(m, trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (!m.ended) IconButton(icon: const Icon(Icons.emoji_events), onPressed: () => resultDialog(m)),
          IconButton(icon: const Icon(Icons.edit), onPressed: () => matchDialog(m: m)),
          IconButton(icon: const Icon(Icons.delete), onPressed: () async { await db.deleteMatch(m); load(); }),
        ])),
      ]),
    );
  }
}
