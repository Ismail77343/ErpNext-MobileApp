import '../entities/material_handover_item.dart';
import '../repositories/material_handover_repository.dart';

class GetMaterialReturnOptionsUseCase {
  const GetMaterialReturnOptionsUseCase(this._repository);

  final MaterialHandoverRepository _repository;

  Future<List<MaterialHandoverItem>> call(String name) {
    return _repository.getReturnOptions(name);
  }
}
