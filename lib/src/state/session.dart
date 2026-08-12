import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyRef {
  final int id;
  final String name;
  final String? gstin;
  final String? city;
  CompanyRef({required this.id, required this.name, this.gstin, this.city});
  factory CompanyRef.fromJson(Map<String, dynamic> j) => CompanyRef(
        id: j['id'], name: j['name'] ?? '', gstin: j['gstin'], city: j['city']);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'gstin': gstin, 'city': city};
}

/// App-wide auth + acting-company state (singleton, persisted).
class Session extends ChangeNotifier {
  Session._();
  static final Session instance = Session._();

  String? token;
  String? userName;
  int? companyId;
  List<CompanyRef> companies = [];

  bool get isAuthed => token != null && companyId != null;
  CompanyRef? get company {
    for (final c in companies) {
      if (c.id == companyId) return c;
    }
    return null;
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString('ak_token');
    userName = p.getString('ak_user');
    companyId = p.getInt('ak_company');
    final raw = p.getString('ak_companies');
    if (raw != null) {
      companies = (jsonDecode(raw) as List)
          .map((e) => CompanyRef.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> saveAuth({
    required String token,
    required String userName,
    required List<CompanyRef> companies,
  }) async {
    this.token = token;
    this.userName = userName;
    this.companies = companies;
    final p = await SharedPreferences.getInstance();
    await p.setString('ak_token', token);
    await p.setString('ak_user', userName);
    await p.setString('ak_companies', jsonEncode(companies.map((c) => c.toJson()).toList()));
    notifyListeners();
  }

  Future<void> setCompany(int id) async {
    companyId = id;
    final p = await SharedPreferences.getInstance();
    await p.setInt('ak_company', id);
    notifyListeners();
  }

  /// Clear the acting company (returns the user to the company picker).
  Future<void> setCompanyNull() async {
    companyId = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('ak_company');
    notifyListeners();
  }

  Future<void> clear() async {
    token = null;
    userName = null;
    companyId = null;
    companies = [];
    final p = await SharedPreferences.getInstance();
    await p.remove('ak_token');
    await p.remove('ak_user');
    await p.remove('ak_company');
    await p.remove('ak_companies');
    notifyListeners();
  }
}
