import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../state/session.dart';
import '../api/ak_service.dart';
import '../models/models.dart';

class VoucherDetailScreen extends StatefulWidget {
  final int id;
  const VoucherDetailScreen({super.key, required this.id});
  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  final _service = AkService();
  late Future<VoucherDetail> _future;

  static const _titles = {
    'sale': 'Tax Invoice', 'purchase': 'Purchase', 'receipt': 'Receipt',
    'payment': 'Payment', 'sale_return': 'Credit Note', 'purchase_return': 'Debit Note',
    'journal': 'Journal',
  };

  @override
  void initState() {
    super.initState();
    _future = _service.voucher(widget.id);
  }

  void _share(VoucherDetail v) {
    final co = Session.instance.company?.name ?? 'Account Keeping';
    final b = StringBuffer()
      ..writeln(co)
      ..writeln('${_titles[v.type] ?? v.type} ${v.voucherNo} • ${v.date}')
      ..writeln('Party: ${v.partyName}${v.partyGstin.isNotEmpty ? ' (GSTIN ${v.partyGstin})' : ''}')
      ..writeln('');
    for (final it in v.items) {
      b.writeln('• ${it.description}  ${it.qty} x ₹${it.rate}  = ₹${it.total}');
    }
    b
      ..writeln('')
      ..writeln('Taxable: ₹${v.taxable}');
    if ((double.tryParse(v.cgst) ?? 0) > 0) b.writeln('CGST: ₹${v.cgst}   SGST: ₹${v.sgst}');
    if ((double.tryParse(v.igst) ?? 0) > 0) b.writeln('IGST: ₹${v.igst}');
    b.writeln('TOTAL: ₹${v.grandTotal}');
    Share.share(b.toString(), subject: '${v.voucherNo} • $co');
  }

  bool _has(String s) => (double.tryParse(s) ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher'),
        actions: [
          FutureBuilder<VoucherDetail>(
            future: _future,
            builder: (context, snap) => snap.hasData
                ? IconButton(icon: const Icon(Icons.share), onPressed: () => _share(snap.data!))
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: FutureBuilder<VoucherDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: AkTheme.danger)));
          }
          final v = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: AkTheme.card,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: AkTheme.headerGradient,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Session.instance.company?.name ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('${(_titles[v.type] ?? v.type).toUpperCase()}  •  ${v.voucherNo}  •  ${v.date}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (v.cancelled)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('CANCELLED', style: TextStyle(color: AkTheme.danger, fontWeight: FontWeight.w800)),
                            ),
                          Text('Party: ${v.partyName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          if (v.partyGstin.isNotEmpty)
                            Text('GSTIN: ${v.partyGstin}', style: const TextStyle(color: AkTheme.muted, fontSize: 12.5)),
                          const Divider(height: 20),
                          ...v.items.map((it) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(it.description, style: const TextStyle(fontSize: 13.5)),
                                          Text('${it.qty} × ₹${it.rate}  (GST ${it.gstRate}%)',
                                              style: const TextStyle(color: AkTheme.muted, fontSize: 11.5)),
                                        ],
                                      ),
                                    ),
                                    Text('₹${it.total}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              )),
                          const Divider(height: 20),
                          _row('Taxable Value', v.taxable),
                          if (_has(v.cgst)) _row('CGST', v.cgst),
                          if (_has(v.sgst)) _row('SGST', v.sgst),
                          if (_has(v.igst)) _row('IGST', v.igst),
                          if (_has(v.roundOff)) _row('Round Off', v.roundOff),
                          const SizedBox(height: 4),
                          _row('Grand Total', v.grandTotal, bold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _share(v),
                icon: const Icon(Icons.share),
                label: const Text('Share Invoice'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 16 : 13.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text('₹$value', style: style)],
      ),
    );
  }
}
