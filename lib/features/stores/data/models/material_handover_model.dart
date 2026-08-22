import '../../domain/entities/material_handover.dart';

class MaterialHandoverModel extends MaterialHandover {
  const MaterialHandoverModel({
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
  });

  factory MaterialHandoverModel.fromJson(Map<String, dynamic> json) {
    return MaterialHandoverModel(
      name: _string(json, const ['name', 'id']),
      status: _string(json, const ['status', 'handover_status']),
      stockEntry: _string(json, const ['stock_entry', 'stock_entry_name']),
      receiverUser: _string(json, const ['receiver_user']),
      project: _string(json, const ['project']),
      task: _string(json, const ['task']),
      company: _string(json, const ['company']),
      fromWarehouse: _string(json, const ['from_warehouse', 's_warehouse']),
      toWarehouse: _string(json, const ['to_warehouse', 't_warehouse']),
      pickupOn: _string(json, const ['pickup_on', 'mobile_pickup_on']),
      deliveryOn: _string(json, const ['delivery_on', 'mobile_delivery_on']),
      lastReturnStockEntry: _string(json, const [
        'last_return_stock_entry',
        'mobile_last_return_stock_entry',
      ]),
      modified: _string(json, const ['modified', 'creation']),
      canConfirmPickup: _bool(json, const ['can_confirm_pickup']),
      canConfirmDelivery: _bool(json, const ['can_confirm_delivery']),
      canCreateReturn: _bool(json, const ['can_create_return']),
    );
  }
}

String _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return '';
}

bool _bool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    if (text == 'true' || text == '1' || text == 'yes') return true;
  }
  return false;
}
