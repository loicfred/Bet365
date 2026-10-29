import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/match.dart';
import '../../models/bet.dart';
import '../../models/wallet.dart';
import '../../services/match_database.dart';
import '../../services/bet_database.dart';
import '../../services/wallet_database.dart';
import '../../services/auth_service.dart';
import '../../widgets/widgets.dart';
import '../admin/admin_page.dart';
import 'bets_page.dart';
import '../auth/login_page.dart';
import 'home_panel.dart';
import 'matches_panel.dart';
import 'stats_panel.dart';

class CustomerPage extends StatefulWidget {
  final String email;
  const CustomerPage({required this.email, super.key});
  @override
  State<CustomerPage> createState() => _CustomerPageState();
}
class _CustomerPageState extends State<CustomerPage> {
  final db = MatchDatabase();
  final betDb = BetDatabase();
  final walletDb = WalletDatabase();
  final auth = AuthService();
  List<Match> matches = [];
  List<Bet> bets = [];
  Wallet? wallet;
  int tab = 0;
  bool loaded = false;

  final Set<dynamic> notified = {};
  Set<dynamic> betMatchIds = {};
  bool firstBets = true;
  StreamSubscription? sub;
  Timer? ticker;

  bool get isAdmin => auth.currentEmail() == const String.fromEnvironment('ADMIN_EMAIL');
  double get balance => wallet?.balance ?? 0;

  @override
  void initState() {
    super.initState();
    loadWallet();
    sub = db.stream.listen((data) {
      if (mounted) setState(() { matches = data; loaded = true; });
      checkBets();
    });
    ticker = Timer.periodic(const Duration(seconds: 30), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { sub?.cancel(); ticker?.cancel(); super.dispose(); }

  void loadWallet() async {
    final w = await walletDb.walletFor(widget.email);
    if (mounted) setState(() => wallet = w);
  }

  // notify the customer when one of their bets has just been settled
  void checkBets() async {
    final fetched = await betDb.betsFor(widget.email);
    final ids = <dynamic>{};
    for (final b in fetched) {
      if (b.matchId != null) ids.add(b.matchId);
      if (b.settled && !notified.contains(b.id)) {
        notified.add(b.id);
        if (!firstBets && mounted) {
          popup(context, b.won ? 'You WON Rs ${b.payout} on ${b.teamPicked}!' : 'You lost your bet on ${b.teamPicked}.');
        }
      }
    }
    firstBets = false;
    if (mounted) setState(() { betMatchIds = ids; bets = fetched; });
    loadWallet();
  }

  void logout() async {
    await auth.signOut();
    if (mounted) goReplace(context, const LoginPage());
  }

  void betDialog(Match m, String team, double odds) {
    if (!m.canBet) { popup(context, 'Betting is closed for this match'); return; }
    final stake = TextEditingController();
    showCupertinoDialog(context: context, builder: (_) => CupertinoAlertDialog(
      title: Text('Bet on $team'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [const SizedBox(height: 12), field(stake, 'enter stake (Rs)')]),
      actions: [
        CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
        CupertinoDialogAction(child: const Text('Place'), onPressed: () async {
          final amt = double.tryParse(stake.text) ?? 0;
          if (wallet == null || !wallet!.canAfford(amt)) {
            Navigator.pop(context);
            popup(context, 'Invalid stake or insufficient balance');
            return;
          }
          await walletDb.adjust(widget.email, -amt);
          await betDb.placeBet(Bet(email: widget.email, matchId: m.id, match: '${m.home} vs ${m.away}', teamPicked: team, stake: amt, payout: m.payout(amt, team), dateBetted: DateTime.now().toUtc().toIso8601String()));
          if (context.mounted) Navigator.pop(context);
          setState(() => betMatchIds.add(m.id));
          loadWallet();
        }),
      ],
    ));
  }

  bool alreadyBet(Match m) => betMatchIds.contains(m.id);

  @override
  Widget build(BuildContext context) {
    final titles = ['Bet365', 'Live Matches', 'Statistics'];
    final pages = [
      HomePanel(matches: matches, onBet: betDialog, alreadyBet: alreadyBet),
      MatchesPanel(matches: matches, onBet: betDialog, alreadyBet: alreadyBet),
      StatsPanel(bets: bets, balance: balance),
    ];
    return MyScaffold(text: titles[tab],
      action: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Rs ${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        if (isAdmin) IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: () => go(context, const AdminPage())),
        IconButton(icon: const Icon(CupertinoIcons.money_dollar_circle), onPressed: () async { await go(context, BetsPage(email: widget.email)); loadWallet(); }),
        IconButton(icon: const Icon(Icons.logout), onPressed: logout),
      ]),
      bottom: BottomNavigationBar(
        currentIndex: tab, onTap: (i) => setState(() => tab = i),
        backgroundColor: Colors.green[900], selectedItemColor: Colors.yellow[700], unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
      body: !loaded && tab != 2 ? const Center(child: CupertinoActivityIndicator()) : pages[tab],
    );
  }
}