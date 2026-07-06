import 'package:flutter/material.dart';

import '../model/rack_model.dart';
import '../service/rack_service.dart';

class RackProvider extends ChangeNotifier {
  final RackService _rackService = RackService();

  List<RackModel> _racks = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _selectedRackId = 0; // 0 = All

  List<RackModel> get racks => _racks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get selectedRackId => _selectedRackId;
  bool get isEmpty => _racks.isEmpty;

  RackModel? get selectedRack => _racks.isEmpty
      ? null
      : _racks.firstWhere(
          (r) => r.id == _selectedRackId,
          orElse: () => _racks.first,
        );

  Future<void> loadRacks() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _racks = await _rackService.getRacks();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRack(int id) {
    _selectedRackId = id;
    notifyListeners();
  }
}
