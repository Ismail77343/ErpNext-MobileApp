import '../../domain/entities/material_handover.dart';
import '../../domain/entities/material_handover_details.dart';
import '../../domain/entities/material_handover_item.dart';
import '../../domain/entities/material_return_line.dart';
import '../../domain/repositories/material_handover_repository.dart';
import '../datasources/material_handover_remote_datasource.dart';

class MaterialHandoverRepositoryImpl implements MaterialHandoverRepository {
  const MaterialHandoverRepositoryImpl(this._remoteDataSource);

  final MaterialHandoverRemoteDataSource _remoteDataSource;

  @override
  Future<List<MaterialHandover>> getHandovers({
    String? status,
    required int start,
    required int limit,
  }) {
    return _remoteDataSource.getHandovers(
      status: status,
      start: start,
      limit: limit,
    );
  }

  @override
  Future<MaterialHandoverDetails> getDetails(String name) {
    return _remoteDataSource.getDetails(name);
  }

  @override
  Future<void> confirmPickup({
    required String name,
    required String photoBase64,
    required String photoFilename,
    required String notes,
  }) {
    return _remoteDataSource.confirmPickup(
      name: name,
      photoBase64: photoBase64,
      photoFilename: photoFilename,
      notes: notes,
    );
  }

  @override
  Future<void> confirmDelivery({
    required String name,
    required String photoBase64,
    required String photoFilename,
    required String notes,
  }) {
    return _remoteDataSource.confirmDelivery(
      name: name,
      photoBase64: photoBase64,
      photoFilename: photoFilename,
      notes: notes,
    );
  }

  @override
  Future<List<MaterialHandoverItem>> getReturnOptions(String name) {
    return _remoteDataSource.getReturnOptions(name);
  }

  @override
  Future<String> createReturn({
    required String name,
    required List<MaterialReturnLine> items,
    required String photoBase64,
    required String photoFilename,
    required String notes,
  }) {
    return _remoteDataSource.createReturn(
      name: name,
      items: items,
      photoBase64: photoBase64,
      photoFilename: photoFilename,
      notes: notes,
    );
  }
}
