import 'package:flutter/material.dart';
import '../theme.dart';
import '../api/ak_service.dart';
import '../models/models.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});
  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  final _service = AkService();
  late Future<List<Party>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.parties();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.parties());
    await _future;
  }

  Future<void> _addDialog() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final gstin = TextEditingController();
    String type = 'customer';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Add Party'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Name *')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                    DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
                    DropdownMenuItem(value: 'both', child: Text('Both')),
                  ],
                  onChanged: (v) => setLocal(() => type = v ?? 'customer'),
                ),
                const SizedBox(height: 10),
                TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 10),
                TextField(controller: gstin, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'GSTIN')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      try {
        await _service.addParty({
          'name': name.text.trim(),
          'type': type,
          if (phone.text.trim().isNotEmpty) 'phone': phone.text.trim(),
          if (gstin.text.trim().isNotEmpty) 'gstin': gstin.text.trim().toUpperCase(),
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Party>>(
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
              return ListView(children: const [Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No parties yet.')))]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = rows[i];
                return Container(
                  decoration: AkTheme.card,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: p.type == 'vendor' ? AkTheme.gold.withOpacity(0.25) : AkTheme.soft,
                      child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: AkTheme.teal800, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([p.type, p.phone, p.gstin].where((e) => e != null && e.isNotEmpty).join(' • ')),
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
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
