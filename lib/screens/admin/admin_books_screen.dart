import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/book_provider.dart';
import '../../widget/error_widget.dart';
import '../../widget/loading_widget.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({super.key});

  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<BookProvider>().books.isEmpty) {
        context.read<BookProvider>().getBooks();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      color: Color(0xFF1565C0),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Book Catalog',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ),
                    Consumer<BookProvider>(
                      builder: (ctx, p, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${p.books.length} Books',
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (v) {
                      if (v.trim().isEmpty) {
                        context.read<BookProvider>().getBooks();
                      } else {
                        context.read<BookProvider>().searchBooks(v.trim());
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search books...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Book list
          Expanded(
            child: Consumer<BookProvider>(
              builder: (ctx, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Memuat katalog...');
                }
                if (provider.errorMessage.isNotEmpty) {
                  return AppErrorWidget(
                    message: provider.errorMessage,
                    onRetry: () => provider.getBooks(),
                  );
                }
                if (provider.isEmpty) {
                  return const Center(
                    child: Text(
                      'Buku tidak ditemukan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF1565C0),
                  onRefresh: () => provider.getBooks(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.books.length,
                    itemBuilder: (ctx, i) {
                      final book = provider.books[i];
                      return _AdminBookTile(
                        title: book.title,
                        author: book.author,
                        thumbnail: book.thumbnail,
                        genre: book.genre,
                        rating: book.rating,
                        publisher: book.publisher,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBookTile extends StatelessWidget {
  final String title;
  final String author;
  final String thumbnail;
  final String genre;
  final double rating;
  final String publisher;

  const _AdminBookTile({
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.genre,
    required this.rating,
    required this.publisher,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: thumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: thumbnail,
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, url, err) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    author,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : 'N/A',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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

  Widget _placeholder() {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFF1565C0),
        size: 22,
      ),
    );
  }
}
