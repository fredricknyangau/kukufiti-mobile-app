import '../../domain/entities/person.dart';

class PersonDto {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String type;

  PersonDto({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.type,
  });

  factory PersonDto.fromJson(Map<String, dynamic> json, String type) {
    return PersonDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      type: type,
    );
  }

  Person toEntity() {
    return Person(
      id: id,
      name: name,
      email: email,
      phone: phone,
      type: type,
    );
  }
}
