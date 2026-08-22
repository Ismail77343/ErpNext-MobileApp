import '../repositories/material_handover_repository.dart';

class ConfirmMaterialDeliveryUseCase {
  const ConfirmMaterialDeliveryUseCase(this._repository);

  final MaterialHandoverRepository _repository;

  Future<void> call({
    required String name,
    required String photoBase64,
    required String photoFilename,
    required String notes,
  }) {
    return _repository.confirmDelivery(
      name: name,
      photoBase64: photoBase64,
      photoFilename: photoFilename,
      notes: notes,
    );
  }
}
