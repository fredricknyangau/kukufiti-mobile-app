import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/shared/utils/json_converters.dart';

part 'people_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Supplier {
  final String id;
  final String name;
  final String? contactName;
  final String? phoneNumber;
  final String? email;
  final String category; // 'feed' | 'chicks' | 'medicine' | 'equipment' | 'other'
  final String? notes;

  Supplier({
    required this.id,
    required this.name,
    this.contactName,
    this.phoneNumber,
    this.email,
    required this.category,
    this.notes,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => _$SupplierFromJson(json);
  Map<String, dynamic> toJson() => _$SupplierToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Customer {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? location;
  final String customerType; // 'wholesale' | 'retail' | 'other'
  final String? notes;

  Customer({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.location,
    required this.customerType,
    this.notes,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Employee {
  final String id;
  final String name;
  final String role; // 'manager' | 'worker' | 'vet' | 'other'
  final String? phoneNumber;
  @OptionalDoubleConverter()
  final double? salary;
  final DateTime? startDate;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.salary,
    this.startDate,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}
