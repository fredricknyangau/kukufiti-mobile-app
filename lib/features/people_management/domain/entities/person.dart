class Person {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String type; // Supplier, Customer, Employee

  Person({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.type,
  });
}
