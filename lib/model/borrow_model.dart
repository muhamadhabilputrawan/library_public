class BorrowModel {
  final String id;
  final String memberId;
  final String bookId;
  final String borrowDate;
  final String status;

  // Data buku yang disimpan saat borrow — agar history tidak perlu fetch ulang
  final String bookTitle;
  final String bookAuthor;
  final String bookThumbnail;

  BorrowModel({
    required this.id,
    required this.memberId,
    required this.bookId,
    required this.borrowDate,
    required this.status,
    this.bookTitle = '',
    this.bookAuthor = '',
    this.bookThumbnail = '',
  });

  factory BorrowModel.fromJson(Map<String, dynamic> json) {
    return BorrowModel(
      id: json['id'].toString(),
      memberId: json['memberId'] ?? '',
      bookId: json['bookId'] ?? '',
      borrowDate: json['borrowDate'] ?? '',
      status: json['status'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      bookAuthor: json['bookAuthor'] ?? '',
      bookThumbnail: json['bookThumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'bookId': bookId,
      'borrowDate': borrowDate,
      'status': status,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookThumbnail': bookThumbnail,
    };
  }
}
