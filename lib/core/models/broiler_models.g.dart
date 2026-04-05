// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broiler_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Batch _$BatchFromJson(Map<String, dynamic> json) => Batch(
  id: json['id'] as String,
  name: json['name'] as String,
  commencementDate: DateTime.parse(json['start_date'] as String),
  initialChicks: (json['initial_count'] as num).toInt(),
  costPerChick: (json['cost_per_bird'] as num).toDouble(),
  totalCost: (json['total_acquisition_cost'] as num).toDouble(),
  status: json['status'] as String,
  notes: json['notes'] as String?,
  breed: json['breed'] as String?,
  supplier: json['supplier'] as String?,
  sourceLocation: json['source_location'] as String?,
  hatcherySource: json['hatchery_source'] as String?,
  expectedEndDate: json['expected_end_date'] == null
      ? null
      : DateTime.parse(json['expected_end_date'] as String),
  farmId: json['farm_id'] as String?,
);

Map<String, dynamic> _$BatchToJson(Batch instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'start_date': instance.commencementDate.toIso8601String(),
  'initial_count': instance.initialChicks,
  'cost_per_bird': instance.costPerChick,
  'total_acquisition_cost': instance.totalCost,
  'status': instance.status,
  'notes': instance.notes,
  'breed': instance.breed,
  'supplier': instance.supplier,
  'source_location': instance.sourceLocation,
  'hatchery_source': instance.hatcherySource,
  'expected_end_date': instance.expectedEndDate?.toIso8601String(),
  'farm_id': instance.farmId,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String?,
  fullName: json['full_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  location: json['location'] as String?,
  isActive: json['is_active'] as bool,
  isSuperuser: json['is_superuser'] as bool,
  role: json['role'] as String?,
  preferences: json['preferences'],
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.fullName,
  'phone_number': instance.phoneNumber,
  'location': instance.location,
  'is_active': instance.isActive,
  'is_superuser': instance.isSuperuser,
  'role': instance.role,
  'preferences': instance.preferences,
};

MortalityRecord _$MortalityRecordFromJson(Map<String, dynamic> json) =>
    MortalityRecord(
      id: json['id'] as String,
      batchId: json['flock_id'] as String,
      date: DateTime.parse(json['event_date'] as String),
      count: (json['count'] as num).toInt(),
      cause: json['cause'] as String?,
      symptoms: json['symptoms'] as String?,
      actionTaken: json['action_taken'] as String?,
      notes: json['notes'] as String?,
      type: json['type'] as String? ?? 'death',
    );

Map<String, dynamic> _$MortalityRecordToJson(MortalityRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flock_id': instance.batchId,
      'event_date': instance.date.toIso8601String(),
      'count': instance.count,
      'cause': instance.cause,
      'symptoms': instance.symptoms,
      'action_taken': instance.actionTaken,
      'notes': instance.notes,
      'type': instance.type,
    };

Expenditure _$ExpenditureFromJson(Map<String, dynamic> json) => Expenditure(
  id: json['id'] as String,
  batchId: json['flock_id'] as String?,
  date: DateTime.parse(json['date'] as String),
  category: json['category'] as String,
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
  receiptImage: json['receipt_image'] as String?,
  mpesaTransactionId: json['mpesa_transaction_id'] as String?,
  inventoryItemId: json['inventory_item_id'] as String?,
  supplierId: json['supplier_id'] as String?,
  createInventoryItem: json['create_inventory_item'] as bool?,
  newInventoryName: json['new_inventory_name'] as String?,
  newInventoryUnit: json['new_inventory_unit'] as String?,
);

Map<String, dynamic> _$ExpenditureToJson(Expenditure instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flock_id': instance.batchId,
      'date': instance.date.toIso8601String(),
      'category': instance.category,
      'description': instance.description,
      'amount': instance.amount,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'receipt_image': instance.receiptImage,
      'mpesa_transaction_id': instance.mpesaTransactionId,
      'inventory_item_id': instance.inventoryItemId,
      'supplier_id': instance.supplierId,
      'create_inventory_item': instance.createInventoryItem,
      'new_inventory_name': instance.newInventoryName,
      'new_inventory_unit': instance.newInventoryUnit,
    };

WeightRecord _$WeightRecordFromJson(Map<String, dynamic> json) => WeightRecord(
  id: json['id'] as String,
  batchId: json['flock_id'] as String,
  date: DateTime.parse(json['event_date'] as String),
  averageWeight: (json['average_weight_grams'] as num).toDouble(),
  sampleSize: (json['sample_size'] as num).toInt(),
  minWeightGrams: (json['min_weight_grams'] as num?)?.toDouble(),
  maxWeightGrams: (json['max_weight_grams'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$WeightRecordToJson(WeightRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flock_id': instance.batchId,
      'event_date': instance.date.toIso8601String(),
      'average_weight_grams': instance.averageWeight,
      'sample_size': instance.sampleSize,
      'min_weight_grams': instance.minWeightGrams,
      'max_weight_grams': instance.maxWeightGrams,
      'notes': instance.notes,
    };

VaccinationRecord _$VaccinationRecordFromJson(Map<String, dynamic> json) =>
    VaccinationRecord(
      id: json['id'] as String,
      batchId: json['flock_id'] as String,
      date: DateTime.parse(json['event_date'] as String),
      vaccineName: json['vaccine_name'] as String,
      diseaseTarget: json['disease_target'] as String?,
      dosage: json['dosage'] as String?,
      administrationMethod: json['administration_method'] as String,
      administeredBy: json['administered_by'] as String?,
      batchNumber: json['batch_number'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      scheduledDate: json['scheduled_date'] == null
          ? null
          : DateTime.parse(json['scheduled_date'] as String),
      completed: json['completed'] as bool? ?? true,
    );

Map<String, dynamic> _$VaccinationRecordToJson(VaccinationRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flock_id': instance.batchId,
      'event_date': instance.date.toIso8601String(),
      'vaccine_name': instance.vaccineName,
      'disease_target': instance.diseaseTarget,
      'dosage': instance.dosage,
      'administration_method': instance.administrationMethod,
      'administered_by': instance.administeredBy,
      'batch_number': instance.batchNumber,
      'cost': instance.cost,
      'notes': instance.notes,
      'scheduled_date': instance.scheduledDate?.toIso8601String(),
      'completed': instance.completed,
    };

SaleRecord _$SaleRecordFromJson(Map<String, dynamic> json) => SaleRecord(
  id: json['id'] as String,
  batchId: json['flock_id'] as String,
  date: DateTime.parse(json['date'] as String),
  quantity: (json['quantity'] as num).toInt(),
  pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
  pricePerBird: (json['price_per_bird'] as num).toDouble(),
  totalAmount: (json['total_amount'] as num).toDouble(),
  buyerName: json['buyer_name'] as String?,
  buyerPhone: json['buyer_phone'] as String?,
  buyerLocation: json['buyer_location'] as String?,
  notes: json['notes'] as String?,
  mpesaTransactionId: json['mpesa_transaction_id'] as String?,
  averageWeight: (json['average_weight_grams'] as num?)?.toDouble(),
  customerId: json['customer_id'] as String?,
);

Map<String, dynamic> _$SaleRecordToJson(SaleRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flock_id': instance.batchId,
      'date': instance.date.toIso8601String(),
      'quantity': instance.quantity,
      'price_per_kg': instance.pricePerKg,
      'price_per_bird': instance.pricePerBird,
      'total_amount': instance.totalAmount,
      'buyer_name': instance.buyerName,
      'buyer_phone': instance.buyerPhone,
      'buyer_location': instance.buyerLocation,
      'notes': instance.notes,
      'mpesa_transaction_id': instance.mpesaTransactionId,
      'average_weight_grams': instance.averageWeight,
      'customer_id': instance.customerId,
    };

FeedRecord _$FeedRecordFromJson(Map<String, dynamic> json) => FeedRecord(
  id: json['id'] as String,
  batchId: json['flock_id'] as String,
  date: DateTime.parse(json['event_date'] as String),
  feedType: json['feed_type'] as String,
  quantity: (json['quantity_kg'] as num).toDouble(),
  cost: (json['cost_ksh'] as num?)?.toDouble(),
  supplier: json['supplier'] as String?,
  notes: json['notes'] as String?,
  isHomemade: json['is_homemade'] as bool?,
  ingredients: (json['ingredients'] as List<dynamic>?)
      ?.map((e) => FeedIngredient.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FeedRecordToJson(FeedRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flock_id': instance.batchId,
      'event_date': instance.date.toIso8601String(),
      'feed_type': instance.feedType,
      'quantity_kg': instance.quantity,
      'cost_ksh': instance.cost,
      'supplier': instance.supplier,
      'notes': instance.notes,
      'is_homemade': instance.isHomemade,
      'ingredients': instance.ingredients,
    };

FeedIngredient _$FeedIngredientFromJson(Map<String, dynamic> json) =>
    FeedIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      proteinContent: (json['protein_content'] as num?)?.toDouble(),
      energyContent: (json['energy_content'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FeedIngredientToJson(FeedIngredient instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'cost': instance.cost,
      'protein_content': instance.proteinContent,
      'energy_content': instance.energyContent,
    };

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      minimumStock: (json['minimum_stock'] as num).toDouble(),
      costPerUnit: (json['cost_per_unit'] as num).toDouble(),
      lastRestocked: json['last_restocked'] == null
          ? null
          : DateTime.parse(json['last_restocked'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'minimum_stock': instance.minimumStock,
      'cost_per_unit': instance.costPerUnit,
      'last_restocked': instance.lastRestocked?.toIso8601String(),
      'notes': instance.notes,
    };

InventoryHistoryRecord _$InventoryHistoryRecordFromJson(
  Map<String, dynamic> json,
) => InventoryHistoryRecord(
  id: json['id'] as String,
  inventoryItemId: json['inventory_item_id'] as String,
  userId: json['user_id'] as String,
  date: DateTime.parse(json['date'] as String),
  action: json['action'] as String,
  quantityChange: (json['quantity_change'] as num).toDouble(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$InventoryHistoryRecordToJson(
  InventoryHistoryRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'inventory_item_id': instance.inventoryItemId,
  'user_id': instance.userId,
  'date': instance.date.toIso8601String(),
  'action': instance.action,
  'quantity_change': instance.quantityChange,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
};

BiosecurityCheck _$BiosecurityCheckFromJson(Map<String, dynamic> json) =>
    BiosecurityCheck(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => BiosecurityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      completedBy: json['completed_by'] as String?,
    );

Map<String, dynamic> _$BiosecurityCheckToJson(BiosecurityCheck instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'items': instance.items,
      'notes': instance.notes,
      'completed_by': instance.completedBy,
    };

BiosecurityItem _$BiosecurityItemFromJson(Map<String, dynamic> json) =>
    BiosecurityItem(
      task: json['task'] as String,
      completed: json['completed'] as bool,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BiosecurityItemToJson(BiosecurityItem instance) =>
    <String, dynamic>{
      'task': instance.task,
      'completed': instance.completed,
      'notes': instance.notes,
    };

MarketPrice _$MarketPriceFromJson(Map<String, dynamic> json) => MarketPrice(
  id: json['id'] as String,
  date: DateTime.parse(json['price_date'] as String),
  county: json['county'] as String,
  town: json['town'] as String?,
  item: json['item'] as String?,
  pricePerKg: (json['price_per_kg'] as num).toDouble(),
  pricePerBird: (json['price_per_bird'] as num?)?.toDouble(),
  status: json['status'] as String?,
  source: json['source'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$MarketPriceToJson(MarketPrice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'price_date': instance.date.toIso8601String(),
      'county': instance.county,
      'town': instance.town,
      'item': instance.item,
      'price_per_kg': instance.pricePerKg,
      'price_per_bird': instance.pricePerBird,
      'status': instance.status,
      'source': instance.source,
      'notes': instance.notes,
    };

VetConsultation _$VetConsultationFromJson(Map<String, dynamic> json) =>
    VetConsultation(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      batchId: json['flock_id'] as String?,
      issue: json['issue'] as String,
      symptoms: json['symptoms'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      vetName: json['vet_name'] as String?,
      vetPhone: json['vet_phone'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$VetConsultationToJson(VetConsultation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'flock_id': instance.batchId,
      'issue': instance.issue,
      'symptoms': instance.symptoms,
      'diagnosis': instance.diagnosis,
      'treatment': instance.treatment,
      'vet_name': instance.vetName,
      'vet_phone': instance.vetPhone,
      'images': instance.images,
      'status': instance.status,
      'notes': instance.notes,
    };

BatchSummary _$BatchSummaryFromJson(Map<String, dynamic> json) => BatchSummary(
  batch: Batch.fromJson(json['batch'] as Map<String, dynamic>),
  totalMortality: (json['total_mortality'] as num).toInt(),
  currentChicks: (json['current_chicks'] as num).toInt(),
  totalExpenditure: (json['total_expenditure'] as num).toDouble(),
  mortalityRate: (json['mortality_rate'] as num).toDouble(),
  daysActive: (json['days_active'] as num).toInt(),
  totalSales: (json['total_sales'] as num).toDouble(),
  birdsSold: (json['birds_sold'] as num).toInt(),
  remainingBirds: (json['remaining_birds'] as num).toInt(),
  averageWeight: (json['average_weight'] as num?)?.toDouble(),
  totalFeedConsumed: (json['total_feed_consumed'] as num).toDouble(),
  fcr: (json['fcr'] as num?)?.toDouble(),
  totalVaccinationCost: (json['total_vaccination_cost'] as num).toDouble(),
  profitLoss: (json['profit_loss'] as num).toDouble(),
);

Map<String, dynamic> _$BatchSummaryToJson(BatchSummary instance) =>
    <String, dynamic>{
      'batch': instance.batch,
      'total_mortality': instance.totalMortality,
      'current_chicks': instance.currentChicks,
      'total_expenditure': instance.totalExpenditure,
      'mortality_rate': instance.mortalityRate,
      'days_active': instance.daysActive,
      'total_sales': instance.totalSales,
      'birds_sold': instance.birdsSold,
      'remaining_birds': instance.remainingBirds,
      'average_weight': instance.averageWeight,
      'total_feed_consumed': instance.totalFeedConsumed,
      'fcr': instance.fcr,
      'total_vaccination_cost': instance.totalVaccinationCost,
      'profit_loss': instance.profitLoss,
    };

DailyCheck _$DailyCheckFromJson(Map<String, dynamic> json) => DailyCheck(
  id: json['id'] as String?,
  batchId: json['flock_id'] as String,
  checkDate: DateTime.parse(json['check_date'] as String),
  checkTime: json['check_time'] as String?,
  temperatureCelsius: (json['temperature_celsius'] as num?)?.toDouble(),
  humidityPercent: (json['humidity_percent'] as num?)?.toDouble(),
  chickBehavior: json['chick_behavior'] as String?,
  litterCondition: json['litter_condition'] as String?,
  feedLevel: json['feed_level'] as String?,
  waterLevel: json['water_level'] as String?,
  generalNotes: json['general_notes'] as String?,
);

Map<String, dynamic> _$DailyCheckToJson(DailyCheck instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flock_id': instance.batchId,
      'check_date': instance.checkDate.toIso8601String(),
      'check_time': instance.checkTime,
      'temperature_celsius': instance.temperatureCelsius,
      'humidity_percent': instance.humidityPercent,
      'chick_behavior': instance.chickBehavior,
      'litter_condition': instance.litterCondition,
      'feed_level': instance.feedLevel,
      'water_level': instance.waterLevel,
      'general_notes': instance.generalNotes,
    };

ScheduledTask _$ScheduledTaskFromJson(Map<String, dynamic> json) =>
    ScheduledTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String? ?? 'PENDING',
      category: json['category'] as String? ?? 'general',
      batchId: json['flock_id'] as String?,
      recurrenceInterval: json['recurrence_interval'] as String?,
    );

Map<String, dynamic> _$ScheduledTaskToJson(ScheduledTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'due_date': instance.dueDate.toIso8601String(),
      'status': instance.status,
      'category': instance.category,
      'flock_id': instance.batchId,
      'recurrence_interval': instance.recurrenceInterval,
    };

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) => AIResponse(
  statusFlag: json['status_flag'] as String?,
  reasoningExplanation: json['reasoning_explanation'] as String?,
  alertLevel: json['alert_level'] as String?,
  recommendations: (json['recommendations'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  potentialCauses: (json['potential_causes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  response: json['response'] as String?,
  actionableHighlights: (json['actionable_highlights'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedDaysToTarget: (json['estimated_days_to_target'] as num?)?.toDouble(),
  estimatedFcr: (json['estimated_fcr'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AIResponseToJson(AIResponse instance) =>
    <String, dynamic>{
      'status_flag': instance.statusFlag,
      'reasoning_explanation': instance.reasoningExplanation,
      'alert_level': instance.alertLevel,
      'recommendations': instance.recommendations,
      'potential_causes': instance.potentialCauses,
      'response': instance.response,
      'actionable_highlights': instance.actionableHighlights,
      'estimated_days_to_target': instance.estimatedDaysToTarget,
      'estimated_fcr': instance.estimatedFcr,
    };
