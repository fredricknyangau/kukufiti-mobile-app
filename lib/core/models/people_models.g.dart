// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Supplier _$SupplierFromJson(Map<String, dynamic> json) => Supplier(
  id: json['id'] as String,
  name: json['name'] as String,
  contactName: json['contact_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  email: json['email'] as String?,
  category: json['category'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SupplierToJson(Supplier instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'contact_name': instance.contactName,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'category': instance.category,
  'notes': instance.notes,
};

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  id: json['id'] as String,
  name: json['name'] as String,
  phoneNumber: json['phone_number'] as String?,
  email: json['email'] as String?,
  location: json['location'] as String?,
  customerType: json['customer_type'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'location': instance.location,
  'customer_type': instance.customerType,
  'notes': instance.notes,
};

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
  id: json['id'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  phoneNumber: json['phone_number'] as String?,
  salary: const OptionalDoubleConverter().fromJson(json['salary']),
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'role': instance.role,
  'phone_number': instance.phoneNumber,
  'salary': const OptionalDoubleConverter().toJson(instance.salary),
  'start_date': instance.startDate?.toIso8601String(),
  'is_active': instance.isActive,
};
