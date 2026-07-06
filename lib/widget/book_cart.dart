import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onBorrow;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onBorrow, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: book.thumbnail.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book.thumbnail,
                        width: 76,
                        height: 108,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => _placeholderCover(),
                        errorWidget: (ctx, url, err) => _placeholderCover(),
                      )
                    : _placeholderCover(),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Author
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          book.rating > 0
                              ? book.rating.toStringAsFixed(1)
                              : 'N/A',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF37474F),
                          ),
                        ),
                        if (book.ratingCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${book.ratingCountLabel})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Genre chip + Borrow button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            book.genre,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: onBorrow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Borrow',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      width: 76,
      height: 108,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFF1565C0),
        size: 32,
      ),
    );
  }
}
