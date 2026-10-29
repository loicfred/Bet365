# Bet365

A Flutter demo of a sports betting app, with a Supabase backend for accounts, matches, bets and wallets in real time. It uses play money only (Mauritian rupees, Rs); no real money is involved.

Built for the Advanced Mobile Application Development module, year 3.

## Screenshots
<!-- add screenshots here -->

## What it does

### Accounts
Sign up and log in with an email and password, using Supabase Auth. Each new account gets a wallet with Rs 1000 to bet with.

### Home
- **Next match**: the next match to close, with its closing time and a bet button for each side (and the draw, where there is one), each showing its odds.
- **Latest sports news**: the three newest sport stories from The Guardian, each with its picture.
- **Share, Rules and Support**: three buttons. The rules are one bet per match, bets close at the stated time, and winnings are paid when the admin settles the match.

### Matches
- A live list of matches across eleven sports, from football and cricket to horse racing. It updates in real time through a Supabase stream.
- **Filters**: search by team, filter by sport and by closing date, and show or hide completed matches.
- **Status**: each match shows whether it is open, closed, ended, or already has your bet on it.

### Placing a bet
Tap Home, Away, or Draw (where the match allows one), then enter a stake in rupees. The app checks that your wallet can cover it, takes the stake from your balance, and records the bet with its payout (stake × odds). Betting closes at the match's closing time, and you can place one bet per match.

### My bets
Every bet you have placed: the match, the team you picked, the date, your stake, the payout, and whether it is pending, won or lost.

### Stats
Your balance, total bets, wins, losses, pending bets, total staked, total winnings and win rate.

### Admin
The admin account gets an extra button. Opening it asks for the password again, then shows a management page where the admin can:
- Create, edit and delete matches: the sport, both teams, the odds (with an optional draw), and the closing time.
- **Settle a match** by choosing the winner (home, away or draw). Every open bet on that match is marked won or lost, and winners have their payout added to their wallet.

## Built with
- Flutter and Dart, with Material and Cupertino widgets
- [Supabase](https://supabase.com) (`supabase_flutter`) for authentication, the database and real-time updates
- The [Guardian Open Platform API](https://open-platform.theguardian.com) (`http`) for sports news

## Project layout
```
lib/
  main.dart              starts Supabase and opens the login page
  models/                Bet, Match (with the sports and the odds maths), News, Wallet
  services/              AuthService and the bets, matches and wallets tables, plus NewsService
  screens/auth/          login and registration
  screens/app/           the customer page with its Home, Matches and Stats panels, and My bets
  screens/admin/         match management and settling
  widgets/widgets.dart   shared widgets
```

## Backend setup
The app expects three Supabase tables:

| Table | Columns |
|---|---|
| `matches` | `id`, `home`, `away`, `sport`, `home_odds`, `away_odds`, `draw_odds` (nullable), `result` (`home`, `away` or `draw`), `created_at`, `date_ended`, `vote_close_time` |
| `bets` | `id`, `email`, `match`, `match_id`, `team_picked`, `stake`, `payout`, `settled`, `won`, `date_betted` |
| `wallets` | `email`, `balance` |

Turn on Realtime for `matches`, and Row Level Security on all three tables.

## Settings
Keys and accounts are kept out of the code, in an `env.json` file that git ignores:

1. Copy `env.example.json` to `env.json`.
2. Fill it in:

| Key | What it is |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Its anon (public) key |
| `GUARDIAN_API_KEY` | A free key from the [Guardian Open Platform](https://open-platform.theguardian.com/access/) |
| `ADMIN_EMAIL` | The account that gets the admin page |
| `SUPPORT_EMAIL` | The address shown under Support |

## Run it
```
flutter pub get
flutter run --dart-define-from-file=env.json
```
In Android Studio or IntelliJ, put `--dart-define-from-file=env.json` under *Additional run args* in the run configuration. Without it, the app stops at start-up with a message saying the settings are missing.
