import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/book_model.dart';

class BookCard extends StatelessWidget {

  final BookModel book;

  const BookCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin:
          const EdgeInsets.only(bottom: 15),

      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Padding(

        padding: const EdgeInsets.all(12),

        child: Row(

          children: [

            CachedNetworkImage(

              imageUrl: book.thumbnail,

              width: 80,

              height: 110,

              fit: BoxFit.cover,

              errorWidget:
                  (_, __, ___) => Container(

                width: 80,

                height: 110,

                color: Colors.grey.shade300,

                child: const Icon(Icons.book),

              ),
            ),

            const SizedBox(width: 15),

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    book.title,

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 17,

                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    book.author,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(

                    width: 110,

                    child: ElevatedButton(

                      onPressed: () {},

                      child: const Text(
                        "Borrow",
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}