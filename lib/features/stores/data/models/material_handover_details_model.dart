import '../../domain/entities/material_handover_details.dart';
import 'material_handover_item_model.dart';
import 'material_handover_model.dart';

class MaterialHandoverDetailsModel extends MaterialHandoverDetails {
  const MaterialHandoverDetailsModel({
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
    required super.items,
    required super.returnOptions,
    required super.notes,
  });

  factory MaterialHandoverDetailsModel.fromJson(Map<String, dynamic> json) {
    final base = MaterialHandoverModel.fromJson(json);
    return MaterialHandoverDetailsModel(
      name: base.name,
      status: base.status,
      stockEntry: base.stockEntry,
      receiverUser: base.receiverUser,
      project: base.project,
      task: base.task,
      company: base.company,
      fromWarehouse: base.fromWarehouse,
      toWarehouse: base.toWarehouse,
      pickupOn: base.pickupOn,
      deliveryOn: base.deliveryOn,
      lastReturnStockEntry: base.lastReturnStockEntry,
      modified: base.modified,
      canConfirmPickup: base.canConfirmPickup,
      canConfirmDelivery: base.canConfirmDelivery,
      canCreateReturn: base.canCreateReturn,
      items: _list(json['items'])
          .whereType<Map<String, dynamic>>()
          .map(MaterialHandoverItemModel.fromJson)
          .toList(),
      returnOptions: _returnOptionItems(json)
          .whereType<Map<String, dynamic>>()
          .map(MaterialHandoverItemModel.fromJson)
          .toList(),
      notes: json['notes']?.toString() ?? '',
    );
  }
}

List<dynamic> _returnOptionItems(Map<String, dynamic> json) {
  final direct = json['return_options'];
  if (direct is Map<String, dynamic>) return _list(direct['items']);
  if (direct is List) return direct;
  return _list(json['return_items']);
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];
