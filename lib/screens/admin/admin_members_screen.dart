import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/borrow_provider.dart';

class AdminMembersScreen extends StatelessWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final borrow = context.watch<BorrowProvider>();
    final members = auth.getAllMembers();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF1565C0), size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Manage Members',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${members.length} Members',
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: members.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada member',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    itemBuilder: (ctx, i) {
                      final m = members[i];
                      final memberHistory = borrow.historyByMember(m['id']!);
                      final active = memberHistory
                          .where((b) => b.status == 'borrowed')
                          .length;
                      final returned = memberHistory
                          .where((b) => b.status == 'returned')
                          .length;

                      return _MemberCard(
                        id: m['id']!,
                        name: m['name']!,
                        email: m['email']!,
                        activeLoans: active,
                        returnedBooks: returned,
                        onDetail: () =>
                            _showMemberDetail(context, m, memberHistory),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetail(
    BuildContext context,
    Map<String, String> member,
    List borrowHistory,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE8F0FE),
                    child: Text(
                      member['name']![0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name']!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        Text(
                          member['email']!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Member',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Borrow History',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: borrowHistory.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada riwayat peminjaman',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: borrowHistory.length,
                        itemBuilder: (_, j) {
                          final b = borrowHistory[j];
                          final isBorrowed = b.status == 'borrowed';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isBorrowed
                                  ? Icons.book_online
                                  : Icons.check_circle_outline,
                              color: isBorrowed
                                  ? const Color(0xFF1565C0)
                                  : Colors.green,
                            ),
                            title: Text(
                              b.bookTitle.isNotEmpty ? b.bookTitle : b.bookId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              b.borrowDate,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
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
                                  color: isBorrowed
                                      ? const Color(0xFF1565C0)
                                      : Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String id;
  final String name;
  final String email;
  final int activeLoans;
  final int returnedBooks;
  final VoidCallback onDetail;

  const _MemberCard({
    required this.id,
    required this.name,
    required this.email,
    required this.activeLoans,
    required this.returnedBooks,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFE8F0FE),
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1A237E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                _badge('$activeLoans Active', Colors.blue),
                const SizedBox(width: 6),
                _badge('$returnedBooks Returned', Colors.green),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline, color: Color(0xFF1565C0)),
          onPressed: onDetail,
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
