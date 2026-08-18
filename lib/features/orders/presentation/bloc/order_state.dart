part of 'order_bloc.dart';

sealed class OrderState {
  const OrderState();
}

final class OrderInitial extends OrderState {
  const OrderInitial();
}

final class OrderCreating extends OrderState {
  const OrderCreating();
}

final class OrderCreateSuccess extends OrderState {
  const OrderCreateSuccess({required this.orderId});

  final String orderId;
}

final class OrderFailure extends OrderState {
  const OrderFailure({required this.message});

  final String message;
}
