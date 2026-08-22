import '../../domain/entities/material_handover_item.dart';

class MaterialHandoverItemModel extends MaterialHandoverItem {
  const MaterialHandoverItemModel({
    required super.stockEntryDetail,
    required super.itemCode,
    required super.itemName,
    required super.description,
    required super.uom,
    required super.qty,
    required super.returnedQty,
    required super.remainingQty,
    required super.sourceWarehouse,
    required super.targetWarehouse,
    required super.returnable,
  });

  factory MaterialHandoverItemModel.fromJson(Map<String, dynamic> json) {
    return MaterialHandoverItemModel(
      stockEntryDetail: _string(json, const ['stock_entry_detail', 'name']),
      itemCode: _string(json, const ['item_code']),
      itemName: _string(json, const ['item_name']),
      description: _string(json, const ['description']),
      uom: _string(json, const ['uom', 'stock_uom']),
      qty: _double(json, const ['qty', 'transfer_qty']),
      returnedQty: _double(json, const ['returned_qty']),
      remainingQty: _double(json, const ['remaining_qty']),
      sourceWarehouse: _string(json, const ['s_warehouse', 'from_warehouse']),
      targetWarehouse: _string(json, const ['t_warehouse', 'to_warehouse']),
      returnable: _bool(json, const ['returnable'], fallback: true),
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

double _double(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return 0;
}

bool _bool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;
  }
  return fallback;
}
