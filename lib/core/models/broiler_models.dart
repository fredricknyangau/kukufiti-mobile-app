import 'package:json_annotation/json_annotation.dart';

part 'broiler_models.g.dart';

@JsonSerializable()
class Batch {
  final String id;
  final String name;

  @JsonKey(name: 'start_date')
  final DateTime commencementDate;

  @JsonKey(name: 'initial_count')
  final int initialChicks;

  @JsonKey(name: 'cost_per_bird')
  final double costPerChick;

  @JsonKey(name: 'total_acquisition_cost')
  final double totalCost;

  final String status; // 'active' | 'completed' | 'sold' | 'culled'
  final String? notes;
  final String? breed;
  final String? supplier;
  final String? sourceLocation;

  Batch({
    required this.id,
    required this.name,
    required this.commencementDate,
    required this.initialChicks,
    required this.costPerChick,
    required this.totalCost,
    required this.status,
    this.notes,
    this.breed,
    this.supplier,
    this.sourceLocation,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);
  Map<String, dynamic> toJson() => _$BatchToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? location;
  final bool isActive;
  final bool isSuperuser;
  final String? role; // 'ADMIN' | 'MANAGER' | 'VIEWER' | 'FARMER'
  final dynamic preferences;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.location,
    required this.isActive,
    required this.isSuperuser,
    this.role,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MortalityRecord {
  final String id;

  @JsonKey(name: 'flock_id')
  final String batchId;
  @JsonKey(name: 'event_date')
  final DateTime date;
  final int count;
  final String? cause;
  final String? notes;
  @JsonKey(defaultValue: 'death')
  final String type; // 'death' | 'cull'

  MortalityRecord({
    required this.id,
    required this.batchId,
    required this.date,
    required this.count,
    this.cause,
    this.notes,
    required this.type,
  });

  factory MortalityRecord.fromJson(Map<String, dynamic> json) => _$MortalityRecordFromJson(json);
  Map<String, dynamic> toJson() => _$MortalityRecordToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Expenditure {
  final String id;

  @JsonKey(name: 'flock_id')
  final String? batchId;
  final DateTime date;
  final String category;
  final String description;
  final double amount;
  final double? quantity;
  final String? unit;
  final String? receiptImage;
  final String? mpesaTransactionId;
  final String? inventoryItemId;
  final String? supplierId;
  final bool? createInventoryItem;
  final String? newInventoryName;
  final String? newInventoryUnit;

  Expenditure({
    required this.id,
    this.batchId,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    this.quantity,
    this.unit,
    this.receiptImage,
    this.mpesaTransactionId,
    this.inventoryItemId,
    this.supplierId,
    this.createInventoryItem,
    this.newInventoryName,
    this.newInventoryUnit,
  });

  factory Expenditure.fromJson(Map<String, dynamic> json) => _$ExpenditureFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenditureToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class WeightRecord {
  final String id;

  @JsonKey(name: 'flock_id')
  final String batchId;
  @JsonKey(name: 'event_date')
  final DateTime date;

  @JsonKey(name: 'average_weight_grams')
  final double averageWeight;
  final int sampleSize;
  final String? notes;

  WeightRecord({
    required this.id,
    required this.batchId,
    required this.date,
    required this.averageWeight,
    required this.sampleSize,
    this.notes,
  });

  factory WeightRecord.fromJson(Map<String, dynamic> json) => _$WeightRecordFromJson(json);
  Map<String, dynamic> toJson() => _$WeightRecordToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VaccinationRecord {
  final String id;

  @JsonKey(name: 'flock_id')
  final String batchId;
  @JsonKey(name: 'event_date')
  final DateTime date;
  final String vaccineName;
  final String? dosage;
  final String administrationMethod;
  final double? cost;
  final String? notes;
  final DateTime? scheduledDate;
  @JsonKey(defaultValue: true)
  final bool completed;

  VaccinationRecord({
    required this.id,
    required this.batchId,
    required this.date,
    required this.vaccineName,
    this.dosage,
    required this.administrationMethod,
    this.cost,
    this.notes,
    this.scheduledDate,
    required this.completed,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) => _$VaccinationRecordFromJson(json);
  Map<String, dynamic> toJson() => _$VaccinationRecordToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SaleRecord {
  final String id;

  @JsonKey(name: 'flock_id')
  final String batchId;
  final DateTime date;
  final int quantity;
  final double? pricePerKg;
  final double pricePerBird;
  final double totalAmount;
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerLocation;
  final String? notes;
  final String? mpesaTransactionId;

  @JsonKey(name: 'average_weight_grams')
  final double? averageWeight;
  final String? customerId;

  SaleRecord({
    required this.id,
    required this.batchId,
    required this.date,
    required this.quantity,
    this.pricePerKg,
    required this.pricePerBird,
    required this.totalAmount,
    this.buyerName,
    this.buyerPhone,
    this.buyerLocation,
    this.notes,
    this.mpesaTransactionId,
    this.averageWeight,
    this.customerId,
  });

  factory SaleRecord.fromJson(Map<String, dynamic> json) => _$SaleRecordFromJson(json);
  Map<String, dynamic> toJson() => _$SaleRecordToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FeedRecord {
  final String id;

  @JsonKey(name: 'flock_id')
  final String batchId;
  @JsonKey(name: 'event_date')
  final DateTime date;
  final String feedType;
  @JsonKey(name: 'quantity_kg')
  final double quantity;
  @JsonKey(name: 'cost_ksh')
  final double? cost;
  final String? supplier;
  final String? notes;
  final bool? isHomemade;
  final List<FeedIngredient>? ingredients;

  FeedRecord({
    required this.id,
    required this.batchId,
    required this.date,
    required this.feedType,
    required this.quantity,
    this.cost,
    this.supplier,
    this.notes,
    this.isHomemade,
    this.ingredients,
  });

  factory FeedRecord.fromJson(Map<String, dynamic> json) => _$FeedRecordFromJson(json);
  Map<String, dynamic> toJson() => _$FeedRecordToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FeedIngredient {
  final String name;
  final double quantity;
  final double cost;
  final double? proteinContent;
  final double? energyContent;

  FeedIngredient({
    required this.name,
    required this.quantity,
    required this.cost,
    this.proteinContent,
    this.energyContent,
  });

  factory FeedIngredient.fromJson(Map<String, dynamic> json) => _$FeedIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$FeedIngredientToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double minimumStock;
  final double costPerUnit;
  final DateTime? lastRestocked;
  final String? notes;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minimumStock,
    required this.costPerUnit,
    this.lastRestocked,
    this.notes,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class InventoryHistoryRecord {
  final String id;
  final String inventoryItemId;
  final String userId;
  final DateTime date;
  final String action;
  final double quantityChange;
  final String? notes;
  final DateTime createdAt;

  InventoryHistoryRecord({
    required this.id,
    required this.inventoryItemId,
    required this.userId,
    required this.date,
    required this.action,
    required this.quantityChange,
    this.notes,
    required this.createdAt,
  });

  factory InventoryHistoryRecord.fromJson(Map<String, dynamic> json) => _$InventoryHistoryRecordFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryHistoryRecordToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BiosecurityCheck {
  final String id;
  final DateTime date;
  final List<BiosecurityItem> items;
  final String? notes;
  final String? completedBy;

  BiosecurityCheck({
    required this.id,
    required this.date,
    required this.items,
    this.notes,
    this.completedBy,
  });

  factory BiosecurityCheck.fromJson(Map<String, dynamic> json) => _$BiosecurityCheckFromJson(json);
  Map<String, dynamic> toJson() => _$BiosecurityCheckToJson(this);
}

@JsonSerializable()
class BiosecurityItem {
  final String task;
  final bool completed;
  final String? notes;

  BiosecurityItem({
    required this.task,
    required this.completed,
    this.notes,
  });

  factory BiosecurityItem.fromJson(Map<String, dynamic> json) => _$BiosecurityItemFromJson(json);
  Map<String, dynamic> toJson() => _$BiosecurityItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MarketPrice {
  final String id;
  @JsonKey(name: 'price_date')
  final DateTime date;
  final String county;
  final String? town;
  final String? item;
  final double pricePerKg;
  final double? pricePerBird;
  final String? status; // 'up' | 'down' | 'stable'
  final String? source;
  final String? notes;

  MarketPrice({
    required this.id,
    required this.date,
    required this.county,
    this.town,
    this.item,
    required this.pricePerKg,
    this.pricePerBird,
    this.status,
    this.source,
    this.notes,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) => _$MarketPriceFromJson(json);
  Map<String, dynamic> toJson() => _$MarketPriceToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VetConsultation {
  final String id;
  final DateTime date;

  @JsonKey(name: 'flock_id')
  final String? batchId;
  final String issue;
  final String? symptoms;
  final String? diagnosis;
  final String? treatment;
  final String? vetName;
  final String? vetPhone;
  final List<String>? images;
  final String status; // 'pending' | 'in_progress' | 'resolved'
  final String? notes;

  VetConsultation({
    required this.id,
    required this.date,
    this.batchId,
    required this.issue,
    this.symptoms,
    this.diagnosis,
    this.treatment,
    this.vetName,
    this.vetPhone,
    this.images,
    required this.status,
    this.notes,
  });

  factory VetConsultation.fromJson(Map<String, dynamic> json) => _$VetConsultationFromJson(json);
  Map<String, dynamic> toJson() => _$VetConsultationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BatchSummary {
  final Batch batch;
  final int totalMortality;
  final int currentChicks;
  final double totalExpenditure;
  final double mortalityRate;
  final int daysActive;
  final double totalSales;
  final int birdsSold;
  final int remainingBirds;
  final double? averageWeight;
  final double totalFeedConsumed;
  final double? fcr;
  final double totalVaccinationCost;
  final double profitLoss;

  BatchSummary({
    required this.batch,
    required this.totalMortality,
    required this.currentChicks,
    required this.totalExpenditure,
    required this.mortalityRate,
    required this.daysActive,
    required this.totalSales,
    required this.birdsSold,
    required this.remainingBirds,
    this.averageWeight,
    required this.totalFeedConsumed,
    this.fcr,
    required this.totalVaccinationCost,
    required this.profitLoss,
  });

  factory BatchSummary.fromJson(Map<String, dynamic> json) => _$BatchSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BatchSummaryToJson(this);
}
