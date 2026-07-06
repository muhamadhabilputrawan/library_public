import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/book_model.dart';
import 'api_service.dart';

/// BookService — menggunakan Gutendex API (gutendex.com)
/// ✅ CORS enabled (web + mobile)
/// ✅ Gratis, tanpa API key
class BookService {
  static const _headers = {'Accept': 'application/json'};

  // ─── GET BOOKS (buku populer default) ────────────────────────────────────
  Future<List<BookModel>> getBooks() async {
    // Ambil buku populer berdasarkan download count tertinggi
    final url = Uri.parse(
      '${ApiService.baseUrl}/books'
      '?sort=popular'
      '&page=1',
    );

    final response = await _get(url);
    return _parseResults(response.body);
  }

  // ─── SEARCH BOOKS ─────────────────────────────────────────────────────────
  Future<List<BookModel>> searchBooks(String keyword) async {
    final encoded = Uri.encodeComponent(keyword);
    final url = Uri.parse(
      '${ApiService.baseUrl}/books'
      '?search=$encoded'
      '&sort=popular',
    );

    final response = await _get(url);
    final results = _parseResults(response.body);
    if (results.isEmpty) throw Exception('Buku "$keyword" tidak ditemukan');
    return results;
  }

  // ─── GET BOOK DETAIL ──────────────────────────────────────────────────────
  Future<BookModel> getBookDetail(String id) async {
    final url = Uri.parse('${ApiService.baseUrl}/books/$id');
    final response = await _get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return BookModel.fromJson(data);
  }

  // ─── GET BOOKS BY TOPIC/GENRE ─────────────────────────────────────────────
  Future<List<BookModel>> getBooksBySubject(String subject) async {
    final encoded = Uri.encodeComponent(subject);
    final url = Uri.parse(
      '${ApiService.baseUrl}/books'
      '?topic=$encoded'
      '&sort=popular',
    );

    final response = await _get(url);
    final results = _parseResults(response.body);
    if (results.isEmpty) {
      throw Exception('Tidak ada buku untuk "$subject"');
    }
    return results;
  }

  // ─── PARSE RESULTS ────────────────────────────────────────────────────────
  List<BookModel> _parseResults(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final List results = data['results'] ?? [];
    return results
        .map((d) => BookModel.fromJson(d as Map<String, dynamic>))
        .where((b) => b.title.isNotEmpty && b.id.isNotEmpty)
        .toList();
  }

  // ─── HTTP helper dengan response code handling ───────────────────────────
  Future<http.Response> _get(Uri url) async {
    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 20));

      switch (response.statusCode) {
        case 200:
          return response;
        case 401:
          throw Exception('Unauthorized (401): Silakan login ulang.');
        case 403:
          throw Exception('Forbidden (403): Akses ditolak.');
        case 404:
          throw Exception('Data tidak ditemukan (404).');
        case 429:
          throw Exception(
            'Terlalu banyak permintaan (429). Coba lagi sebentar.',
          );
        case 500:
          throw Exception('Server error (500). Coba lagi nanti.');
        case 503:
          throw Exception('Server tidak tersedia (503).');
        default:
          throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          );
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on Exception {
      rethrow;
    }
  }
}
