import '../entities/material_return_line.dart';
import '../repositories/material_handover_repository.dart';

class CreateMaterialReturnUseCase {
  const CreateMaterialReturnUseCase(this._repository);

  final MaterialHandoverRepository _repository;

  Future<String> call({
    required String name,
    required List<MaterialReturnLine> items,
    required String photoBase64,
    required String photoFilename,
    required String notes,
  }) {
    return _repository.createReturn(
      name: name,
      items: items,
      photoBase64: photoBase64,
      photoFilename: photoFilename,
      notes: notes,
    );
  }
}
