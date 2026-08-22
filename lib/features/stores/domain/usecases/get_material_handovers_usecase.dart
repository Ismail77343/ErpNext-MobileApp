import '../entities/material_handover.dart';
import '../repositories/material_handover_repository.dart';

class GetMaterialHandoversUseCase {
  const GetMaterialHandoversUseCase(this._repository);

  final MaterialHandoverRepository _repository;

  Future<List<MaterialHandover>> call({
    String? status,
    required int start,
    required int limit,
  }) {
    return _repository.getHandovers(status: status, start: start, limit: limit);
  }
}
