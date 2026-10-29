import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/match.dart';

class MyScaffold extends StatelessWidget {
  final String text;
  final Color? barColor;
  final Color? bgColor;
  final Widget body;
  final Widget? action;
  final Widget? bottom;
  const MyScaffold({required this.text, this.barColor, this.bgColor, required this.body, this.action, this.bottom, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(text), backgroundColor: barColor ?? Colors.green[900], foregroundColor: Colors.white, actions: action != null ? [action!] : null),
      backgroundColor: bgColor ?? Color(0xFF14805E),
      bottomNavigationBar: bottom,
      body: Padding(padding: const EdgeInsets.all(20), child: body),
    );
  }
}

const fieldHeight = 40.0;

BoxDecoration get fieldBox => BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black54), borderRadius: BorderRadius.circular(4));

Widget field(TextEditingController c, String hint, {bool hide = false, ValueChanged<String>? onChanged}) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: Material(
    type: MaterialType.transparency,
    child: TextField(controller: c, obscureText: hide, onChanged: onChanged, style: const TextStyle(color: Colors.black), cursorColor: Colors.black, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black54), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), border: const OutlineInputBorder())),
  ),
);

Widget yellowButton(String label, VoidCallback onTap) => ElevatedButton(
  onPressed: onTap,
  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 45)),
  child: Text(label),
);

Future go(BuildContext c, Widget page) => Navigator.push(c, CupertinoPageRoute(builder: (_) => page));

void goReplace(BuildContext c, Widget page) => Navigator.pushReplacement(c, CupertinoPageRoute(builder: (_) => page));

// runs an async action and shows the error in a popup instead of crashing
Future<bool> attempt(BuildContext c, Future Function() action, String label) async {
  try { await action(); return true; }
  catch (e) { if (c.mounted) popup(c, '$label Error: $e'); return false; }
}

void popup(BuildContext context, String message) => showCupertinoDialog(
  context: context,
  builder: (_) => CupertinoAlertDialog(
    content: Text(message),
    actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
  ),
);

Widget toggleField(String label, bool value, ValueChanged<bool> onChanged) => Container(
  height: fieldHeight,
  padding: const EdgeInsets.symmetric(horizontal: 12),
  decoration: fieldBox,
  child: Row(children: [
    Expanded(child: Text(label, style: const TextStyle(color: Colors.black))),
    CupertinoSwitch(value: value, onChanged: onChanged),
  ]),
);

Widget pickerField(String text, VoidCallback onTap, IconData icon) => GestureDetector(
  onTap: onTap,
  child: Container(
    height: fieldHeight,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: fieldBox,
    child: Row(children: [
      Expanded(child: Text(text, style: const TextStyle(color: Colors.black), overflow: TextOverflow.ellipsis)),
      Icon(icon, color: Colors.black),
    ]),
  ),
);

Widget boxField({required Widget child}) => Container(
  height: fieldHeight,
  padding: const EdgeInsets.symmetric(horizontal: 8),
  decoration: fieldBox,
  child: child,
);

String two(int n) => n.toString().padLeft(2, '0');

String fmtDate(String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
  return d == null ? '-' : '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

class LinkText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const LinkText(this.text, this.onTap, {super.key});
  @override
  State<LinkText> createState() => _LinkTextState();
}
class _LinkTextState extends State<LinkText> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(widget.text, style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, decoration: hover ? TextDecoration.underline : TextDecoration.none, decorationColor: Colors.lightBlueAccent)),
      ),
    );
  }
}

class MatchTile extends StatelessWidget {
  final Match m;
  final Widget? trailing;
  const MatchTile(this.m, {this.trailing, super.key});

  Color? get color => m.ended ? Colors.grey[350] : m.closed ? Colors.yellow[100] : null;

  Icon? get icon => m.ended ? const Icon(Icons.check_circle, color: Colors.green) : m.closed ? const Icon(Icons.hourglass_bottom, color: Colors.orange) : null;

  String get info => m.ended ? 'Winner: ${m.winner}\nEnded: ${fmtDate(m.dateEnded)}'
      : '${m.oddsLine}\nCloses: ${fmtDate(m.voteCloseTime)}${m.closed ? '  (closed)' : ''}';

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: ListTile(isThreeLine: true, leading: icon, title: Text(m.label), subtitle: Text(info), trailing: trailing),
  );
}