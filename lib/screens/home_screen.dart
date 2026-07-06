import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../providers/borrow_provider.dart';
import '../providers/rack_provider.dart';
import '../widget/book_cart.dart';
import '../widget/error_widget.dart';
import '../widget/loading_widget.dart';
import 'book_detail_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load rak dari API terlebih dahulu, lalu load buku
      context.read<RackProvider>().loadRacks();
      context.read<BookProvider>().getBooks();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (value.trim().isEmpty) {
      context.read<BookProvider>().getBooks();
    } else {
      context.read<BookProvider>().searchBooks(value.trim());
    }
  }

  void _onRackTap(int rackId, String rackName) {
    context.read<RackProvider>().selectRack(rackId);
    if (rackName == 'All') {
      context.read<BookProvider>().getBooks();
    } else {
      context.read<BookProvider>().searchBooks(rackName.toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const HistoryScreen(isEmbedded: true),
      const ProfileScreen(isEmbedded: true),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          _buildSearchBar(),
          _buildRackFilter(), // ← dari RackProvider (API)
          Expanded(child: _buildBookList()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Color(0xFF1565C0)),
          const SizedBox(width: 12),
          const Text(
            'Lumina Library',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _selectedIndex = 2),
            child: Consumer<AuthProvider>(
              builder: (ctx, auth, _) {
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1565C0),
                  child: Text(
                    auth.userName.isNotEmpty
                        ? auth.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onSubmitted: _onSearch,
          decoration: InputDecoration(
            hintText: 'Search books, authors, or genres...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: const Icon(Icons.mic_none, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  /// Filter rak — data dinamis dari RackProvider (API)
  Widget _buildRackFilter() {
    return Consumer<RackProvider>(
      builder: (ctx, rackProv, _) {
        if (rackProv.isLoading) {
          return const SizedBox(
            height: 52,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
          );
        }

        if (rackProv.racks.isEmpty) return const SizedBox(height: 8);

        return SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            itemCount: rackProv.racks.length,
            itemBuilder: (ctx, i) {
              final rack = rackProv.racks[i];
              final isSelected = rackProv.selectedRackId == rack.id;
              return GestureDetector(
                onTap: () => _onRackTap(rack.id, rack.name),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1565C0)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    rack.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBookList() {
    return Consumer<BookProvider>(
      builder: (ctx, provider, _) {
        if (provider.isLoading) {
          return const LoadingWidget(message: 'Memuat buku...');
        }

        if (provider.errorMessage.isNotEmpty) {
          return AppErrorWidget(
            message: provider.errorMessage,
            onRetry: () => provider.getBooks(),
          );
        }

        if (provider.isEmpty) {
          return _EmptyBooks();
        }

        final books = provider.books;

        return RefreshIndicator(
          color: const Color(0xFF1565C0),
          onRefresh: () => provider.getBooks(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(
                    children: [
                      const Text(
                        'Featured Books',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${books.length} books',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final book = books[i];
                    return BookCard(
                      book: book,
                      onTap: () {
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(bookId: book.id),
                          ),
                        );
                      },
                      onBorrow: () {
                        final borrowProv = context.read<BorrowProvider>();
                        final authProv = context.read<AuthProvider>();
                        if (borrowProv.isAlreadyBorrowed(book.id)) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Buku ini sudah dipinjam.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        borrowProv.borrowBook(
                          bookId: book.id,
                          memberId: authProv.userId,
                          bookTitle: book.title,
                          bookAuthor: book.author,
                          bookThumbnail: book.thumbnail,
                        );
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('${book.title} berhasil dipinjam!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    );
                  }, childCount: books.length),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyBooks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Buku tidak ditemukan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
