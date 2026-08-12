import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../api/ak_service.dart';
import '../models/models.dart';
import 'voucher_detail_screen.dart';
import 'new_receipt_screen.dart';

class _Line {
  int? itemId;
  String name = '';
  double qty = 1;
  double rate = 0;
  double gstRate = 0;
}

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});
  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _service = AkService();
  List<Party> _parties = [];
  List<Item> _items = [];
  Party? _party;
  DateTime _date = DateTime.now();
  final List<_Line> _lines = [_Line()];
  bool _loading = true, _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  Future<void> _loadMasters() async {
    try {
      final res = await Future.wait([_service.parties(type: 'customer'), _service.items()]);
      setState(() {
        _parties = res[0] as List<Party>;
        _items = res[1] as List<Item>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  double get _taxable => _lines.fold(0, (s, l) => s + l.qty * l.rate);
  double get _gst => _lines.fold(0, (s, l) => s + l.qty * l.rate * l.gstRate / 100);
  double get _grand => (_taxable + _gst);

  Future<void> _save() async {
    if (_party == null) {
      setState(() => _error = 'Choose a customer.');
      return;
    }
    final valid = _lines.where((l) => l.itemId != null && l.qty > 0).toList();
    if (valid.isEmpty) {
      setState(() => _error = 'Add at least one item.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final v = await _service.createSale(
        partyId: _party!.id,
        date: DateFormat('yyyy-MM-dd').format(_date),
        items: valid
            .map((l) => {
                  'item_id': l.itemId, 'qty': l.qty, 'rate': l.rate, 'gst_rate': l.gstRate,
                })
            .toList(),
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
      appBar: AppBar(
        title: const Text('New Sale Invoice'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const NewReceiptScreen())),
            child: const Text('Receipt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_error != null) _errorBox(_error!),
                      DropdownButtonFormField<Party>(
                        value: _party,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Customer *'),
                        items: _parties
                            .map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (p) => setState(() => _party = p),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date'),
                          child: Text(DateFormat('dd MMM yyyy').format(_date)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Items', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      ..._lines.asMap().entries.map((e) => _lineCard(e.key, e.value)),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: () => setState(() => _lines.add(_Line())),
                        icon: const Icon(Icons.add),
                        label: const Text('Add item'),
                      ),
                    ],
                  ),
                ),
                _summaryBar(),
              ],
            ),
    );
  }

  Widget _lineCard(int i, _Line l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AkTheme.card,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: l.itemId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Item'),
                  items: _items
                      .map((it) => DropdownMenuItem(value: it.id, child: Text(it.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (id) => setState(() {
                    final it = _items.firstWhere((x) => x.id == id);
                    l.itemId = it.id;
                    l.name = it.name;
                    l.rate = it.salePrice;
                    l.gstRate = it.gstRate;
                  }),
                ),
              ),
              if (_lines.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: AkTheme.danger),
                  onPressed: () => setState(() => _lines.removeAt(i)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _numField('Qty', l.qty, (v) => setState(() => l.qty = v),
                  key: ValueKey('qty_$i'))),
              const SizedBox(width: 8),
              // Keyed to the item so Rate/GST refresh when an item is picked.
              Expanded(child: _numField('Rate ₹', l.rate, (v) => setState(() => l.rate = v),
                  key: ValueKey('rate_${i}_${l.itemId}'))),
              const SizedBox(width: 8),
              Expanded(child: _numField('GST %', l.gstRate, (v) => setState(() => l.gstRate = v),
                  key: ValueKey('gst_${i}_${l.itemId}'))),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Line: ₹${(l.qty * l.rate * (1 + l.gstRate / 100)).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AkTheme.teal800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numField(String label, double value, ValueChanged<double> onChanged, {Key? key}) {
    return TextFormField(
      key: key,
      initialValue: _fmt(value),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  Widget _summaryBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AkTheme.line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _sumRow('Taxable', _taxable),
            _sumRow('GST', _gst),
            _sumRow('Grand Total', _grand, bold: true),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AkTheme.goldButton,
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sumRow(String label, double value, {bool bold = false}) {
    final s = TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 17 : 13.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: s), Text('₹${value.toStringAsFixed(2)}', style: s)],
      ),
    );
  }

  Widget _errorBox(String m) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: const Color(0xFFFDE3EA), borderRadius: BorderRadius.circular(9)),
        child: Text(m, style: const TextStyle(color: AkTheme.danger)),
      );

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }
}
