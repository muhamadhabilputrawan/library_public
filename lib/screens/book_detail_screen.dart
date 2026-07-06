import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/book_model.dart';
import '../providers/auth_provider.dart';
import '../providers/borrow_provider.dart';
import '../service/book_service.dart';
import '../widget/error_widget.dart';
import '../widget/loading_widget.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookService _bookService = BookService();

  BookModel? _book;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final book = await _bookService.getBookDetail(widget.bookId);
      if (mounted) setState(() => _book = book);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleBorrow() {
    if (_book == null) return;
    final borrowProv = context.read<BorrowProvider>();
    final authProv = context.read<AuthProvider>();

    if (borrowProv.isAlreadyBorrowed(_book!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buku ini sudah dipinjam.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    borrowProv.borrowBook(
      bookId: _book!.id,
      memberId: authProv.userId,
      bookTitle: _book!.title,
      bookAuthor: _book!.author,
      bookThumbnail: _book!.thumbnail,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_book!.title} berhasil dipinjam!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const LoadingWidget(message: 'Memuat detail buku...'),
      );
    }
    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: AppErrorWidget(message: _error, onRetry: _loadDetail),
      );
    }

    return Consumer<BorrowProvider>(
      builder: (ctx, borrowProv, _) {
        final isBorrowed =
            _book != null && borrowProv.isAlreadyBorrowed(_book!.id);
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildDetail(),
          bottomNavigationBar: _book != null
              ? _BorrowBottomBar(
                  isBorrowed: isBorrowed,
                  onBorrow: _handleBorrow,
                )
              : null,
        );
      },
    );
  }

  Widget _buildDetail() {
    if (_book == null) return const SizedBox();
    final book = _book!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Color(0xFF1565C0),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Color(0xFF1565C0),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: book.thumbnail,
                  fit: BoxFit.cover,
                  color: Colors.black38,
                  colorBlendMode: BlendMode.darken,
                  errorWidget: (ctx, url, err) =>
                      Container(color: const Color(0xFF1A237E)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: book.thumbnail,
                        width: 140,
                        height: 200,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, url, err) => Container(
                          width: 140,
                          height: 200,
                          color: Colors.grey.shade400,
                          child: const Icon(
                            Icons.book,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.rating > 0
                                  ? book.rating.toStringAsFixed(1)
                                  : 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          book.ratingCount > 0
                              ? '${book.ratingCountLabel} Reviews'
                              : 'No Reviews',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'by ${book.author}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (book.pageCount > 0)
                      _buildTag(
                        Icons.menu_book_outlined,
                        '${book.pageCount} Pages',
                      ),
                    _buildTag(Icons.translate, book.language.toUpperCase()),
                    if (book.genre.isNotEmpty)
                      _buildTag(Icons.category_outlined, book.genre),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Synopsis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  book.description.isNotEmpty
                      ? book.description
                      : 'No description available.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF546E7A),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        'PUBLISHER',
                        book.publisher.isNotEmpty ? book.publisher : 'Unknown',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoTile(
                        'RELEASED',
                        book.publishedDate.isNotEmpty
                            ? book.publishedDate
                            : 'Unknown',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1565C0)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowBottomBar extends StatelessWidget {
  final bool isBorrowed;
  final VoidCallback onBorrow;

  const _BorrowBottomBar({required this.isBorrowed, required this.onBorrow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Status',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              Text(
                isBorrowed ? 'Already Borrowed' : 'Available Now',
                style: TextStyle(
                  color: isBorrowed ? Colors.orange : const Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isBorrowed ? null : onBorrow,
              icon: const Icon(Icons.book_outlined),
              label: Text(isBorrowed ? 'BORROWED' : 'BORROW'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
