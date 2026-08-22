import '../entities/material_handover.dart';
import '../entities/material_handover_details.dart';
import '../entities/material_handover_item.dart';
import '../entities/material_handover_location.dart';
import '../entities/material_return_line.dart';

abstract class MaterialHandoverRepository {
  Future<List<MaterialHandover>> getHandovers({
    String? status,
    required int start,
    required int limit,
  });

  Future<MaterialHandoverDetails> getDetails(String name);

  Future<void> confirmPickup({
    required String name,
    required String photoBase64,
    required String photoFilename,
    required MaterialHandoverLocation location,
    required String notes,
  });

  Future<void> confirmDelivery({
    required String name,
    required String photoBase64,
    required String photoFilename,
    required MaterialHandoverLocation location,
    required String notes,
  });

  Future<List<MaterialHandoverItem>> getReturnOptions(String name);

  Future<String> createReturn({
    required String name,
    required List<MaterialReturnLine> items,
    required String photoBase64,
    required String photoFilename,
    required MaterialHandoverLocation location,
    required String notes,
  });
}
