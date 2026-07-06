class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String thumbnail;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.thumbnail,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    return BookModel(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? '',
      author: (volumeInfo['authors'] != null &&
              volumeInfo['authors'].isNotEmpty)
          ? volumeInfo['authors'][0]
          : 'Unknown',
      description: volumeInfo['description'] ?? '',
      thumbnail: imageLinks['thumbnail'] ?? '',
    );
  }
}