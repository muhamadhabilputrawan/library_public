import '../model/rack_model.dart';

/// RackService — daftar rak/kategori buku
/// Menggunakan topic dari Gutendex API sebagai representasi "rak" perpustakaan
class RackService {
  Future<List<RackModel>> getRacks() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Topic yang didukung Gutendex: ?topic=xxx
    return [
      RackModel(id: 0, name: 'All'),
      RackModel(id: 1, name: 'Fiction'),
      RackModel(id: 2, name: 'Science'),
      RackModel(id: 3, name: 'Philosophy'),
      RackModel(id: 4, name: 'Adventure'),
      RackModel(id: 5, name: 'History'),
      RackModel(id: 6, name: 'Mystery'),
      RackModel(id: 7, name: 'Romance'),
      RackModel(id: 8, name: 'Poetry'),
    ];
  }
}
