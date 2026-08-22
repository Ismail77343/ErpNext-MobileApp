import 'material_handover.dart';
import 'material_handover_item.dart';

class MaterialHandoverDetails extends MaterialHandover {
  final List<MaterialHandoverItem> items;
  final List<MaterialHandoverItem> returnOptions;
  final String notes;

  const MaterialHandoverDetails({
    required super.name,
    required super.status,
    required super.stockEntry,
    required super.receiverUser,
    required super.project,
    required super.task,
    required super.company,
    required super.fromWarehouse,
    required super.toWarehouse,
    required super.pickupOn,
    required super.deliveryOn,
    required super.lastReturnStockEntry,
    required super.modified,
    required super.canConfirmPickup,
    required super.canConfirmDelivery,
    required super.canCreateReturn,
    required this.items,
    required this.returnOptions,
    required this.notes,
  });
}
