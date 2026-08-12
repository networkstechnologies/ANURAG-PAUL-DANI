import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/session.dart';
import '../api/ak_service.dart';
import 'dashboard_screen.dart';
import 'vouchers_screen.dart';
import 'parties_screen.dart';
import 'reports_screen.dart';
import 'new_invoice_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  final _pages = const [
    DashboardScreen(),
    VouchersScreen(),
    PartiesScreen(),
    ReportsScreen(),
  ];
  final _titles = const ['Dashboard', 'Invoices', 'Parties', 'Reports'];

  @override
  Widget build(BuildContext context) {
    final s = Session.instance;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titles[_tab], style: const TextStyle(fontSize: 18)),
            Text(s.company?.name ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'switch') {
                await s.setCompanyNull();
              } else if (v == 'logout') {
                await AkService().logout();
              }
            },
            itemBuilder: (_) => [
              if (s.companies.length > 1)
                const PopupMenuItem(value: 'switch', child: Text('Switch company')),
              const PopupMenuItem(value: 'logout', child: Text('Log out')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: _pages),
      floatingActionButton: (_tab == 0 || _tab == 1)
          ? FloatingActionButton.extended(
              backgroundColor: AkTheme.gold,
              foregroundColor: AkTheme.navy,
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewInvoiceScreen())),
              icon: const Icon(Icons.add),
              label: const Text('New Invoice', style: TextStyle(fontWeight: FontWeight.w800)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Invoices'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Parties'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }
}
