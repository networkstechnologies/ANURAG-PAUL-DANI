/// Data models for the Account Keeping app.

double _d(dynamic v) => double.tryParse('$v') ?? 0;

class Dashboard {
  final String fy, sales, purchases, receivable, payable, cash, bank, netProfit;
  final bool isProfit;
  Dashboard(this.fy, this.sales, this.purchases, this.receivable, this.payable,
      this.cash, this.bank, this.netProfit, this.isProfit);
  factory Dashboard.fromJson(Map<String, dynamic> j) => Dashboard(
        j['fy'] ?? '', '${j['sales']}', '${j['purchases']}', '${j['receivable']}',
        '${j['payable']}', '${j['cash']}', '${j['bank']}', '${j['net_profit']}',
        j['is_profit'] == true,
      );
}

class Party {
  final int id;
  final String name, type;
  final String? gstin, phone, stateCode;
  Party({required this.id, required this.name, required this.type, this.gstin, this.phone, this.stateCode});
  factory Party.fromJson(Map<String, dynamic> j) => Party(
        id: j['id'], name: j['name'] ?? '', type: j['type'] ?? 'customer',
        gstin: j['gstin'], phone: j['phone'], stateCode: j['state_code']);
}

class Item {
  final int id;
  final String name;
  final double salePrice, purchasePrice, gstRate;
  final String? unit, hsn;
  Item({required this.id, required this.name, required this.salePrice,
    required this.purchasePrice, required this.gstRate, this.unit, this.hsn});
  factory Item.fromJson(Map<String, dynamic> j) => Item(
        id: j['id'], name: j['name'] ?? '', salePrice: _d(j['sale_price']),
        purchasePrice: _d(j['purchase_price']), gstRate: _d(j['gst_rate']),
        unit: j['unit'], hsn: j['hsn_sac']);
}

class VoucherRow {
  final int id;
  final String voucherNo, type, date, grandTotal;
  final bool cancelled;
  final String? partyName;
  VoucherRow({required this.id, required this.voucherNo, required this.type,
    required this.date, required this.grandTotal, required this.cancelled, this.partyName});
  factory VoucherRow.fromJson(Map<String, dynamic> j) => VoucherRow(
        id: j['id'], voucherNo: j['voucher_no'] ?? '', type: j['type'] ?? '',
        date: '${j['date']}'.split('T').first, grandTotal: '${j['grand_total']}',
        cancelled: j['is_cancelled'] == true,
        partyName: j['party'] is Map ? j['party']['name'] : null);
}

class VoucherLine {
  final String description, qty, rate, gstRate, taxable, total;
  VoucherLine(this.description, this.qty, this.rate, this.gstRate, this.taxable, this.total);
  factory VoucherLine.fromJson(Map<String, dynamic> j) => VoucherLine(
        j['description'] ?? (j['item']?['name'] ?? ''), '${j['qty']}', '${j['rate']}',
        '${j['gst_rate']}', '${j['taxable_value']}', '${j['total']}');
}

class VoucherDetail {
  final int id;
  final String voucherNo, type, date, partyName, partyGstin;
  final String taxable, cgst, sgst, igst, roundOff, grandTotal, narration;
  final bool cancelled;
  final List<VoucherLine> items;
  VoucherDetail({required this.id, required this.voucherNo, required this.type,
    required this.date, required this.partyName, required this.partyGstin,
    required this.taxable, required this.cgst, required this.sgst, required this.igst,
    required this.roundOff, required this.grandTotal, required this.narration,
    required this.cancelled, required this.items});
  factory VoucherDetail.fromJson(Map<String, dynamic> j) => VoucherDetail(
        id: j['id'], voucherNo: j['voucher_no'] ?? '', type: j['type'] ?? '',
        date: '${j['date']}'.split('T').first,
        partyName: j['party'] is Map ? (j['party']['name'] ?? '') : '',
        partyGstin: j['party'] is Map ? (j['party']['gstin'] ?? '') : '',
        taxable: '${j['taxable_total']}', cgst: '${j['cgst_total']}',
        sgst: '${j['sgst_total']}', igst: '${j['igst_total']}',
        roundOff: '${j['round_off']}', grandTotal: '${j['grand_total']}',
        narration: j['narration'] ?? '', cancelled: j['is_cancelled'] == true,
        items: ((j['items'] as List?) ?? []).map((e) => VoucherLine.fromJson(e)).toList());
}

class OutstandingRow {
  final String party, amount;
  final String? phone;
  OutstandingRow(this.party, this.amount, this.phone);
  factory OutstandingRow.fromJson(Map<String, dynamic> j) =>
      OutstandingRow(j['party'] ?? '', '${j['amount']}', j['phone']);
}
