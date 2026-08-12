import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/customer_design_model.dart';
import '../../../domain/usecases/watch_approved_customer_designs.dart';

part 'customer_design_event.dart';
part 'customer_design_state.dart';

class CustomerDesignBloc
    extends Bloc<CustomerDesignEvent, CustomerDesignState> {
  CustomerDesignBloc({
    required this._watchApprovedCustomerDesigns,
  }) : super(const CustomerDesignInitial()) {
    on<CustomerDesignStarted>(_onStarted);
    on<CustomerDesignCategoryChanged>(_onCategoryChanged);
    on<CustomerDesignReloadRequested>(_onReloadRequested);
    on<CustomerDesignDataReceived>(_onDataReceived);
    on<CustomerDesignStreamFailed>(_onStreamFailed);
  }

  final WatchApprovedCustomerDesigns _watchApprovedCustomerDesigns;

  StreamSubscription<List>? _subscription;

  String? _category;

  Future<void> _onStarted(
    CustomerDesignStarted event,
    Emitter<CustomerDesignState> emit,
  ) async {
    await _startWatching(emit);
  }

  Future<void> _onCategoryChanged(
    CustomerDesignCategoryChanged event,
    Emitter<CustomerDesignState> emit,
  ) async {
    _category = event.category;
    await _startWatching(emit);
  }

  Future<void> _onReloadRequested(
    CustomerDesignReloadRequested event,
    Emitter<CustomerDesignState> emit,
  ) async {
    await _startWatching(emit);
  }

  void _onDataReceived(
    CustomerDesignDataReceived event,
    Emitter<CustomerDesignState> emit,
  ) {
    emit(
      CustomerDesignLoaded(
        designs: List.unmodifiable(event.designs),
        category: event.category,
      ),
    );
  }

  void _onStreamFailed(
    CustomerDesignStreamFailed event,
    Emitter<CustomerDesignState> emit,
  ) {
    emit(
      CustomerDesignFailure(
        message: _mapErrorMessage(event.error),
        category: event.category,
      ),
    );
  }

  Future<void> _startWatching(
    Emitter<CustomerDesignState> emit,
  ) async {
    await _subscription?.cancel();

    emit(
      CustomerDesignLoading(
        category: _category,
      ),
    );

    _subscription = _watchApprovedCustomerDesigns(
      category: _category,
    ).listen(
      (designs) {
        if (isClosed) {
          return;
        }

        add(
          CustomerDesignDataReceived(
            designs: designs,
            category: _category,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isClosed) {
          return;
        }

        add(
          CustomerDesignStreamFailed(
            error: error,
            stackTrace: stackTrace,
            category: _category,
          ),
        );
      },
    );
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('permission-denied')) {
      return 'لا تملك صلاحية الوصول إلى التصاميم.';
    }

    if (message.contains('failed-precondition')) {
      return 'يحتاج هذا الاستعلام إلى إعداد فهرس في Firebase.';
    }

    if (message.contains('unavailable')) {
      return 'خدمة التصاميم غير متاحة حاليًا. حاول مرة أخرى.';
    }

    if (message.contains('network')) {
      return 'تعذر الاتصال بالخدمة. تحقق من الإنترنت.';
    }

    return 'تعذر تحميل التصاميم. حاول مرة أخرى.';
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
