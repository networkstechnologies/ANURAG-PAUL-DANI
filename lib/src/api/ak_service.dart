import 'api_client.dart';
import '../models/models.dart';
import '../state/session.dart';

/// Typed wrappers over the Account Keeping API.
class AkService {
  final ApiClient _api;
  AkService([ApiClient? api]) : _api = api ?? ApiClient();

  /// Login → returns token + companies (fetched via /auth/me).
  Future<void> login(String email, String password) async {
    final res = await _api.post('/auth/login',
        {'email': email, 'password': password}, company: false) as Map<String, dynamic>;
    final token = res['token'] as String;
    Session.instance.token = token; // needed for the /auth/me call below
    final me = await _api.get('/auth/me', company: false) as Map<String, dynamic>;
    final companies = ((me['companies'] as List?) ?? [])
        .map((e) => CompanyRef.fromJson(e as Map<String, dynamic>))
        .toList();
    await Session.instance.saveAuth(
      token: token,
      userName: (me['user']?['name'] ?? res['user']?['name'] ?? '') as String,
      companies: companies,
    );
    if (companies.length == 1) await Session.instance.setCompany(companies.first.id);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {}, company: false);
    } catch (_) {}
    await Session.instance.clear();
  }

  Future<Dashboard> dashboard() async =>
      Dashboard.fromJson(await _api.get('/dashboard') as Map<String, dynamic>);

  Future<List<Party>> parties({String? type}) async {
    final res = await _api.get('/parties', query: type != null ? {'type': type} : null) as List;
    return res.map((e) => Party.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Party> addParty(Map<String, dynamic> body) async =>
      Party.fromJson(await _api.post('/parties', body) as Map<String, dynamic>);

  Future<List<Item>> items() async {
    final res = await _api.get('/items') as List;
    return res.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Item> addItem(Map<String, dynamic> body) async =>
      Item.fromJson(await _api.post('/items', body) as Map<String, dynamic>);

  Future<List<VoucherRow>> vouchers({String? type}) async {
    final res = await _api.get('/vouchers', query: type != null ? {'type': type} : null);
    final data = (res is Map && res['data'] is List) ? res['data'] as List : (res as List);
    return data.map((e) => VoucherRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VoucherDetail> voucher(int id) async =>
      VoucherDetail.fromJson(await _api.get('/vouchers/$id') as Map<String, dynamic>);

  /// Create a sale invoice. items: [{item_id, qty, rate, gst_rate, discount_pct}]
  Future<VoucherDetail> createSale({
    required int partyId,
    required String date,
    required List<Map<String, dynamic>> items,
    String? narration,
  }) async {
    final res = await _api.post('/vouchers', {
      'type': 'sale', 'party_id': partyId, 'date': date,
      if (narration != null && narration.isNotEmpty) 'narration': narration,
      'items': items,
    }) as Map<String, dynamic>;
    return VoucherDetail.fromJson(res);
  }

  /// Record a receipt (money in) against a party.
  Future<VoucherDetail> createReceipt({
    required int partyId,
    required String date,
    required double amount,
    String mode = 'bank',
    String? narration,
  }) async {
    final res = await _api.post('/vouchers', {
      'type': 'receipt', 'party_id': partyId, 'date': date,
      'amount': amount, 'mode': mode,
      if (narration != null && narration.isNotEmpty) 'narration': narration,
    }) as Map<String, dynamic>;
    return VoucherDetail.fromJson(res);
  }

  Future<Map<String, dynamic>> profitAndLoss() async =>
      await _api.get('/reports/profit-loss') as Map<String, dynamic>;

  Future<List<OutstandingRow>> outstanding(String side) async {
    final res = await _api.get('/reports/outstanding', query: {'side': side}) as Map<String, dynamic>;
    return ((res['rows'] as List?) ?? []).map((e) => OutstandingRow.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> gstSummary() async =>
      await _api.get('/reports/gst-summary') as Map<String, dynamic>;
}
