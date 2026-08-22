import '../entities/material_handover_location.dart';
import '../repositories/material_handover_repository.dart';

class ConfirmMaterialPickupUseCase {
  const ConfirmMaterialPickupUseCase(this._repository);

  final MaterialHandoverRepository _repository;

  Future<void> call({
    required String name,
    required String photoBase64,
    required String photoFilename,
    required MaterialHandoverLocation location,
    required String notes,
  }) {
    return _repository.confirmPickup(
      name: name,
      photoBase64: photoBase64,
      photoFilename: photoFilename,
      location: location,
      notes: notes,
    );
  }
}
