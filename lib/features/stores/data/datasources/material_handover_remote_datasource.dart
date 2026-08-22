import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/material_return_line.dart';
import '../models/material_handover_details_model.dart';
import '../models/material_handover_item_model.dart';
import '../models/material_handover_model.dart';

class MaterialHandoverRemoteDataSource {
  Future<List<MaterialHandoverModel>> getHandovers({
    String? status,
    required int start,
    required int limit,
  }) async {
    final uri = ApiConstants.uri(ApiConstants.materialTransferHandoversEndpoint)
        .replace(
          queryParameters: {
            'limit_start': '$start',
            'limit_page_length': '$limit',
            if (status != null && status.isNotEmpty && status != 'All')
              'status': status,
          },
        );

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.project(
      'material handovers response=${response.statusCode} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load handovers: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiError(decoded, 'Failed to load handovers');
    return _extractList(decoded)
        .whereType<Map<String, dynamic>>()
        .map(MaterialHandoverModel.fromJson)
        .toList();
  }

  Future<MaterialHandoverDetailsModel> getDetails(String name) async {
    final response = await _post(
      ApiConstants.materialTransferHandoverDetailsEndpoint,
      {'name': name},
    );
    return MaterialHandoverDetailsModel.fromJson(_extractMap(response));
  }

  Future<void> confirmPickup({
    required String name,
    required String photoBase64,
    required String photoFilename,
    required String notes,
  }) async {
    await _post(ApiConstants.confirmMaterialTransferPickupEndpoint, {
      'name': name,
      'photo_base64': _dataUri(photoBase64, photoFilename),
      'photo_filename': photoFilename,
      'notes': notes,
    });
  }

  Future<void> confirmDelivery({
    required String name,
    required String photoBase64,
    required String photoFilename,
    required String notes,
  }) async {
    await _post(ApiConstants.confirmMaterialTransferDeliveryEndpoint, {
      'name': name,
      'photo_base64': _dataUri(photoBase64, photoFilename),
      'photo_filename': photoFilename,
      'notes': notes,
    });
  }

  Future<List<MaterialHandoverItemModel>> getReturnOptions(String name) async {
    final decoded = await _post(
      ApiConstants.materialTransferReturnOptionsEndpoint,
      {'name': name},
    );
    final map = _extractMap(decoded);
    final items = map['items'];
    final List<dynamic> raw = items is List ? items : _extractList(map);
    return raw
        .whereType<Map>()
        .map((item) => MaterialHandoverItemModel.fromJson(_safeMap(item)))
        .toList();
  }

  Future<String> createReturn({
    required String name,
    required List<MaterialReturnLine> items,
    required String photoBase64,
    required String photoFilename,
    required String notes,
  }) async {
    final decoded = await _post(
      ApiConstants.createMaterialTransferReturnEndpoint,
      {
        'name': name,
        'items': items
            .map(
              (item) => {
                'stock_entry_detail': item.stockEntryDetail,
                'qty': item.qty,
              },
            )
            .toList(),
        'photo_base64': _dataUri(photoBase64, photoFilename),
        'photo_filename': photoFilename,
        'notes': notes,
      },
    );
    final map = _extractMap(decoded);
    return _string(map, const [
      'request',
      'request_name',
      'return_request',
      'stock_entry',
      'stock_entry_name',
      'return_stock_entry',
      'draft_stock_entry',
      'name',
    ]);
  }

  Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      ApiConstants.uri(endpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode(body),
    );
    AppLogger.project(
      'material handover POST $endpoint response=${response.statusCode} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Material handover request failed: ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    _throwIfApiError(decoded, 'Material handover request failed');
    return decoded;
  }

  String _dataUri(String base64, String filename) {
    if (base64.startsWith('data:image/')) return base64;
    final mime = filename.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
    return 'data:$mime;base64,$base64';
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map<String, dynamic>) return const [];
    for (final key in const [
      'data',
      'message',
      'result',
      'items',
      'handovers',
      'results',
    ]) {
      final value = decoded[key];
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        final nested = _extractList(value);
        if (nested.isNotEmpty) return nested;
      }
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return <String, dynamic>{};
    for (final key in const ['data', 'message', 'result']) {
      final value = decoded[key];
      if (value is Map<String, dynamic>) {
        final nested = value['data'];
        if (nested is Map<String, dynamic>) return nested;
        return value;
      }
    }
    return decoded;
  }

  void _throwIfApiError(dynamic decoded, String fallback) {
    if (decoded is! Map<String, dynamic>) return;
    for (final candidate in [decoded, decoded['message'], decoded['data']]) {
      if (candidate is! Map<String, dynamic>) continue;
      final status = candidate['status']?.toString().toLowerCase();
      if (status == 'error') {
        throw Exception(candidate['message']?.toString() ?? fallback);
      }
    }
  }

  String _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return '';
  }

  Map<String, dynamic> _safeMap(Map item) {
    return item.map((key, value) => MapEntry(key.toString(), value));
  }

  String _preview(String body, {int max = 500}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}...';
  }
}
