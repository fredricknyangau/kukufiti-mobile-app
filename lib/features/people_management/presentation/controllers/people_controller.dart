import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client_provider.dart';
import 'package:mobile/features/people_management/data/repositories/people_repository_impl.dart';
import 'package:mobile/features/people_management/domain/entities/person.dart';
import 'package:mobile/features/people_management/domain/repositories/people_repository.dart';
import 'package:mobile/features/people_management/domain/usecases/get_people_usecase.dart';

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PeopleRepositoryImpl(apiClient);
});

final getPeopleUseCaseProvider = Provider<GetPeopleUseCase>((ref) {
  final repository = ref.watch(peopleRepositoryProvider);
  return GetPeopleUseCase(repository);
});

// Safe manual family provider standard
final peopleProvider = FutureProvider.family<List<Person>, String>((ref, type) async {
  final useCase = ref.watch(getPeopleUseCaseProvider);
  final result = await useCase(type);
  return result.fold(
    (failure) => throw failure.message,
    (people) => people,
  );
});

// Helper for mutation triggers
class PeopleOps {
  final Ref ref;
  PeopleOps(this.ref);

  Future<void> create({
    required String name,
    required String type,
    String? email,
    String? phone,
  }) async {
    final repo = ref.read(peopleRepositoryProvider);
    final result = await repo.createPerson(
      name: name,
      type: type,
      email: email,
      phone: phone,
    );
    
    return result.fold(
      (f) => throw f.message,
      (_) {
        // Force refresh the specific family list node
        ref.invalidate(peopleProvider(type));
      },
    );
  }
}

final peopleOpsProvider = Provider<PeopleOps>((ref) => PeopleOps(ref));
