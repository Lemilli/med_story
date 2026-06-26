import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event_api.dart';
import '../../data/event_repository.dart';
import '../../domain/medical_event.dart';

final eventDetailProvider = FutureProvider.autoDispose
    .family<MedicalEvent, String>((ref, id) {
      return ref.watch(eventRepositoryProvider).getEvent(id);
    });

final eventFormControllerProvider =
    AsyncNotifierProvider<EventFormController, void>(EventFormController.new);

class EventFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<MedicalEvent> create(EventWriteRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(eventRepositoryProvider).createEvent(request),
    );
    state = result.when(
      data: (_) => const AsyncValue.data(null),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      loading: () => const AsyncValue.loading(),
    );
    return result.requireValue;
  }

  Future<MedicalEvent> saveUpdate(String id, EventWriteRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(eventRepositoryProvider).updateEvent(id, request),
    );
    state = result.when(
      data: (_) => const AsyncValue.data(null),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      loading: () => const AsyncValue.loading(),
    );
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(eventRepositoryProvider).deleteEvent(id),
    );
  }
}
