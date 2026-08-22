class MaterialHandover {
  final String name;
  final String status;
  final String stockEntry;
  final String receiverUser;
  final String project;
  final String task;
  final String company;
  final String fromWarehouse;
  final String toWarehouse;
  final String pickupOn;
  final String deliveryOn;
  final String lastReturnStockEntry;
  final String modified;
  final bool canConfirmPickup;
  final bool canConfirmDelivery;
  final bool canCreateReturn;

  const MaterialHandover({
    required this.name,
    required this.status,
    required this.stockEntry,
    required this.receiverUser,
    required this.project,
    required this.task,
    required this.company,
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.pickupOn,
    required this.deliveryOn,
    required this.lastReturnStockEntry,
    required this.modified,
    required this.canConfirmPickup,
    required this.canConfirmDelivery,
    required this.canCreateReturn,
  });
}
