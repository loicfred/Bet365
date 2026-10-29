class Bet {
  int? id, matchId;
  String email, match, teamPicked;
  double stake, payout;
  bool settled, won;
  String? dateBetted;
  Bet({this.id, required this.email, required this.match, this.matchId, required this.teamPicked, required this.stake, required this.payout, this.settled = false, this.won = false, this.dateBetted});

  factory Bet.fromMap(Map<String, dynamic> m) => Bet(id: m['id'], email: m['email'], match: m['match'] ?? '', matchId: m['match_id'], teamPicked: m['team_picked'] ?? '', stake: (m['stake'] as num).toDouble(), payout: (m['payout'] as num).toDouble(), settled: m['settled'] == true, won: m['won'] == true, dateBetted: m['date_betted']);

  Map<String, dynamic> toMap() => {'email': email, 'match': match, 'match_id': matchId, 'team_picked': teamPicked, 'stake': stake, 'payout': payout, 'date_betted': dateBetted};

  // checks
  bool get pending => !settled;
  bool get lost => settled && !won;
  String get status => !settled ? 'Pending' : won ? 'WON' : 'LOST';
}

