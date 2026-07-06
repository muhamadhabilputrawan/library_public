import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/book_model.dart';
import 'api_service.dart';

class BookService {
  /// Ambil daftar buku
  Future<List<BookModel>> getBooks() async {
    final url =
        Uri.parse("${ApiService.baseUrl}/volumes?q=programming");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List items = data["items"] ?? [];

      return items
          .map((e) => BookModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Gagal mengambil data buku");
    }
  }

  /// Cari buku
  Future<List<BookModel>> searchBooks(String keyword) async {
    final url = Uri.parse(
      "${ApiService.baseUrl}/volumes?q=$keyword",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List items = data["items"] ?? [];

      return items
          .map((e) => BookModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Buku tidak ditemukan");
    }
  }

  /// Detail buku
  Future<BookModel> getBookDetail(String id) async {
    final url =
        Uri.parse("${ApiService.baseUrl}/volumes/$id");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return BookModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception("Detail buku gagal diambil");
    }
  }
}