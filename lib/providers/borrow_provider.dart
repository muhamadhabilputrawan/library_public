import 'package:flutter/material.dart';

import '../model/borrow_model.dart';
import '../service/borrow_service.dart';

class BorrowProvider extends ChangeNotifier {
  final BorrowService _borrowService = BorrowService();

  List<BorrowModel> _history = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<BorrowModel> get history => _history;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isEmpty => _history.isEmpty;

  /// History yang difilter berdasarkan memberId yang sedang login
  List<BorrowModel> historyByMember(String memberId) {
    if (memberId.isEmpty) return _history;
    return _history.where((b) => b.memberId == memberId).toList();
  }

  List<BorrowModel> get activeLoans =>
      _history.where((b) => b.status == 'borrowed').toList();

  List<BorrowModel> activeLoansByMember(String memberId) {
    return historyByMember(
      memberId,
    ).where((b) => b.status == 'borrowed').toList();
  }

  List<BorrowModel> get returnedBooks =>
      _history.where((b) => b.status == 'returned').toList();

  void loadHistory() {
    _history = _borrowService.getHistory();
    notifyListeners();
  }

  void borrowBook({
    required String bookId,
    required String memberId,
    required String bookTitle,
    required String bookAuthor,
    required String bookThumbnail,
  }) {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final now = DateTime.now();
      final borrow = BorrowModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        bookId: bookId,
        borrowDate:
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        status: 'borrowed',
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        bookThumbnail: bookThumbnail,
      );
      _borrowService.borrowBook(borrow);
      _history = _borrowService.getHistory();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isAlreadyBorrowed(String bookId) {
    return _history.any((b) => b.bookId == bookId && b.status == 'borrowed');
  }

  /// Return book — ubah status dari 'borrowed' ke 'returned'
  void returnBook(String borrowId) {
    final idx = _history.indexWhere((b) => b.id == borrowId);
    if (idx == -1) return;

    final old = _history[idx];
    _history[idx] = BorrowModel(
      id: old.id,
      memberId: old.memberId,
      bookId: old.bookId,
      borrowDate: old.borrowDate,
      status: 'returned',
      bookTitle: old.bookTitle,
      bookAuthor: old.bookAuthor,
      bookThumbnail: old.bookThumbnail,
    );
    notifyListeners();
  }
}
