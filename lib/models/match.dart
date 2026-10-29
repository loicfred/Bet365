const sports = ['Football', 'Cricket', 'Tennis', 'Basketball', 'Rugby', 'Baseball', 'Ping Pong', 'Nascar', 'Natation', 'Equitation', 'Horse Race'];
const draw = 'Draw';

class Match {
  int? id;
  String home, away, sport;
  double homeOdds, awayOdds; double? drawOdds;
  String? result, createdAt, dateEnded, voteCloseTime;
  Match({this.id, required this.home, required this.away, this.sport = 'Football', required this.homeOdds, required this.awayOdds, this.drawOdds, this.result, this.createdAt, this.dateEnded, this.voteCloseTime});

  factory Match.fromMap(Map<String, dynamic> m) => Match(id: m['id'], home: m['home'], away: m['away'], sport: m['sport'] ?? 'Football', homeOdds: (m['home_odds'] as num).toDouble(), awayOdds: (m['away_odds'] as num).toDouble(), drawOdds: (m['draw_odds'] as num?)?.toDouble(), result: m['result'], createdAt: m['created_at'], dateEnded: m['date_ended'], voteCloseTime: m['vote_close_time']);
  Map<String, dynamic> toMap() => {'home': home, 'away': away, 'sport': sport, 'home_odds': homeOdds, 'away_odds': awayOdds, 'draw_odds': drawOdds, 'vote_close_time': voteCloseTime};

  // checks
  DateTime? get closeTime => voteCloseTime == null ? null : DateTime.tryParse(voteCloseTime!)?.toLocal();
  bool get ended => result != null;
  bool get closed => closeTime != null && DateTime.now().isAfter(closeTime!);
  bool get canBet => !ended && !closed;
  bool get hasDraw => drawOdds != null;

  // calculations
  String? get winner => !ended ? null : result == 'home' ? home : result == 'away' ? away : draw;
  double oddsFor(String team) => team == home ? homeOdds : team == away ? awayOdds : drawOdds ?? 0;
  double payout(double stake, String team) => stake * oddsFor(team);

  // display
  String get label => '[$sport]  $home vs $away';
  String get oddsLine => hasDraw ? '$home: $homeOdds   $draw: $drawOdds   $away: $awayOdds' : '$home: $homeOdds   $away: $awayOdds';
  bool hasTeam(String q) => home.toLowerCase().contains(q.toLowerCase()) || away.toLowerCase().contains(q.toLowerCase());
  bool closesOn(DateTime d) => closeTime != null && closeTime!.year == d.year && closeTime!.month == d.month && closeTime!.day == d.day;
}

