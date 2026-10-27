/// Prices differ by an order of magnitude across the stores, so (like the web
/// app) whole dollars above $100 and cents below.
String money(double n) => n >= 100 ? '\$${_group(n.round())}' : '\$${n.toStringAsFixed(2)}';

/// Totals always show cents.
String moneyExact(double n) {
  final cents = (n * 100).round();
  return '\$${_group(cents ~/ 100)}.${(cents % 100).toString().padLeft(2, '0')}';
}

String _group(int n) {
  final s = n.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "26 Oct 2026"
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "Thu, 30 Oct"
String formatDay(DateTime d) => '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

String plural(int n, String one, [String? many]) => '$n ${n == 1 ? one : many ?? '${one}s'}';
