import 'package:flutter/material.dart';
import '../theme.dart';
import '../api/ak_service.dart';
import '../models/models.dart';
import 'voucher_detail_screen.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});
  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  final _service = AkService();
  late Future<List<VoucherRow>> _future;
  String? _type;

  static const _typeLabels = {
    'sale': 'Sale', 'purchase': 'Purchase', 'receipt': 'Receipt',
    'payment': 'Payment', 'sale_return': 'Credit Note', 'purchase_return': 'Debit Note',
    'journal': 'Journal',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = _service.vouchers(type: _type);

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _chip('All', null),
              _chip('Sales', 'sale'),
              _chip('Purchases', 'purchase'),
              _chip('Receipts', 'receipt'),
              _chip('Payments', 'payment'),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<VoucherRow>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _msg('Could not load: ${snap.error}');
                }
                final rows = snap.data ?? [];
                if (rows.isEmpty) return _msg('No vouchers yet. Tap “New Invoice”.');
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _row(rows[i]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String? type) {
    final selected = _type == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AkTheme.teal600,
        labelStyle: TextStyle(
            color: selected ? Colors.white : AkTheme.navy,
            fontWeight: FontWeight.w600, fontSize: 13),
        backgroundColor: Colors.white,
        onSelected: (_) => setState(() {
          _type = type;
          _load();
        }),
      ),
    );
  }

  Widget _row(VoucherRow v) {
    return Container(
      decoration: AkTheme.card,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => VoucherDetailScreen(id: v.id))),
        title: Row(
          children: [
            Text(v.voucherNo, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            if (v.cancelled)
              const _Badge('Cancelled', AkTheme.danger)
            else
              _Badge(_typeLabels[v.type] ?? v.type, AkTheme.teal600),
          ],
        ),
        subtitle: Text('${v.partyName ?? '—'} • ${v.date}'),
        trailing: Text('₹${v.grandTotal}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      ),
    );
  }

  Widget _msg(String m) => ListView(children: [
        Padding(
          padding: const EdgeInsets.all(40),
          child: Center(child: Text(m, textAlign: TextAlign.center, style: const TextStyle(color: AkTheme.muted))),
        )
      ]);
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}
