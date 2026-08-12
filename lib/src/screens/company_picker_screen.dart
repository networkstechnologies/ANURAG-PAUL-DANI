import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/session.dart';

class CompanyPickerScreen extends StatelessWidget {
  const CompanyPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Session.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Company'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => s.clear()),
        ],
      ),
      body: s.companies.isEmpty
          ? const Center(child: Text('No companies on this account.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: s.companies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = s.companies[i];
                return Container(
                  decoration: AkTheme.card,
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundColor: AkTheme.soft,
                        child: Icon(Icons.business, color: AkTheme.teal600)),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([c.city, c.gstin].where((e) => e != null && e.isNotEmpty).join(' • ')),
                    trailing: const Icon(Icons.chevron_right, color: AkTheme.teal600),
                    onTap: () => s.setCompany(c.id),
                  ),
                );
              },
            ),
    );
  }
}
