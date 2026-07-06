class BorrowModel {
  final String id;
  final String memberId;
  final String bookId;
  final String borrowDate;
  final String status;

  BorrowModel({
    required this.id,
    required this.memberId,
    required this.bookId,
    required this.borrowDate,
    required this.status,
  });

  factory BorrowModel.fromJson(Map<String, dynamic> json) {
    return BorrowModel(
      id: json['id'].toString(),
      memberId: json['memberId'] ?? '',
      bookId: json['bookId'] ?? '',
      borrowDate: json['borrowDate'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'bookId': bookId,
      'borrowDate': borrowDate,
      'status': status,
    };
  }
}