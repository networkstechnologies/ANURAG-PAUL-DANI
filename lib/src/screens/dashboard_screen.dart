import 'package:flutter/material.dart';
import '../theme.dart';
import '../api/ak_service.dart';
import '../models/models.dart';
import 'items_screen.dart';
import 'new_receipt_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = AkService();
  late Future<Dashboard> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.dashboard();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.dashboard());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<Dashboard>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load: ${snap.error}',
                    style: const TextStyle(color: AkTheme.danger)),
              )
            ]);
          }
          final d = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Financial Year ${d.fy}',
                  style: const TextStyle(color: AkTheme.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _tile('Sales (FY)', '₹${d.sales}', AkTheme.teal600),
                  _tile('Purchases (FY)', '₹${d.purchases}', AkTheme.navy),
                  _tile('Receivable', '₹${d.receivable}', AkTheme.goldDark),
                  _tile('Payable', '₹${d.payable}', AkTheme.danger),
                  _tile('Cash', d.cash, AkTheme.navy),
                  _tile('Bank', d.bank, AkTheme.navy),
                  _tile(d.isProfit ? 'Net Profit' : 'Net Loss', '₹${d.netProfit}',
                      d.isProfit ? AkTheme.green : AkTheme.danger),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Quick actions',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _quick(Icons.south_west, 'Record Receipt', const NewReceiptScreen())),
                  const SizedBox(width: 12),
                  Expanded(child: _quick(Icons.inventory_2_outlined, 'Products & Services', const ItemsScreen())),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _quick(IconData icon, String label, Widget screen) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: AkTheme.card,
        child: Column(
          children: [
            Icon(icon, color: AkTheme.teal600, size: 26),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AkTheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: AkTheme.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(color: color, fontSize: 21, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
