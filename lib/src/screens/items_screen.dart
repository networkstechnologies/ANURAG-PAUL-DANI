import 'package:flutter/material.dart';
import '../theme.dart';
import '../api/ak_service.dart';
import '../models/models.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});
  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _service = AkService();
  late Future<List<Item>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.items();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.items());
    await _future;
  }

  Future<void> _addDialog() async {
    final name = TextEditingController();
    final sale = TextEditingController();
    final purchase = TextEditingController();
    final gst = TextEditingController(text: '18');
    final unit = TextEditingController(text: 'NOS');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Item / Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name *')),
              const SizedBox(height: 10),
              TextField(controller: sale, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sale Price ₹')),
              const SizedBox(height: 10),
              TextField(controller: purchase, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Purchase Price ₹')),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: gst, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GST %'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unit'))),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      try {
        await _service.addItem({
          'name': name.text.trim(),
          'sale_price': double.tryParse(sale.text) ?? 0,
          'purchase_price': double.tryParse(purchase.text) ?? 0,
          'gst_rate': double.tryParse(gst.text) ?? 0,
          'unit': unit.text.trim().isEmpty ? 'NOS' : unit.text.trim(),
        });
        _refresh();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products & Services')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Item>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('${snap.error}', style: const TextStyle(color: AkTheme.danger)))]);
            }
            final rows = snap.data ?? [];
            if (rows.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No items yet.')))]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = rows[i];
                return Container(
                  decoration: AkTheme.card,
                  child: ListTile(
                    title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('GST ${it.gstRate.toStringAsFixed(0)}% • ${it.unit ?? 'NOS'}'),
                    trailing: Text('₹${it.salePrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AkTheme.teal600,
        onPressed: _addDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
