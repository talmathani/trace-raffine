import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_order.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({required this._createOrder}) : super(const OrderInitial()) {
    on<OrderCreateRequested>(_onCreateRequested, transformer: _droppable());
  }

  final CreateOrder _createOrder;

  Future<void> _onCreateRequested(
    OrderCreateRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderCreating());

    try {
      final orderId = await _createOrder(
        customerId: event.customerId,
        designId: event.designId,
        designerId: event.designerId,
        amount: event.amount,
      );

      emit(OrderCreateSuccess(orderId: orderId));
    } catch (error) {
      emit(OrderFailure(message: _mapErrorMessage(error)));
    }
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('permission')) {
      return 'لا تملك صلاحية إنشاء الطلب.';
    }

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('socket')) {
      return 'تعذر الاتصال بالخدمة. تحقق من الإنترنت.';
    }

    return 'تعذر إنشاء الطلب. حاول مرة أخرى.';
  }

  EventTransformer<T> _droppable<T>() {
    return (events, mapper) {
      return events.asyncExpand((event) async* {
        if (state is OrderCreating) {
          return;
        }

        yield* mapper(event);
      });
    };
  }
}
