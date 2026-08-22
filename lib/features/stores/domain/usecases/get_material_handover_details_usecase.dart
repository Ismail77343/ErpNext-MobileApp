import '../entities/material_handover_details.dart';
import '../repositories/material_handover_repository.dart';

class GetMaterialHandoverDetailsUseCase {
  const GetMaterialHandoverDetailsUseCase(this._repository);

  final MaterialHandoverRepository _repository;

  Future<MaterialHandoverDetails> call(String name) {
    return _repository.getDetails(name);
  }
}
