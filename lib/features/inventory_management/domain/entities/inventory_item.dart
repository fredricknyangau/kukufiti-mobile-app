class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double minimumStock;
  final double costPerUnit;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minimumStock,
    required this.costPerUnit,
  });

  String get status => quantity <= minimumStock ? 'Low Stock' : 'In Stock';
}
