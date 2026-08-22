import 'package:flutter/material.dart';

import '../../../../core/utils/app_logger.dart';
import '../../data/services/material_handover_location_service.dart';
import '../../data/services/material_handover_photo_service.dart';
import '../../domain/entities/material_handover_location.dart';
import '../../domain/entities/material_handover.dart';
import '../../domain/entities/material_handover_details.dart';
import '../../domain/entities/material_handover_item.dart';
import '../../domain/entities/material_return_line.dart';
import '../../domain/usecases/confirm_material_delivery_usecase.dart';
import '../../domain/usecases/confirm_material_pickup_usecase.dart';
import '../../domain/usecases/create_material_return_usecase.dart';
import '../../domain/usecases/get_material_handover_details_usecase.dart';
import '../../domain/usecases/get_material_handovers_usecase.dart';
import '../../domain/usecases/get_material_return_options_usecase.dart';

class MaterialHandoversProvider extends ChangeNotifier {
  MaterialHandoversProvider({
    required GetMaterialHandoversUseCase getHandoversUseCase,
    required GetMaterialHandoverDetailsUseCase getDetailsUseCase,
    required ConfirmMaterialPickupUseCase confirmPickupUseCase,
    required ConfirmMaterialDeliveryUseCase confirmDeliveryUseCase,
    required GetMaterialReturnOptionsUseCase getReturnOptionsUseCase,
    required CreateMaterialReturnUseCase createReturnUseCase,
    required MaterialHandoverPhotoService photoService,
    required MaterialHandoverLocationService locationService,
  }) : _getHandoversUseCase = getHandoversUseCase,
       _getDetailsUseCase = getDetailsUseCase,
       _confirmPickupUseCase = confirmPickupUseCase,
       _confirmDeliveryUseCase = confirmDeliveryUseCase,
       _getReturnOptionsUseCase = getReturnOptionsUseCase,
       _createReturnUseCase = createReturnUseCase,
       _photoService = photoService,
       _locationService = locationService;

  final GetMaterialHandoversUseCase _getHandoversUseCase;
  final GetMaterialHandoverDetailsUseCase _getDetailsUseCase;
  final ConfirmMaterialPickupUseCase _confirmPickupUseCase;
  final ConfirmMaterialDeliveryUseCase _confirmDeliveryUseCase;
  final GetMaterialReturnOptionsUseCase _getReturnOptionsUseCase;
  final CreateMaterialReturnUseCase _createReturnUseCase;
  final MaterialHandoverPhotoService _photoService;
  final MaterialHandoverLocationService _locationService;

  static const int _pageSize = 20;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isProcessing = false;
  bool _hasMore = true;
  int _nextStart = 0;
  String _statusFilter = 'All';
  String? _error;
  List<MaterialHandover> _handovers = [];
  MaterialHandoverDetails? _details;
  List<MaterialHandoverItem> _returnOptions = [];
  String? _lastReturnDraft;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isProcessing => _isProcessing;
  bool get hasMore => _hasMore;
  bool get canLoadMore => !_isLoading && !_isLoadingMore && _hasMore;
  String get statusFilter => _statusFilter;
  String? get error => _error;
  List<MaterialHandover> get handovers => _handovers;
  MaterialHandoverDetails? get details => _details;
  List<MaterialHandoverItem> get returnOptions => _returnOptions;
  String? get lastReturnDraft => _lastReturnDraft;

  Future<void> fetch({bool refresh = false}) async {
    if (_isLoading || _isLoadingMore) return;
    if (!refresh && !_hasMore) return;
    if (refresh) {
      _isLoading = true;
      _nextStart = 0;
      _hasMore = true;
      _handovers = [];
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();
    try {
      final batch = await _getHandoversUseCase.call(
        status: _statusFilter == 'All' ? null : _statusFilter,
        start: _nextStart,
        limit: _pageSize,
      );
      final existing = _handovers.map((item) => item.name).toSet();
      _handovers = [
        ..._handovers,
        ...batch.where((item) => !existing.contains(item.name)),
      ];
      _nextStart += batch.length;
      _hasMore = batch.length == _pageSize;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('material handovers fetch failed: $_error');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetch(refresh: true);

  void setStatusFilter(String value) {
    if (_statusFilter == value) return;
    _statusFilter = value;
    refresh();
  }

  Future<void> loadDetails(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _details = await _getDetailsUseCase.call(name);
    } catch (e) {
      _error = e.toString();
      AppLogger.error('material handover details failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmPickup(String notes) {
    return _confirmAction(
      action: 'pickup',
      runner: (photo) => _confirmPickupUseCase.call(
        name: _details!.name,
        photoBase64: photo.base64,
        photoFilename: photo.filename,
        location: photo.location,
        notes: notes,
      ),
    );
  }

  Future<bool> confirmDelivery(String notes) {
    return _confirmAction(
      action: 'delivery',
      runner: (photo) => _confirmDeliveryUseCase.call(
        name: _details!.name,
        photoBase64: photo.base64,
        photoFilename: photo.filename,
        location: photo.location,
        notes: notes,
      ),
    );
  }

  Future<bool> _confirmAction({
    required String action,
    required Future<void> Function(_MaterialHandoverEvidence evidence) runner,
  }) async {
    if (_details == null) return false;
    _isProcessing = true;
    _error = null;
    notifyListeners();
    try {
      final photo = await _photoService.captureEvidence(action: action);
      final location = await _locationService.getCurrentLocation();
      await runner(
        _MaterialHandoverEvidence(
          base64: photo.base64,
          filename: photo.filename,
          location: location,
        ),
      );
      await loadDetails(_details!.name);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('material handover $action failed: $_error');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> loadReturnOptions(String name) async {
    _isLoading = true;
    _error = null;
    _returnOptions = [];
    _lastReturnDraft = null;
    notifyListeners();
    try {
      final options = await _getReturnOptionsUseCase.call(name);
      _returnOptions = options
          .where((item) => item.returnable && item.remainingQty > 0)
          .toList();
    } catch (e) {
      _error = e.toString();
      AppLogger.error('material return options failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReturn({
    required List<MaterialReturnLine> items,
    required String notes,
  }) async {
    final current = _details;
    if (current == null) return false;
    _isProcessing = true;
    _error = null;
    _lastReturnDraft = null;
    notifyListeners();
    try {
      final photo = await _photoService.captureEvidence(action: 'return');
      final location = await _locationService.getCurrentLocation();
      _lastReturnDraft = await _createReturnUseCase.call(
        name: current.name,
        items: items,
        photoBase64: photo.base64,
        photoFilename: photo.filename,
        location: location,
        notes: notes,
      );
      await loadDetails(current.name);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('material return failed: $_error');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}

class _MaterialHandoverEvidence {
  const _MaterialHandoverEvidence({
    required this.base64,
    required this.filename,
    required this.location,
  });

  final String base64;
  final String filename;
  final MaterialHandoverLocation location;
}
