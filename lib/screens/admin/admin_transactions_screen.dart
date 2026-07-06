import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/borrow_provider.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Transactions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola semua transaksi peminjaman',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabCtrl,
                  labelColor: const Color(0xFF1565C0),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1565C0),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Active'),
                    Tab(text: 'Returned'),
                  ],
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _TransactionList(filter: 'all'),
                _TransactionList(filter: 'borrowed'),
                _TransactionList(filter: 'returned'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final String filter; // 'all' | 'borrowed' | 'returned'

  const _TransactionList({required this.filter});

  @override
  Widget build(BuildContext context) {
    final borrow = context.watch<BorrowProvider>();
    final auth = context.watch<AuthProvider>();

    final list = filter == 'all'
        ? borrow.history
        : borrow.history.where((b) => b.status == filter).toList();

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              filter == 'borrowed'
                  ? 'Tidak ada peminjaman aktif'
                  : filter == 'returned'
                  ? 'Tidak ada buku yang dikembalikan'
                  : 'Belum ada transaksi',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF1565C0),
      onRefresh: () async => borrow.loadHistory(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final b = list[i];
          final isBorrowed = b.status == 'borrowed';
          final isOverdue = isBorrowed && _checkOverdue(b.borrowDate);

          // Cari nama member
          final members = auth.getAllMembers();
          final memberData = members.firstWhere(
            (m) => m['id'] == b.memberId,
            orElse: () => {'name': b.memberId},
          );
          final memberName = memberData['name'] ?? b.memberId;

          return _TransactionCard(
            borrowId: b.id,
            bookTitle: b.bookTitle.isNotEmpty ? b.bookTitle : b.bookId,
            bookAuthor: b.bookAuthor,
            thumbnail: b.bookThumbnail,
            memberName: memberName,
            date: b.borrowDate,
            isBorrowed: isBorrowed,
            isOverdue: isOverdue,
            onReturn: isBorrowed
                ? () => _confirmReturn(ctx, borrow, b.id, b.bookTitle)
                : null,
          );
        },
      ),
    );
  }

  bool _checkOverdue(String date) {
    try {
      final d = DateTime.parse(date);
      return DateTime.now().isAfter(d.add(const Duration(days: 14)));
    } catch (_) {
      return false;
    }
  }

  void _confirmReturn(
    BuildContext context,
    BorrowProvider borrow,
    String borrowId,
    String bookTitle,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
        content: Text(
          'Tandai "${bookTitle.isNotEmpty ? bookTitle : 'buku ini'}" sebagai dikembalikan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Kembalikan'),
            onPressed: () {
              borrow.returnBook(borrowId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Buku berhasil dikembalikan!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String borrowId;
  final String bookTitle;
  final String bookAuthor;
  final String thumbnail;
  final String memberName;
  final String date;
  final bool isBorrowed;
  final bool isOverdue;
  final VoidCallback? onReturn;

  const _TransactionCard({
    required this.borrowId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.thumbnail,
    required this.memberName,
    required this.date,
    required this.isBorrowed,
    required this.isOverdue,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeLabel;
    if (isOverdue) {
      badgeColor = Colors.red;
      badgeLabel = 'Overdue';
    } else if (isBorrowed) {
      badgeColor = const Color(0xFF1565C0);
      badgeLabel = 'Active';
    } else {
      badgeColor = Colors.green;
      badgeLabel = 'Returned';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isOverdue
            ? Border.all(color: Colors.red.shade300, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: thumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: thumbnail,
                      width: 56,
                      height: 78,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, url, err) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          bookTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeLabel,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (bookAuthor.isNotEmpty)
                    Text(
                      bookAuthor,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Member info
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        memberName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        isOverdue
                            ? Icons.warning_amber_rounded
                            : Icons.calendar_today_outlined,
                        size: 12,
                        color: isOverdue ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isOverdue ? 'Due: $date' : 'Borrowed: $date',
                        style: TextStyle(
                          fontSize: 11,
                          color: isOverdue ? Colors.red : Colors.grey,
                          fontWeight: isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (onReturn != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: onReturn,
                        icon: const Icon(Icons.assignment_return, size: 14),
                        label: const Text(
                          'Return Book',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFF1565C0),
        size: 24,
      ),
    );
  }
}
