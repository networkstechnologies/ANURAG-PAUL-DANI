import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../api/ak_service.dart';
import '../models/models.dart';
import 'voucher_detail_screen.dart';

class NewReceiptScreen extends StatefulWidget {
  const NewReceiptScreen({super.key});
  @override
  State<NewReceiptScreen> createState() => _NewReceiptScreenState();
}

class _NewReceiptScreenState extends State<NewReceiptScreen> {
  final _service = AkService();
  List<Party> _parties = [];
  Party? _party;
  DateTime _date = DateTime.now();
  final _amount = TextEditingController();
  String _mode = 'bank';
  bool _loading = true, _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service.parties().then((p) => setState(() {
          _parties = p;
          _loading = false;
        })).catchError((e) => setState(() {
          _error = '$e';
          _loading = false;
        }));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amt = double.tryParse(_amount.text) ?? 0;
    if (_party == null || amt <= 0) {
      setState(() => _error = 'Choose a party and enter an amount.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final v = await _service.createReceipt(
        partyId: _party!.id,
        date: DateFormat('yyyy-MM-dd').format(_date),
        amount: amt,
        mode: _mode,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => VoucherDetailScreen(id: v.id)));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Receipt')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(color: const Color(0xFFFDE3EA), borderRadius: BorderRadius.circular(9)),
                    child: Text(_error!, style: const TextStyle(color: AkTheme.danger)),
                  ),
                DropdownButtonFormField<Party>(
                  value: _party,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'From Party *'),
                  items: _parties
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (p) => setState(() => _party = p),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount ₹ *', prefixText: '₹ '),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _mode,
                  decoration: const InputDecoration(labelText: 'Received in'),
                  items: const [
                    DropdownMenuItem(value: 'bank', child: Text('Bank')),
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  ],
                  onChanged: (v) => setState(() => _mode = v ?? 'bank'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                        context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (d != null) setState(() => _date = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: AkTheme.goldButton,
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Receipt'),
                ),
              ],
            ),
    );
  }
}
