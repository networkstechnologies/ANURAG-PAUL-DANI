import 'package:flutter/material.dart';
import '../theme.dart';
import '../api/ak_service.dart';
import '../models/models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _service = AkService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() => Future.wait([
        _service.profitAndLoss(),
        _service.outstanding('receivable'),
        _service.outstanding('payable'),
      ]);

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('${snap.error}', style: const TextStyle(color: AkTheme.danger)))]);
          }
          final pl = snap.data![0] as Map<String, dynamic>;
          final recv = snap.data![1] as List<OutstandingRow>;
          final pay = snap.data![2] as List<OutstandingRow>;
          final isProfit = pl['is_profit'] == true;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card('Profit & Loss', [
                _kv('Income', '₹${pl['total_income']}'),
                _kv('Expense', '₹${pl['total_expense']}'),
                if ('${pl['closing_stock']}' != '0.00' && pl['closing_stock'] != null)
                  _kv('Closing Stock', '₹${pl['closing_stock']}'),
                const Divider(),
                _kv(isProfit ? 'Net Profit' : 'Net Loss', '₹${pl['net_profit']}',
                    color: isProfit ? AkTheme.green : AkTheme.danger, bold: true),
              ]),
              const SizedBox(height: 14),
              _outstandingCard('Receivable (owed to you)', recv, AkTheme.goldDark),
              const SizedBox(height: 14),
              _outstandingCard('Payable (you owe)', pay, AkTheme.danger),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String title, List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: AkTheme.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );

  Widget _outstandingCard(String title, List<OutstandingRow> rows, Color color) {
    final total = rows.fold<double>(0, (s, r) => s + (double.tryParse(r.amount) ?? 0));
    return _card(title, [
      if (rows.isEmpty) const Text('Nothing outstanding.', style: TextStyle(color: AkTheme.muted)),
      ...rows.take(8).map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(r.party, overflow: TextOverflow.ellipsis)),
                Text('₹${r.amount}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          )),
      if (rows.isNotEmpty) ...[
        const Divider(),
        _kv('Total', '₹${total.toStringAsFixed(2)}', color: color, bold: true),
      ],
    ]);
  }

  Widget _kv(String k, String v, {Color? color, bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
            Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color)),
          ],
        ),
      );
}
