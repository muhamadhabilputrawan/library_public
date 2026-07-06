import '../model/borrow_model.dart';

class BorrowService {
  final List<BorrowModel> _history = [];

  List<BorrowModel> getHistory() {
    return _history;
  }

  void borrowBook(BorrowModel borrow) {
    _history.add(borrow);
  }
}