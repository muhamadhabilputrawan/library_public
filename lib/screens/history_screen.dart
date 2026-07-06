import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/borrow_provider.dart';
import '../widget/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  final bool isEmbedded;

  const HistoryScreen({super.key, this.isEmbedded = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer2<BorrowProvider, AuthProvider>(
      builder: (ctx, prov, auth, _) {
        final memberHistory = prov.historyByMember(auth.userId);
        final activeCount = memberHistory
            .where((b) => b.status == 'borrowed')
            .length;
        final returnedCount = memberHistory
            .where((b) => b.status == 'returned')
            .length;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu, color: Color(0xFF1565C0)),
                  const SizedBox(width: 8),
                  const Text(
                    'Lumina Library',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.search, color: Color(0xFF1565C0)),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF1565C0),
                    child: Text(
                      auth.userName.isNotEmpty
                          ? auth.userName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Borrow History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Review your reading journey and active loans.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    '$activeCount',
                    'Active',
                    const Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard('$returnedCount', 'Read', Colors.green),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    '${memberHistory.length}',
                    'Total',
                    Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Consumer2<BorrowProvider, AuthProvider>(
      builder: (ctx, prov, auth, _) {
        // Filter history berdasarkan memberId yang sedang login
        final memberHistory = prov.historyByMember(auth.userId);

        if (memberHistory.isEmpty) {
          return const EmptyStateWidget(
            title: 'Belum ada riwayat',
            subtitle: 'Pinjam buku pertama Anda untuk melihat riwayat di sini.',
            icon: Icons.history_outlined,
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF1565C0),
          onRefresh: () async => prov.loadHistory(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: memberHistory.length,
            itemBuilder: (ctx, i) {
              final borrow = memberHistory[i];
              final isBorrowed = borrow.status == 'borrowed';
              final isOverdue = _isOverdue(borrow.borrowDate) && isBorrowed;

              return _BorrowCard(
                title: borrow.bookTitle.isNotEmpty
                    ? borrow.bookTitle
                    : 'Unknown Book',
                author: borrow.bookAuthor.isNotEmpty
                    ? borrow.bookAuthor
                    : 'Unknown Author',
                thumbnail: borrow.bookThumbnail,
                date: borrow.borrowDate,
                status: isBorrowed
                    ? (isOverdue ? 'overdue' : 'borrowed')
                    : 'returned',
              );
            },
          ),
        );
      },
    );
  }

  bool _isOverdue(String borrowDate) {
    try {
      final date = DateTime.parse(borrowDate);
      final dueDate = date.add(const Duration(days: 14));
      return DateTime.now().isAfter(dueDate);
    } catch (_) {
      return false;
    }
  }
}

// ─── Reusable Borrow Card ────────────────────────────────────────────────────
class _BorrowCard extends StatelessWidget {
  final String title;
  final String author;
  final String thumbnail;
  final String date;
  final String status; // 'borrowed' | 'returned' | 'overdue'

  const _BorrowCard({
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = status == 'overdue';
    final isBorrowed = status == 'borrowed' || isOverdue;

    Color badgeColor;
    String badgeLabel;
    if (isOverdue) {
      badgeColor = Colors.red;
      badgeLabel = 'Overdue';
    } else if (isBorrowed) {
      badgeColor = const Color(0xFF1565C0);
      badgeLabel = 'Active';
    } else {
      badgeColor = Colors.grey;
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
                      width: 64,
                      height: 88,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => _coverPlaceholder(),
                      errorWidget: (ctx, url, err) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge di atas kanan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  // Date row
                  Row(
                    children: [
                      Icon(
                        isOverdue
                            ? Icons.warning_amber_rounded
                            : isBorrowed
                            ? Icons.calendar_month_outlined
                            : Icons.history,
                        size: 13,
                        color: isOverdue
                            ? Colors.red
                            : isBorrowed
                            ? const Color(0xFF1565C0)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue
                            ? 'Due on $date'
                            : isBorrowed
                            ? 'Borrowed on $date'
                            : 'Returned on $date',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue
                              ? Colors.red
                              : isBorrowed
                              ? const Color(0xFF1565C0)
                              : Colors.grey,
                          fontWeight: isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 64,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFF1565C0),
        size: 28,
      ),
    );
  }
}
