class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String thumbnail;
  final double rating;
  final int ratingCount;
  final int pageCount;
  final String publisher;
  final String publishedDate;
  final List<String> categories;
  final String language;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.thumbnail,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.pageCount = 0,
    this.publisher = '',
    this.publishedDate = '',
    this.categories = const [],
    this.language = 'en',
  });

  /// Genre pertama dari categories
  String get genre => categories.isNotEmpty ? categories.first : 'General';

  /// Rating count ringkas: 1200 → 1.2k
  String get ratingCountLabel {
    if (ratingCount >= 1000) {
      return '${(ratingCount / 1000).toStringAsFixed(1)}k';
    }
    return '$ratingCount';
  }

  /// Parse dari Gutendex API response
  /// Endpoint: GET /books  atau  GET /books/{id}
  factory BookModel.fromJson(Map<String, dynamic> json) {
    // Authors: list of {name, birth_year, death_year}
    final List authors = json['authors'] ?? [];
    final String author = authors.isNotEmpty
        ? authors.first['name']?.toString() ?? 'Unknown Author'
        : 'Unknown Author';

    // Cover image dari formats
    final Map formats = json['formats'] ?? {};
    String thumbnail = formats['image/jpeg'] ?? '';

    // Subjects sebagai categories
    final List subjects = json['subjects'] ?? [];
    final List<String> cats = subjects
        .take(3)
        .map((s) => _toTitleCase(s.toString().split(' -- ').first))
        .toList();

    // Bookshelves sebagai fallback categories
    if (cats.isEmpty) {
      final List shelves = json['bookshelves'] ?? [];
      cats.addAll(shelves.take(2).map((s) => _toTitleCase(s.toString())));
    }

    // Language
    final List langs = json['languages'] ?? [];
    final String lang = langs.isNotEmpty ? langs.first.toString() : 'en';

    // Download count sebagai proxy popularity
    final int downloads = (json['download_count'] ?? 0).toInt();

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'No Title',
      author: author,
      description: '',
      thumbnail: thumbnail,
      rating: _downloadToRating(downloads),
      ratingCount: downloads,
      pageCount: 0,
      publisher: 'Project Gutenberg',
      publishedDate: json['copyright'] == false ? 'Public Domain' : '',
      categories: cats,
      language: lang,
    );
  }

  /// Konversi download count → rating 1-5
  static double _downloadToRating(int downloads) {
    if (downloads <= 0) return 0;
    if (downloads >= 10000) return 5.0;
    if (downloads >= 5000) return 4.5;
    if (downloads >= 2000) return 4.0;
    if (downloads >= 500) return 3.5;
    return 3.0;
  }

  static String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'thumbnail': thumbnail,
      'rating': rating,
      'ratingCount': ratingCount,
      'pageCount': pageCount,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'categories': categories,
      'language': language,
    };
  }
}
