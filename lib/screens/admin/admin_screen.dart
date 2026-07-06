import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/borrow_provider.dart';
import '../login_screen.dart';
import 'admin_books_screen.dart';
import 'admin_members_screen.dart';
import 'admin_transactions_screen.dart';

// ─── Main Admin Shell ────────────────────────────────────────────────────────
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _AdminDashboard(),
    AdminMembersScreen(),
    AdminBooksScreen(),
    AdminTransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ───────────────────────────────────────────────────────────
class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final borrow = context.watch<BorrowProvider>();

    final activeBorrow = borrow.activeLoans.length;
    final returnedCount = borrow.returnedBooks.length;
    final overdueCount = borrow.history.where((b) {
      if (b.status != 'borrowed') return false;
      try {
        final d = DateTime.parse(b.borrowDate);
        return DateTime.now().isAfter(d.add(const Duration(days: 14)));
      } catch (_) {
        return false;
      }
    }).length;
    final members = auth.getAllMembers();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Color(0xFF1565C0),
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
                _AdminLogoutBtn(),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome, ${auth.userName}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ── Stats grid ──────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  label: 'Total Members',
                  value: '${members.length}',
                  icon: Icons.people,
                  color: const Color(0xFF1565C0),
                ),
                _StatCard(
                  label: 'Active Loans',
                  value: '$activeBorrow',
                  icon: Icons.book_online,
                  color: Colors.orange,
                ),
                _StatCard(
                  label: 'Returned',
                  value: '$returnedCount',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _StatCard(
                  label: 'Overdue',
                  value: '$overdueCount',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Recent transactions ─────────────────────────────
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 10),
            if (borrow.history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Belum ada transaksi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...borrow.history.reversed
                  .take(5)
                  .map((b) => _RecentTile(borrow: b)),
            const SizedBox(height: 20),

            // ── Quick actions ───────────────────────────────────
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickBtn(
                    icon: Icons.people,
                    label: 'Manage Members',
                    color: const Color(0xFF1565C0),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Members'),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1565C0),
                            elevation: 0,
                          ),
                          body: const AdminMembersScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickBtn(
                    icon: Icons.swap_horiz,
                    label: 'Transactions',
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Transactions'),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1565C0),
                            elevation: 0,
                          ),
                          body: const AdminTransactionsScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Recent Transaction Tile ──────────────────────────────────────────────────
class _RecentTile extends StatelessWidget {
  final dynamic borrow;
  const _RecentTile({required this.borrow});

  @override
  Widget build(BuildContext context) {
    final isBorrowed = borrow.status == 'borrowed';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isBorrowed ? Icons.book_online : Icons.check_circle_outline,
            color: isBorrowed ? const Color(0xFF1565C0) : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  borrow.bookTitle.isNotEmpty
                      ? borrow.bookTitle
                      : borrow.bookId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
                Text(
                  borrow.borrowDate,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isBorrowed
                  ? const Color(0xFFE8F0FE)
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isBorrowed ? 'Active' : 'Returned',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isBorrowed ? const Color(0xFF1565C0) : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Button ──────────────────────────────────────────────────────
class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────
class _AdminLogoutBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      tooltip: 'Logout',
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Keluar'),
            content: const Text('Yakin ingin keluar dari panel admin?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      },
    );
  }
}
