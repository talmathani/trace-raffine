part of 'order_bloc.dart';

sealed class OrderEvent {
  const OrderEvent();
}

final class OrderCreateRequested extends OrderEvent {
  const OrderCreateRequested({
    required this.customerId,
    required this.designId,
    required this.designerId,
    required this.amount,
  });

  final String customerId;
  final String designId;
  final String designerId;
  final double amount;
}
