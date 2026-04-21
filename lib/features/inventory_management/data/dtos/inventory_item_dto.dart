import 'package:mobile/features/inventory_management/domain/entities/inventory_item.dart';

class InventoryItemDto {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double minimumStock;
  final double costPerUnit;

  InventoryItemDto({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minimumStock,
    required this.costPerUnit,
  });

  factory InventoryItemDto.fromJson(Map<String, dynamic> json) {
    return InventoryItemDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Item',
      category: json['category'] ?? 'Other',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'units',
      minimumStock: (json['minimum_stock'] as num?)?.toDouble() ?? 0.0,
      costPerUnit: (json['cost_per_unit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  InventoryItem toEntity() {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      minimumStock: minimumStock,
      costPerUnit: costPerUnit,
    );
  }
}
