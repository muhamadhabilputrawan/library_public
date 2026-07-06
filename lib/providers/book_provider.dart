import 'package:flutter/material.dart';

import '../model/book_model.dart';
import '../service/book_service.dart';

class BookProvider extends ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _books = [];

  bool _isLoading = false;

  String _errorMessage = "";

  List<BookModel> get books => _books;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  Future<void> getBooks() async {
    try {
      _isLoading = true;
      _errorMessage = "";

      notifyListeners();

      _books = await _bookService.getBooks();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> searchBooks(String keyword) async {
    try {
      _isLoading = true;
      _errorMessage = "";

      notifyListeners();

      _books = await _bookService.searchBooks(keyword);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  bool get isEmpty => _books.isEmpty;
}