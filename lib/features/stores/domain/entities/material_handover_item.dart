class MaterialHandoverItem {
  final String stockEntryDetail;
  final String itemCode;
  final String itemName;
  final String description;
  final String uom;
  final double qty;
  final double returnedQty;
  final double remainingQty;
  final String sourceWarehouse;
  final String targetWarehouse;
  final bool returnable;

  const MaterialHandoverItem({
    required this.stockEntryDetail,
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.uom,
    required this.qty,
    required this.returnedQty,
    required this.remainingQty,
    required this.sourceWarehouse,
    required this.targetWarehouse,
    required this.returnable,
  });
}
