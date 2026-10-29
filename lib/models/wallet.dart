class Wallet {
  String email;
  double balance;
  Wallet({required this.email, required this.balance});

  factory Wallet.fromMap(Map<String, dynamic> m) => Wallet(email: m['email'], balance: (m['balance'] as num).toDouble());

  Map<String, dynamic> toMap() => {'email': email, 'balance': balance};

  // ---- checks ----
  bool canAfford(double stake) => stake > 0 && stake <= balance;
}


